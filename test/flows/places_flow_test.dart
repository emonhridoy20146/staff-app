import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/places/src/places_data.dart';

import 'helpers.dart';

/// Master FR-PLC-002..005 (contract 1.38.0): a place is added offline, changed before it was sent,
/// gets its server id from the sync; a move request waits for the office, whose decision comes back.
void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await h.dispose();
  });

  Future<void> sync() => h.read(syncEngineProvider).syncNow();
  Future<List<PlaceRow>> rows() async {
    final db = h.read(databaseProvider);
    return db.select(db.mapPlaces).get();
  }

  Future<List<OutboxRow>> outbox(String entity) async {
    final db = h.read(databaseProvider);
    return (await db.select(db.outbox).get()).where((o) => o.entity == entity).toList();
  }

  test('added offline: on the map at once, edited before sending, both sent in order, server id comes back', () async {
    await h.signIn();
    h.api.offline = true;
    final svc = h.read(placeServiceProvider);
    final id = await svc.create(name: '  করিম স্টোর ', icon: 'shop', note: 'নীল গেট', lat: 22.7012, lng: 90.3711);
    var p = (await rows()).single;
    expect([p.localId, p.serverId, p.name, p.icon, p.note, p.createState], [id, null, 'করিম স্টোর', 'shop', 'নীল গেট', 'queued']);
    expect(p.createdById, 'u-fs-014');
    expect(MapPlace(p).isMine('u-fs-014'), isTrue);

    // A change before the network is back names the place by my clientId and waits for the create.
    await svc.edit(id, name: 'করিম জেনারেল স্টোর', icon: 'shop', note: 'নীল গেট');
    final edit = (await outbox('place_edit')).single;
    expect(edit.payloadJson, contains('"placeClientId":"$id"'));
    expect(edit.dependsOnJson, contains((await outbox('place')).single.mutationId));
    // Nothing new: no second mutation.
    await svc.edit(id, name: 'করিম জেনারেল স্টোর', icon: 'shop', note: 'নীল গেট');
    expect(await outbox('place_edit'), hasLength(1));

    h.api.offline = false;
    await sync();
    p = (await rows()).single;
    expect(p.localId, id); // the same row on the phone
    expect(p.serverId, startsWith('pl-'));
    expect([p.name, p.createState, p.editState, p.version], ['করিম জেনারেল স্টোর', 'synced', 'none', 2]);
    expect(h.api.appliedPayloads.values.where((x) => x['placeClientId'] == id), hasLength(1));
  });

  test('a colleague\'s place arrives with the sync; my move request waits for the office, then the marker moves', () async {
    h.api.addPlace('pl-9', name: 'নতুন বাজার', icon: 'market', lat: 22.7045, lng: 90.3725, by: const {'id': 'u-fs-002', 'name': 'সুমন মিয়া'});
    await h.signIn();
    var p = (await rows()).single;
    expect([p.serverId, p.name, p.createdByName], ['pl-9', 'নতুন বাজার', 'সুমন মিয়া']);
    expect(MapPlace(p).isMine('u-fs-014'), isFalse);

    h.api.offline = true;
    final svc = h.read(placeServiceProvider);
    expect(await svc.requestMove(p.localId, lat: 22.7052, lng: 90.3731, reason: 'মূল গেট রাস্তার ওপারে'), isTrue);
    // One request at a time.
    expect(await svc.requestMove(p.localId, lat: 22.706, lng: 90.374), isFalse);
    p = (await rows()).single;
    expect([p.moveState, p.lat, p.moveLat], ['queued', 22.7045, 22.7052]);
    expect(MapPlace(p).movePending, isTrue);
    expect(MapPlace(p).requestedPoint, (lat: 22.7052, lng: 90.3731));

    h.api.offline = false;
    await sync();
    p = (await rows()).single;
    expect(p.moveState, 'none'); // sent, and the server's open request (pendingMove) took over
    expect(p.lat, 22.7045); // the marker stays until the office decides
    expect(MapPlace(p).pendingMove?['reason'], 'মূল গেট রাস্তার ওপারে');

    h.api.decidePlaceMove('pl-9', approve: false, reason: 'গেট এই পাশেই');
    await sync();
    p = (await rows()).single;
    expect([p.lat, p.pendingMoveJson], [22.7045, null]);
    expect(MapPlace(p).lastDecision?['reason'], 'গেট এই পাশেই');
    expect(MapPlace(p).movePending, isFalse);

    await svc.requestMove(p.localId, lat: 22.7052, lng: 90.3731);
    await sync();
    h.api.decidePlaceMove('pl-9', approve: true);
    await sync();
    p = (await rows()).single;
    expect([p.lat, p.lng, p.pendingMoveJson], [22.7052, 90.3731, null]);
    expect(MapPlace(p).lastDecision?['decision'], 'approve');
  });

  test('refusals stay on the place with their reason; a removed place leaves, but never what is still unsent', () async {
    h.api.addPlace('pl-1', name: 'সোনালী ব্যাংক', icon: 'bank');
    h.api.addPlace('pl-2', name: 'বাস স্ট্যান্ড', icon: 'bus_stop');
    await h.signIn();
    final svc = h.read(placeServiceProvider);
    final byName = {for (final r in await rows()) r.name: r};

    // Not mine: the server refuses a change of words (staff edit only their own places).
    await svc.edit(byName['সোনালী ব্যাংক']!.localId, name: 'জনতা ব্যাংক', icon: 'bank');
    await sync();
    var bank = (await rows()).firstWhere((r) => r.serverId == 'pl-1');
    expect([bank.editState, bank.errorCode], ['failed', 'NOT_OWNER']);

    // The office removes one place while my move request for it is still on the phone: it stays.
    h.api.offline = true;
    await svc.requestMove(byName['বাস স্ট্যান্ড']!.localId, lat: 22.36, lng: 90.33);
    h.api.deletePlace('pl-1');
    h.api.deletePlace('pl-2');
    h.api.offline = false;
    final db = h.read(databaseProvider);
    await PlacePullHandler().delete(db, 'pl-2');
    expect((await rows()).where((r) => r.serverId == 'pl-2'), hasLength(1));
    await PlacePullHandler().delete(db, 'pl-1');
    expect((await rows()).where((r) => r.serverId == 'pl-1'), isEmpty);
    bank = (await rows()).first;
    expect(bank.serverId, 'pl-2');
  });
}
