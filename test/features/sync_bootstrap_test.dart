import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/api/api_models.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/visits/src/visits.dart';

import '../flows/helpers.dart';

/// FR-M-032 (2026-11-19): GET /sync/bootstrap answers `items` + a snapshot `nextCursor` + `pullCursor`
/// (contract SyncBootstrapResponse). Until 0.12.4 the app read it like a pull page and stored none of the
/// snapshot, so staff saw only customers that changed later (an assignment, a pin).
void main() {
  test('a bootstrap page is read in the contract shape', () {
    final mid = SyncPullResponse.fromBootstrapJson({
      'items': [
        {'entity': 'customer', 'op': 'upsert', 'id': 'c1', 'data': {'id': 'c1'}},
      ],
      'nextCursor': 'eyJpIjoyfQ',
    });
    expect(mid.changes.single.id, 'c1');
    expect(mid.hasMore, isTrue);
    expect(mid.bootstrapCursor, 'eyJpIjoyfQ');
    expect(mid.nextCursor, isEmpty, reason: 'a snapshot cursor is never a pull cursor');

    final last = SyncPullResponse.fromBootstrapJson({'items': const [], 'nextCursor': null, 'pullCursor': 's_96'});
    expect(last.hasMore, isFalse);
    expect(last.nextCursor, 's_96');
  });

  test('first login over several snapshot pages stores every customer and the pull cursor', () async {
    final h = Harness();
    h.api.bootstrapPageSize = 2;
    await h.signIn();
    final db = h.read(databaseProvider);
    expect((await db.select(db.customers).get()).length, greaterThan(2));
    final meta = (await db.select(db.syncMeta).get()).single;
    expect(int.tryParse(meta.pullCursor ?? ''), isNotNull, reason: 'pull starts at the pullCursor of the last page');
    await h.dispose();
  });

  test('a phone that bootstrapped with an older app takes one fresh snapshot, keeping the outbox', () async {
    final h = Harness();
    await h.signIn();
    final db = h.read(databaseProvider);
    final all = (await db.select(db.customers).get()).length;
    // What 0.12.3 left behind: snapshot "done", a pull cursor, but customers missing, and no format mark.
    await db.delete(db.customers).go();
    await (db.delete(db.kvSettings)..where((t) => t.key.equals('sync.snapshotFormat'))).go();
    await db.into(db.outbox).insert(OutboxCompanion.insert(mutationId: 'm-keep', entity: 'note', op: 'create', payloadJson: '{}', createdAt: DateTime.utc(2026, 11, 19), state: const Value('failed')));
    await h.read(syncEngineProvider).kick();
    expect((await db.select(db.customers).get()).length, all);
    expect((await db.select(db.outbox).get()).map((o) => o.mutationId), contains('m-keep'));
    // Only once: a later run does not take another snapshot.
    expect(await db.kvGet('sync.snapshotFormat'), isNotNull);
    await h.dispose();
  });

  test('same-day visits: count and latest check-in since the start of the business day', () {
    final start = DateTime.utc(2026, 11, 18, 18); // Dhaka midnight
    VisitRow v(String id, DateTime at) => VisitRow(clientId: id, customerId: 'c1', outcome: 'not_home', checkInAt: at, syncState: 'synced', mock: false, photoMediaClientIdsJson: '[]', source: 'manual');
    expect(sameDayVisits([v('a', DateTime.utc(2026, 11, 18, 17, 59))], start), isNull);
    final r = sameDayVisits([v('a', DateTime.utc(2026, 11, 18, 18)), v('b', DateTime.utc(2026, 11, 19, 5)), v('c', DateTime.utc(2026, 11, 18, 10))], start)!;
    expect(r.count, 2);
    expect(r.checkInAt, DateTime.utc(2026, 11, 19, 5));
  });
}
