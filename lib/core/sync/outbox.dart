import 'dart:convert';

import 'package:drift/drift.dart';

import '../api/api_models.dart';
import '../db/app_database.dart';
import '../time/clock.dart';

/// Write side of the offline sync engine (04-architecture §5.1).
///
/// Use cases call [enqueue] **inside the same DB transaction** that writes
/// the local entity, so the entity and its mutation are saved atomically.
/// The mutation id is the entity's clientId (UUIDv7 created once at save time)
/// and is the server's idempotency key — never regenerate it.
class OutboxWriter {
  OutboxWriter(this._db, this._clock);
  final AppDatabase _db;
  final Clock _clock;

  Future<void> enqueue({
    required String mutationId,
    required String entity,
    required Json payload,
    String op = 'create',
    List<String> dependsOn = const [],
    bool held = false,
  }) async {
    assert(SyncMutation.entities.contains(entity), 'Unknown mutation entity "$entity" — add it to the contract first');
    await _db.into(_db.outbox).insert(
          OutboxCompanion.insert(
            mutationId: mutationId,
            entity: entity,
            op: op,
            payloadJson: jsonEncode(payload),
            dependsOnJson: Value(jsonEncode(dependsOn)),
            createdAt: _clock.nowUtc(),
            // `held`: saved but not sent until something it needs is ready
            // (e.g. its photo is uploaded); see [release]. Counts as unsynced.
            state: held ? const Value('held') : const Value.absent(),
          ),
          // Same id twice = same mutation: keep the original (idempotent save).
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Moves a held mutation to pending, merging [extra] into its payload.
  /// False when there was no held mutation with that id.
  Future<bool> release(String mutationId, Json extra) async {
    final row = await (_db.select(_db.outbox)..where((t) => t.mutationId.equals(mutationId) & t.state.equals('held'))).getSingleOrNull();
    if (row == null) return false;
    final payload = {...(jsonDecode(row.payloadJson) as Json), ...extra};
    await (_db.update(_db.outbox)..where((t) => t.mutationId.equals(mutationId))).write(
      OutboxCompanion(state: const Value('pending'), payloadJson: Value(jsonEncode(payload))),
    );
    return true;
  }
}

/// Read helpers for UI (counts, problems) — streams from the local DB.
class OutboxReader {
  OutboxReader(this._db);
  final AppDatabase _db;

  Stream<int> watchPendingCount() {
    final c = _db.outbox.mutationId.count();
    final q = _db.selectOnly(_db.outbox)
      ..addColumns([c])
      ..where(_db.outbox.state.isIn(['held', 'pending', 'sending']));
    return q.map((r) => r.read(c) ?? 0).watchSingle();
  }

  /// Unsent (held, pending or sending) mutations of one entity.
  Stream<int> watchUnsentOf(String entity) {
    final c = _db.outbox.mutationId.count();
    final q = _db.selectOnly(_db.outbox)
      ..addColumns([c])
      ..where(_db.outbox.entity.equals(entity) & _db.outbox.state.isIn(['held', 'pending', 'sending']));
    return q.map((r) => r.read(c) ?? 0).watchSingle();
  }

  Future<bool> hasUnsentOf(String entity) async => (await watchUnsentOf(entity).first) > 0;

  Stream<int> watchFailedCount() {
    final c = _db.outbox.mutationId.count();
    final q = _db.selectOnly(_db.outbox)
      ..addColumns([c])
      ..where(_db.outbox.state.equals('failed'));
    return q.map((r) => r.read(c) ?? 0).watchSingle();
  }

  /// Counts of unsent mutations by entity (sync centre).
  Stream<Map<String, int>> watchPendingByEntity() {
    final c = _db.outbox.mutationId.count();
    final q = _db.selectOnly(_db.outbox)
      ..addColumns([_db.outbox.entity, c])
      ..where(_db.outbox.state.isIn(['held', 'pending', 'sending', 'failed']))
      ..groupBy([_db.outbox.entity]);
    return q.watch().map((rows) => {for (final r in rows) r.read(_db.outbox.entity)!: r.read(c) ?? 0});
  }

  Stream<DateTime?> watchOldestPending() {
    final m = _db.outbox.createdAt.min();
    final q = _db.selectOnly(_db.outbox)
      ..addColumns([m])
      ..where(_db.outbox.state.isIn(['held', 'pending', 'sending', 'failed']));
    return q.map((r) => r.read(m)).watchSingle();
  }

  Stream<List<OutboxRow>> watchFailed() =>
      (_db.select(_db.outbox)..where((t) => t.state.equals('failed'))..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).watch();

  Future<int> unsyncedCount() async {
    final c = _db.outbox.mutationId.count();
    final q = _db.selectOnly(_db.outbox)
      ..addColumns([c])
      ..where(_db.outbox.state.isIn(['held', 'pending', 'sending', 'failed']));
    final m = _db.mediaQueue.clientId.count();
    final mq = _db.selectOnly(_db.mediaQueue)
      ..addColumns([m])
      ..where(_db.mediaQueue.state.isIn(['pending', 'failed']));
    // Unsent photos count too: logout must never discard them (CLAUDE.md §2.2).
    return (await q.map((r) => r.read(c) ?? 0).getSingle()) + (await mq.map((r) => r.read(m) ?? 0).getSingle());
  }
}
