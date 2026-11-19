import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/sync/sync_handlers.dart';

/// Tasks from the office (master FR-TASK-001..005, contract 1.20.0).
///
/// A task is a free-form job an admin gave me, not tied to a customer. It
/// arrives as the `task` sync entity. "The work is done" is stored on the
/// phone at once and sent as the `task_resolve_request` mutation, so it
/// works without a network like every other field action. Only the admin
/// makes a task `resolved`.
class TaskPullHandler implements PullHandler {
  @override
  String get entity => 'task';

  @override
  Future<void> upsert(AppDatabase db, String id, Json d) async {
    final existing = await (db.select(db.tasks)..where((t) => t.serverId.equals(id))).getSingleOrNull();
    final status = (d['status'] as String?) ?? 'open';
    final by = d['createdBy'];
    final resolveAt = d['resolveRequestedAt'] == null ? null : DateTime.parse(d['resolveRequestedAt'] as String).toUtc();
    // My "done" tap that the server has not seen yet stays as it is (it still shows as sending).
    final keepLocal = existing != null && existing.resolveState == 'queued' && status == 'open';
    final String resolveState;
    final String? resolveNote;
    final DateTime? resolveRequestedAt;
    if (keepLocal) {
      resolveState = 'queued';
      resolveNote = existing.resolveNote;
      resolveRequestedAt = existing.resolveRequestedAt;
    } else if (status == 'resolve_requested' || status == 'resolved') {
      resolveState = 'synced';
      resolveNote = (d['resolveNote'] as String?) ?? existing?.resolveNote;
      resolveRequestedAt = resolveAt ?? existing?.resolveRequestedAt;
    } else {
      // open again (the office sent it back) or cancelled: nothing of mine is waiting.
      resolveState = existing?.resolveState == 'failed' && status == 'open' ? 'failed' : 'none';
      resolveNote = status == 'open' ? null : (d['resolveNote'] as String?) ?? existing?.resolveNote;
      resolveRequestedAt = status == 'open' ? null : resolveAt ?? existing?.resolveRequestedAt;
    }
    await db.into(db.tasks).insertOnConflictUpdate(TasksCompanion.insert(
          serverId: id,
          title: (d['title'] as String?) ?? '',
          note: Value(d['note'] as String?),
          dueDate: Value(d['dueDate'] as String?),
          status: Value(status),
          createdByName: Value(by is Map ? by['name'] as String? : null),
          branchId: Value(d['branchId'] as String?),
          decisionNote: Value(d['decisionNote'] as String?),
          decidedAt: Value(d['decidedAt'] == null ? null : DateTime.parse(d['decidedAt'] as String).toUtc()),
          eventsJson: Value(jsonEncode(d['events'] ?? const [])),
          createdAt: DateTime.parse(d['createdAt'] as String).toUtc(),
          updatedAt: Value(d['updatedAt'] == null ? null : DateTime.parse(d['updatedAt'] as String).toUtc()),
          seenAt: Value(existing?.seenAt),
          resolveNote: Value(resolveNote),
          resolveRequestedAt: Value(resolveRequestedAt),
          resolveState: Value(resolveState),
          resolveMutationId: Value(existing?.resolveMutationId),
        ));
  }

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) =>
      // Never drop a "done" tap that is still waiting to be sent.
      (db.delete(db.tasks)..where((t) => t.serverId.equals(id) & t.resolveState.equals('queued').not())).go();
}

class TaskResolvePushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'task_resolve_request'};

  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) async {
    final rejected = r.result == 'rejected' || r.result == 'conflict';
    await (db.update(db.tasks)..where((t) => t.resolveMutationId.equals(m.mutationId) & t.resolveState.equals('queued'))).write(
      TasksCompanion(resolveState: Value(rejected ? 'failed' : 'synced')),
    );
    // Applied or replayed: the server moved the task to "waiting for the office"; the next
    // pull brings the exact state, this only keeps the screen right until then.
    if (!rejected) {
      await (db.update(db.tasks)..where((t) => t.resolveMutationId.equals(m.mutationId) & t.status.equals('open'))).write(
        const TasksCompanion(status: Value('resolve_requested')),
      );
    }
  }
}

/// One entry of a task's history.
class TaskEvent {
  const TaskEvent({required this.type, required this.by, required this.at, this.note});
  final String type;
  final String by;
  final DateTime at;
  final String? note;
}

/// A task on the phone.
class StaffTask {
  const StaffTask(this.row);
  final TaskRow row;

  String get id => row.serverId;
  String get status => row.status;
  bool get isOpen => status == 'open';
  bool get isWaiting => status == 'resolve_requested';
  bool get isResolved => status == 'resolved';
  bool get isCancelled => status == 'cancelled';
  bool get isClosed => isResolved || isCancelled;

  /// Not yet opened by me.
  bool get isNew => row.seenAt == null && !isClosed;

  /// My "done" tap is saved on the phone and waits for the network.
  bool get resolveQueued => row.resolveState == 'queued';
  bool get resolveFailed => row.resolveState == 'failed' && isOpen;

  /// I can say "done" (offline too); once sent, only the office moves it on.
  bool get canRequestResolve => isOpen && !resolveQueued;

  /// What the screen shows: a queued tap reads as "sent to the office" already.
  String get shownStatus => resolveQueued && isOpen ? 'resolve_requested' : status;

  /// The office sent it back with a reason (status is open again).
  bool get wasRejected => isOpen && (row.decisionNote?.isNotEmpty ?? false);

  /// Due date passed (Dhaka business date, compared as text) and still not done.
  bool isOverdue(String today) => !isClosed && !isWaiting && row.dueDate != null && row.dueDate!.compareTo(today) < 0;

  List<TaskEvent> get events {
    try {
      final list = jsonDecode(row.eventsJson) as List<dynamic>;
      return [
        for (final e in list)
          if (e is Map<String, dynamic> && e['at'] is String)
            TaskEvent(
              type: (e['type'] as String?) ?? '',
              by: (e['by'] is Map ? (e['by'] as Map)['name'] as String? : null) ?? '',
              at: DateTime.parse(e['at'] as String).toUtc(),
              note: e['note'] as String?,
            ),
      ];
    } on FormatException {
      return const [];
    }
  }
}

/// Sort: what needs me first (overdue, then by due date), finished ones last.
int compareTasks(StaffTask a, StaffTask b, String today) {
  int rank(StaffTask t) => t.isClosed
      ? 3
      : t.isWaiting
          ? 2
          : t.isOverdue(today)
              ? 0
              : 1;
  final r = rank(a).compareTo(rank(b));
  if (r != 0) return r;
  if (!a.isClosed) {
    final ad = a.row.dueDate, bd = b.row.dueDate;
    if (ad != null && bd != null && ad != bd) return ad.compareTo(bd);
    if (ad != null && bd == null) return -1;
    if (ad == null && bd != null) return 1;
  }
  return b.row.createdAt.compareTo(a.row.createdAt);
}

/// All my tasks, in the order described above.
final tasksProvider = StreamProvider<List<StaffTask>>((ref) {
  final db = ref.watch(databaseProvider);
  final clock = ref.read(clockProvider);
  return db.select(db.tasks).watch().map((rows) {
    final today = clock.businessDate();
    final all = [for (final r in rows) StaffTask(r)]..sort((a, b) => compareTasks(a, b, today));
    return all;
  });
});

final taskProvider = StreamProvider.family<StaffTask?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.tasks)..where((t) => t.serverId.equals(id))).watchSingleOrNull().map((r) => r == null ? null : StaffTask(r));
});

/// Still on me: open (also sent back by the office). Badge on Me, card on Today.
final openTasksProvider = Provider<List<StaffTask>>((ref) => [for (final t in ref.watch(tasksProvider).value ?? const <StaffTask>[]) if (t.isOpen) t]);

/// Tasks I have not opened yet.
final newTasksProvider = Provider<List<StaffTask>>((ref) => [for (final t in ref.watch(tasksProvider).value ?? const <StaffTask>[]) if (t.isNew) t]);

class TaskService {
  TaskService(this._ref);
  final Ref _ref;

  /// Opening a task clears its "new" marker. Local only.
  Future<void> markSeen(String id) async {
    final db = _ref.read(databaseProvider);
    final at = _ref.read(clockProvider).nowUtc();
    await (db.update(db.tasks)..where((t) => t.serverId.equals(id) & t.seenAt.isNull())).write(TasksCompanion(seenAt: Value(at)));
  }

  /// "কাজ হয়েছে": saved now, sent when there is a network. Tapping twice is harmless: the
  /// mutation id is made once here and never again, and the server treats a repeat as a replay.
  Future<void> requestResolve(String id, {String? note}) async {
    final db = _ref.read(databaseProvider);
    final at = _ref.read(clockProvider).nowUtc();
    final text = note?.trim();
    var queued = false;
    await db.transaction(() async {
      final row = await (db.select(db.tasks)..where((t) => t.serverId.equals(id))).getSingleOrNull();
      if (row == null || row.status != 'open' || row.resolveState == 'queued') return;
      final mutationId = const Uuid().v7();
      await (db.update(db.tasks)..where((t) => t.serverId.equals(id))).write(TasksCompanion(
        resolveState: const Value('queued'),
        resolveMutationId: Value(mutationId),
        resolveNote: Value(text == null || text.isEmpty ? null : text),
        resolveRequestedAt: Value(at),
        seenAt: Value(row.seenAt ?? at),
      ));
      await _ref.read(outboxWriterProvider).enqueue(
        mutationId: mutationId,
        entity: 'task_resolve_request',
        payload: {
          'taskId': id,
          if (text != null && text.isNotEmpty) 'note': text,
          'requestedAt': at.toIso8601String(),
        },
      );
      queued = true;
    });
    if (queued) unawaited(_ref.read(syncEngineProvider).kick(reason: 'task'));
  }
}

final taskServiceProvider = Provider<TaskService>(TaskService.new);
