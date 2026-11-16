import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
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

  test('a pin proposal is saved offline and sent with its photo once the photo is up', () async {
    await h.signIn();
    final c = (await h.read(customerRepositoryProvider).watchAll().first).firstWhere((c) => !c.hasPin);
    final fix = GeoFix(lat: 22.7051, lng: 90.3601, accuracyM: 9, fixAt: h.clock.nowUtc());
    final db = h.read(databaseProvider);

    h.api.offline = true;
    final id = await h.read(pinCorrectionServiceProvider).record(customer: c, fix: fix, photo: jpeg(), note: 'Blue gate');
    var p = await (db.select(db.locationProposals)..where((t) => t.clientId.equals(id))).getSingle();
    expect(p.syncState, 'waiting_photo');
    expect(p.photoMediaClientId, isNotNull);
    expect((await db.select(db.outbox).get()).where((o) => o.entity == 'location_proposal'), isEmpty);

    // Back online after the photo's retry delay.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    h.api.offline = false;
    h.clock.advance(const Duration(minutes: 1));
    await h.read(mediaServiceProvider).uploadPending();
    await h.read(syncEngineProvider).syncNow();
    p = await (db.select(db.locationProposals)..where((t) => t.clientId.equals(id))).getSingle();
    expect(p.syncState, 'synced');
    final sent = h.api.appliedPayloads[id]!;
    expect(sent['customerId'], c.id);
    expect((sent['geo'] as Map)['accuracyM'], 9);
    expect(sent['photoMediaId'], isNotNull);
    expect(sent['note'], 'Blue gate');
  });
}
