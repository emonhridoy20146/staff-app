import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../api/api_models.dart';
import '../api/field_api.dart';
import '../db/app_database.dart';
import '../time/clock.dart';
import 'backoff.dart';
import 'sync_handlers.dart';

/// Snapshot of what the server sends alongside pull pages.
class ServerSnapshot {
  const ServerSnapshot({this.permissions, this.flags, this.settings, this.cash, this.target});
  final List<String>? permissions;
  final Map<String, bool>? flags;
  final Json? settings;
  final CashPositionDto? cash;
  final MyTarget? target;
}

enum SyncPhase { idle, bootstrapping, pushing, pulling }

class SyncStatus {
  const SyncStatus({
    this.phase = SyncPhase.idle,
    this.online = true,
    this.lastSuccessAt,
    this.lastErrorCode,
    this.bootstrapProgress,
  });
  final SyncPhase phase;
  final bool online;
  final DateTime? lastSuccessAt;
  final String? lastErrorCode;

  /// 0..1 while bootstrapping (pages done / estimate), else null.
  final double? bootstrapProgress;

  bool get running => phase != SyncPhase.idle;

  SyncStatus copyWith({SyncPhase? phase, bool? online, DateTime? lastSuccessAt, String? lastErrorCode, bool clearError = false, double? bootstrapProgress}) =>
      SyncStatus(
        phase: phase ?? this.phase,
        online: online ?? this.online,
        lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
        lastErrorCode: clearError ? null : (lastErrorCode ?? this.lastErrorCode),
        bootstrapProgress: bootstrapProgress,
      );
}

/// Offline sync engine (04-architecture §5).
///
/// * Push: outbox FIFO by createdAt, honouring `dependsOn`, batches ≤ 50.
///   applied/replayed → done; conflict → done + entity shows conflict;
///   rejected → failed (stays visible in Problems, never deleted);
///   rejected + retryable → pending again with backoff (1.5.0);
///   network/5xx → pending with exponential backoff.
/// * Pull: cursor loop until hasMore=false; one transaction per page;
///   cursor saved after commit; 410 → bootstrap (outbox untouched).
class SyncEngine {
  SyncEngine({
    required AppDatabase db,
    required FieldApi api,
    required Clock clock,
    required SyncHandlerRegistry handlers,
    required String deviceId,
    required void Function(ServerSnapshot) onSnapshot,
    Backoff? backoff,
    this.batchSize = 50,
  })  : _db = db,
        _api = api,
        _clock = clock,
        _handlers = handlers,
        _deviceId = deviceId,
        _onSnapshot = onSnapshot,
        _backoff = backoff ?? Backoff();

  final AppDatabase _db;
  final FieldApi _api;
  final Clock _clock;
  final SyncHandlerRegistry _handlers;
  final String _deviceId;
  final void Function(ServerSnapshot) _onSnapshot;
  final Backoff _backoff;
  final int batchSize;

  final _status = StreamController<SyncStatus>.broadcast();
  SyncStatus _current = const SyncStatus();
  Future<void>? _running;
  bool _again = false;

  Stream<SyncStatus> get status => _status.stream;
  SyncStatus get current => _current;

  void _emit(SyncStatus s) {
    _current = s;
    if (!_status.isClosed) _status.add(s);
  }

  /// Request a sync. Coalesces concurrent requests into one run (+1 rerun).
  Future<void> kick({String reason = 'manual'}) {
    if (_running != null) {
      _again = true;
      return _running!;
    }
    final run = _run().whenComplete(() => _running = null);
    _running = run;
    return run;
  }

  Future<void> _run() async {
    do {
      _again = false;
      try {
        final meta = await _meta();
        if (!meta.bootstrapDone) await bootstrap();
        _emit(_current.copyWith(phase: SyncPhase.pushing));
        await pushAll();
        _emit(_current.copyWith(phase: SyncPhase.pulling));
        await pullAll();
        final now = _clock.nowUtc();
        await _updateMeta(SyncMetaCompanion(lastSuccessAt: Value(now), lastError: const Value(null)));
        _emit(_current.copyWith(phase: SyncPhase.idle, online: true, lastSuccessAt: now, clearError: true));
      } on ApiException catch (e) {
        await _updateMeta(SyncMetaCompanion(lastError: Value(e.code)));
        _emit(_current.copyWith(phase: SyncPhase.idle, online: !e.isNetwork, lastErrorCode: e.code));
        return;
      }
    } while (_again);
  }

  Future<SyncMetaRow> _meta() async {
    final row = await (_db.select(_db.syncMeta)..where((t) => t.id.equals(1))).getSingleOrNull();
    if (row != null) return row;
    await _db.into(_db.syncMeta).insert(SyncMetaCompanion.insert());
    return (await (_db.select(_db.syncMeta)..where((t) => t.id.equals(1))).getSingle());
  }

  Future<void> _updateMeta(SyncMetaCompanion c) async {
    await _meta();
    await (_db.update(_db.syncMeta)..where((t) => t.id.equals(1))).write(c);
  }

  // ── push ────────────────────────────────────────────────────────────────

  /// Sends all eligible pending mutations. Returns number of items sent.
  Future<int> pushAll() async {
    var sent = 0;
    while (true) {
      final batch = await _nextBatch();
      if (batch.isEmpty) break;
      await _pushBatch(batch);
      sent += batch.length;
      if (batch.length < batchSize) break;
    }
    if (sent > 0) await _updateMeta(SyncMetaCompanion(lastPushAt: Value(_clock.nowUtc())));
    return sent;
  }

  Future<List<OutboxRow>> _nextBatch() async {
    final now = _clock.nowUtc();
    final candidates = await (_db.select(_db.outbox)
          ..where((t) => t.state.equals('pending') & (t.nextAttemptAt.isNull() | t.nextAttemptAt.isSmallerOrEqualValue(now)))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt), (t) => OrderingTerm.asc(t.mutationId)])
          ..limit(batchSize * 4))
        .get();
    if (candidates.isEmpty) return const [];

    // dependsOn: a mutation waits until each dependency is done (or not in
    // the outbox at all, e.g. already purged). Items in the same batch are
    // allowed if the dependency comes earlier in it (server applies in order).
    final depIds = <String>{for (final c in candidates) ...(jsonDecode(c.dependsOnJson) as List).cast<String>()};
    final notDone = depIds.isEmpty
        ? <String>{}
        : (await (_db.select(_db.outbox)..where((t) => t.mutationId.isIn(depIds) & t.state.isNotValue('done'))).get())
            .map((r) => r.mutationId)
            .toSet();
    final out = <OutboxRow>[];
    final inBatch = <String>{};
    for (final c in candidates) {
      final deps = (jsonDecode(c.dependsOnJson) as List).cast<String>();
      final ok = deps.every((d) => !notDone.contains(d) || inBatch.contains(d));
      if (!ok) continue;
      out.add(c);
      inBatch.add(c.mutationId);
      if (out.length == batchSize) break;
    }
    return out;
  }

  Future<void> _pushBatch(List<OutboxRow> batch) async {
    final ids = batch.map((b) => b.mutationId).toList();
    await (_db.update(_db.outbox)..where((t) => t.mutationId.isIn(ids))).write(const OutboxCompanion(state: Value('sending')));
    final meta = await _meta();
    SyncPushResponse res;
    try {
      res = await _api.syncPush(
        deviceId: _deviceId,
        lastPullCursor: meta.pullCursor,
        mutations: [
          for (final m in batch)
            SyncMutation(
              mutationId: m.mutationId,
              entity: m.entity,
              op: m.op,
              payload: jsonDecode(m.payloadJson) as Json,
              createdAt: m.createdAt,
            ),
        ],
      );
    } on ApiException catch (e) {
      // Whole request failed: nothing is lost, everything goes back to
      // pending with backoff. Same ids are re-sent → server dedupes.
      await _db.transaction(() async {
        for (final m in batch) {
          final attempts = m.attempts + 1;
          await (_db.update(_db.outbox)..where((t) => t.mutationId.equals(m.mutationId))).write(
            OutboxCompanion(
              state: const Value('pending'),
              attempts: Value(attempts),
              nextAttemptAt: Value(_clock.nowUtc().add(_backoff.delayFor(attempts))),
              lastError: Value(e.code),
            ),
          );
        }
      });
      rethrow;
    }
    if (res.serverTime != null) _clock.syncWithServer(res.serverTime!);

    final byId = {for (final r in res.results) r.mutationId: r};
    await _db.transaction(() async {
      for (final m in batch) {
        final r = byId[m.mutationId];
        if (r == null) {
          // Server did not answer for this item: retry later.
          final attempts = m.attempts + 1;
          await (_db.update(_db.outbox)..where((t) => t.mutationId.equals(m.mutationId))).write(
            OutboxCompanion(
              state: const Value('pending'),
              attempts: Value(attempts),
              nextAttemptAt: Value(_clock.nowUtc().add(_backoff.delayFor(attempts))),
              lastError: const Value('NO_RESULT'),
            ),
          );
          continue;
        }
        if (r.result == 'rejected' && r.retryable) {
          // Transient server failure (1.5.0): stays pending, same id later.
          final attempts = m.attempts + 1;
          await (_db.update(_db.outbox)..where((t) => t.mutationId.equals(m.mutationId))).write(
            OutboxCompanion(
              state: const Value('pending'),
              attempts: Value(attempts),
              nextAttemptAt: Value(_clock.nowUtc().add(_backoff.delayFor(attempts))),
              lastError: Value(r.error?.code ?? 'RETRYABLE'),
            ),
          );
          continue;
        }
        final done = r.result == 'applied' || r.result == 'replayed' || r.result == 'conflict';
        if (r.entityId != null) {
          await _db.into(_db.idMap).insertOnConflictUpdate(
                IdMapCompanion.insert(clientId: m.mutationId, entity: m.entity, serverId: r.entityId!),
              );
        }
        await (_db.update(_db.outbox)..where((t) => t.mutationId.equals(m.mutationId))).write(
          OutboxCompanion(
            state: Value(done ? 'done' : 'failed'),
            attempts: Value(m.attempts + 1),
            result: Value(r.result),
            doneAt: Value(done ? _clock.nowUtc() : null),
            lastError: Value(r.error == null ? r.conflictCode : '${r.error!.code}: ${r.error!.detail ?? r.error!.title}'),
          ),
        );
        await _handlers.pushFor(m.entity)?.onResult(_db, m, r);
      }
    });
  }

  /// Puts a failed (rejected) mutation back in the queue — used by
  /// edit-and-resubmit for non-money items. Money items stay failed until a
  /// manager acts (never silently retried with changed content).
  Future<void> retryFailed(String mutationId) async {
    await (_db.update(_db.outbox)..where((t) => t.mutationId.equals(mutationId) & t.state.equals('failed'))).write(
      const OutboxCompanion(state: Value('pending'), nextAttemptAt: Value(null)),
    );
    unawaited(kick(reason: 'retry'));
  }

  /// Retry everything now (manual "Sync now" clears backoff).
  Future<void> syncNow() async {
    await (_db.update(_db.outbox)..where((t) => t.state.equals('pending'))).write(const OutboxCompanion(nextAttemptAt: Value(null)));
    await kick(reason: 'manual');
  }

  // ── pull ────────────────────────────────────────────────────────────────

  Future<void> pullAll() async {
    var meta = await _meta();
    var cursor = meta.pullCursor;
    if (cursor == null) {
      await bootstrap();
      return;
    }
    while (true) {
      SyncPullResponse page;
      try {
        page = await _api.syncPull(cursor!);
      } on ApiException catch (e) {
        if (e.statusCode == 410) {
          await bootstrap();
          return;
        }
        rethrow;
      }
      await _applyPage(page);
      cursor = page.nextCursor;
      if (!page.hasMore) break;
    }
    meta = await _meta();
  }

  /// Paged snapshot of the whole scope (first login, 410). Keeps the outbox.
  Future<void> bootstrap() async {
    _emit(_current.copyWith(phase: SyncPhase.bootstrapping, bootstrapProgress: 0));
    String? cursor;
    var pages = 0;
    while (true) {
      final page = await _api.syncBootstrap(cursor: cursor);
      pages++;
      await _applyPage(page, bootstrap: true);
      _emit(_current.copyWith(phase: SyncPhase.bootstrapping, bootstrapProgress: page.hasMore ? (1 - 1 / (pages + 1)) : 1));
      cursor = page.nextCursor;
      if (!page.hasMore) break;
    }
    await _updateMeta(const SyncMetaCompanion(bootstrapDone: Value(true)));
  }

  Future<void> _applyPage(SyncPullResponse page, {bool bootstrap = false}) async {
    if (page.serverTime != null) _clock.syncWithServer(page.serverTime!);
    await _db.transaction(() async {
      for (final c in page.changes) {
        final h = _handlers.pullFor(c.entity);
        if (h == null) continue; // entity of a disabled / unknown feature
        if (c.op == 'delete') {
          await h.delete(_db, c.id, reason: c.reason);
        } else if (c.data != null) {
          await h.upsert(_db, c.id, c.data!);
        }
      }
      await _updateMeta(
        SyncMetaCompanion(
          pullCursor: Value(page.nextCursor.isEmpty ? null : page.nextCursor),
          lastPullAt: Value(_clock.nowUtc()),
          serverOffsetMs: Value(_clock.serverOffset.inMilliseconds),
        ),
      );
    });
    if (page.permissions != null || page.flags != null || page.settings != null || page.cash != null || page.target != null) {
      _onSnapshot(ServerSnapshot(permissions: page.permissions, flags: page.flags, settings: page.settings, cash: page.cash, target: page.target));
    }
  }

  /// Purges `done` outbox rows older than 7 days (docs/06 §2).
  Future<int> purgeDone() => (_db.delete(_db.outbox)
        ..where((t) => t.state.equals('done') & t.doneAt.isSmallerThanValue(_clock.nowUtc().subtract(const Duration(days: 7)))))
      .go();

  void markOffline() => _emit(_current.copyWith(online: false));

  Future<void> dispose() => _status.close();
}
