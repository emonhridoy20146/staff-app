import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/location/location_engine.dart';
import 'package:staff_app/core/media/media.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/customers/customers.dart';
import 'package:staff_app/features/customers/src/pin_correction.dart';

import 'helpers.dart';

Uint8List jpeg() => Uint8List.fromList(img.encodeJpg(img.Image(width: 64, height: 48)));

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await h.dispose();
  });

  Future<LocationProposalRow> proposal(String id) {
    final db = h.read(databaseProvider);
    return (db.select(db.locationProposals)..where((t) => t.clientId.equals(id))).getSingle();
  }

  test('a map pin with a photo is saved offline and sent once the photo is up; the manager can reject it', () async {
    h.api.staffPinApproval = 'always';
    await h.signIn();
    final c = (await h.read(customerRepositoryProvider).watchAll().first).firstWhere((c) => !c.hasPin);
    final phone = GeoFix(lat: 22.7051, lng: 90.3601, accuracyM: 9, fixAt: h.clock.nowUtc());
    final db = h.read(databaseProvider);

    h.api.offline = true;
    final id = await h.read(pinCorrectionServiceProvider).record(customer: c, lat: 22.7055, lng: 90.3604, phone: phone, photo: jpeg(), note: 'Blue gate');
    var p = await proposal(id);
    expect(p.syncState, 'waiting_photo');
    expect(p.method, 'map');
    expect(p.photoMediaClientId, isNotNull);
    expect((await db.select(db.outbox).get()).where((o) => o.entity == 'location_proposal'), isEmpty);

    // Back online after the photo's retry delay.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    h.api.offline = false;
    h.clock.advance(const Duration(minutes: 1));
    await h.read(mediaServiceProvider).uploadPending();
    await h.read(syncEngineProvider).syncNow();
    p = await proposal(id);
    expect(p.syncState, 'synced');
    expect(p.status, 'pending', reason: 'policy always: a manager decides');
    final sent = h.api.appliedPayloads[id]!;
    expect(sent['customerId'], c.id);
    expect(sent['method'], 'map');
    expect(sent['geo'], {'lat': 22.7055, 'lng': 90.3604, 'accuracyM': 0.0, 'mock': false});
    expect(sent['deviceGeo'], containsPair('accuracyM', 9.0));
    expect((sent['deviceGeo'] as Map)['mock'], false);
    expect((sent['deviceGeo'] as Map)['capturedAt'], isNotNull);
    expect(sent['photoMediaId'], isNotNull);
    expect(sent['note'], 'Blue gate');

    // Manager rejects it on the web → the proposer learns why (1.7.0).
    h.api.decideProposal(id, 'rejected', reason: 'Wrong house');
    await h.read(syncEngineProvider).syncNow();
    p = await proposal(id);
    expect(p.status, 'rejected');
    expect(p.decisionReason, 'Wrong house');
  });

  test('a pin for a customer without a location, without a photo, is queued at once and set when sent (when_missing)', () async {
    await h.signIn();
    expect(h.read(staffPinApprovalProvider).name, 'whenMissing');
    final c = (await h.read(customerRepositoryProvider).watchAll().first).firstWhere((c) => !c.hasPin);
    final db = h.read(databaseProvider);

    h.api.offline = true;
    final id = await h.read(pinCorrectionServiceProvider).record(customer: c, lat: 22.7101, lng: 90.3502, phone: GeoFix(lat: 22.7102, lng: 90.3503, accuracyM: 40, fixAt: h.clock.nowUtc()));
    var p = await proposal(id);
    expect(p.syncState, 'queued');
    expect(p.photoMediaClientId, isNull);
    final queued = (await db.select(db.outbox).get()).where((o) => o.entity == 'location_proposal').toList();
    expect(queued.single.mutationId, id, reason: 'the mutation id is the proposal client id, made once');
    final body = jsonDecode(queued.single.payloadJson) as Map;
    expect(body.containsKey('photoMediaId'), isFalse);
    expect(body['method'], 'map');

    h.api.offline = false;
    await h.read(syncEngineProvider).syncNow();
    p = await proposal(id);
    expect(p.syncState, 'synced');
    expect(p.status, 'approved');
    final after = (await h.read(customerRepositoryProvider).getOne(c.id))!;
    expect(after.hasPin, isTrue);
    expect(after.pinUsable, isTrue);
    expect(after.row.lat, 22.7101);
    expect(after.row.lng, 90.3502);
    expect(after.row.locationStatus, 'overridden');
  });

  test('moving an existing pin, or a fake phone location, waits for a manager', () async {
    await h.signIn();
    final all = await h.read(customerRepositoryProvider).watchAll().first;
    final pinned = all.firstWhere((c) => c.pinUsable);
    final pinless = all.firstWhere((c) => !c.hasPin);

    final moved = await h.read(pinCorrectionServiceProvider).record(customer: pinned, lat: pinned.row.lat! + 0.001, lng: pinned.row.lng!);
    final mocked = await h.read(pinCorrectionServiceProvider).record(customer: pinless, lat: 22.7101, lng: 90.3502, phone: GeoFix(lat: 22.7101, lng: 90.3502, accuracyM: 3, mock: true, fixAt: h.clock.nowUtc()));
    await h.read(syncEngineProvider).syncNow();
    expect((await proposal(moved)).status, 'pending');
    expect((await proposal(mocked)).status, 'pending');
    expect((h.api.appliedPayloads[mocked]!['deviceGeo'] as Map)['mock'], isTrue);
    expect((await h.read(customerRepositoryProvider).getOne(pinned.id))!.row.lat, pinned.row.lat, reason: 'unchanged until approved');
    expect((await h.read(customerRepositoryProvider).getOne(pinless.id))!.hasPin, isFalse);

    // Approved on the web → the pin arrives as a customer change.
    h.api.decideProposal(moved, 'approved');
    await h.read(syncEngineProvider).syncNow();
    expect((await h.read(customerRepositoryProvider).getOne(pinned.id))!.row.lat, closeTo(pinned.row.lat! + 0.001, 1e-9));
  });

  test('GPS proposals saved before 0.8.0 keep their old body', () {
    const row = LocationProposalRow(clientId: 'p-1', customerId: 'c-1', lat: 22.7, lng: 90.35, accuracyM: 9, note: 'Gate', status: 'pending', syncState: 'queued', method: 'gps');
    expect(locationProposalPayload(row, const ['m-1']), {
      'clientId': 'p-1',
      'customerId': 'c-1',
      'geo': {'lat': 22.7, 'lng': 90.35, 'accuracyM': 9.0, 'mock': false},
      'photoMediaId': 'm-1',
      'note': 'Gate',
    });
  });

  test('a user who can approve pins moves an existing pin at once, even under policy always (1.39.0)', () async {
    h.api.staffPinApproval = 'always';
    h.api.pinApprover = true;
    await h.signIn();
    expect(h.read(canApprovePinsProvider), isTrue, reason: 'from the server snapshot');
    final c = (await h.read(customerRepositoryProvider).watchAll().first).firstWhere((c) => c.pinUsable);
    final id = await h.read(pinCorrectionServiceProvider).record(customer: c, lat: 22.7101, lng: 90.3502);
    await h.read(syncEngineProvider).syncNow();
    final p = await proposal(id);
    expect(p.syncState, 'synced');
    expect(p.status, 'approved', reason: 'the push result says approved');
    expect(await h.read(openProposalProvider(c.id)).future, isNull, reason: 'nothing left waiting on the customer');
  });

  test('field staff moving an existing pin still wait for a manager', () async {
    await h.signIn();
    expect(h.read(canApprovePinsProvider), isFalse);
    final c = (await h.read(customerRepositoryProvider).watchAll().first).firstWhere((c) => c.pinUsable);
    final id = await h.read(pinCorrectionServiceProvider).record(customer: c, lat: 22.7101, lng: 90.3502);
    await h.read(syncEngineProvider).syncNow();
    final p = await proposal(id);
    expect(p.status, 'pending');
    expect((await h.read(openProposalProvider(c.id)).future)?.clientId, id);
  });
}
