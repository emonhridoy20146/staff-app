import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/tasks/src/tasks_data.dart';

import 'helpers.dart';

/// Master FR-TASK-001..005 (contract 1.20.0): a free-form task from the office; the staff member says
/// "done" (works offline), only the office makes it resolved.
void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await h.dispose();
  });

  Future<TaskRow> row(String id) async {
    final db = h.read(databaseProvider);
    return (db.select(db.tasks)..where((t) => t.serverId.equals(id))).getSingle();
  }

  Future<void> sync() => h.read(syncEngineProvider).syncNow();

  test('a task arrives with the next sync, stays "new" until opened, and keeps the office\'s note', () async {
    await h.signIn();
    h.api.addTask('tk-1', title: 'গুদাম থেকে ফ্রিজ আনুন', note: 'সকাল ১০টার মধ্যে। রসিদ সাথে রাখবেন।', dueDate: '2026-11-20');
    await sync();
    var t = await row('tk-1');
    expect(t.title, 'গুদাম থেকে ফ্রিজ আনুন');
    expect(t.note, contains('রসিদ'));
    expect(t.createdByName, 'মোস্তফা কামাল');
    expect(t.status, 'open');
    expect(t.seenAt, isNull);
    expect(StaffTask(t).isNew, isTrue);
    expect(StaffTask(t).events.single.type, 'created');

    await h.read(taskServiceProvider).markSeen('tk-1');
    t = await row('tk-1');
    expect(t.seenAt, isNotNull);
    expect(StaffTask(t).isNew, isFalse);
    // A later change from the office does not make it "new" again.
    h.api.addTask('tk-1', title: 'গুদাম থেকে ফ্রিজ আনুন (সময় বদল)', dueDate: '2026-11-21');
    await sync();
    t = await row('tk-1');
    expect(t.title, contains('সময় বদল'));
    expect(t.seenAt, isNotNull);
  });

  test('"done" is saved offline as one mutation, sent later; the office verifies it', () async {
    await h.signIn();
    h.api.addTask('tk-2', title: 'দোকানে নোটিশ লাগান');
    await sync();

    h.api.offline = true;
    h.clock.advance(const Duration(minutes: 5));
    final at = h.clock.nowUtc();
    await h.read(taskServiceProvider).requestResolve('tk-2', note: '  লাগিয়েছি, ছবি অফিসে দিয়েছি  ');
    await h.read(taskServiceProvider).requestResolve('tk-2', note: 'আবার'); // twice: still one mutation
    var t = await row('tk-2');
    var task = StaffTask(t);
    expect(t.resolveState, 'queued');
    expect(t.resolveNote, 'লাগিয়েছি, ছবি অফিসে দিয়েছি');
    expect(t.resolveRequestedAt!.toUtc(), at);
    expect(task.shownStatus, 'resolve_requested', reason: 'a saved tap already reads as sent to the office');
    expect(task.canRequestResolve, isFalse);
    expect(task.isOpen, isTrue, reason: 'the office has not seen it yet');
    final queued = (await h.read(databaseProvider).select(h.read(databaseProvider).outbox).get()).where((o) => o.entity == 'task_resolve_request').toList();
    expect(queued, hasLength(1));
    final payload = jsonDecode(queued.single.payloadJson) as Map<String, dynamic>;
    expect(payload['taskId'], 'tk-2');
    expect(payload['note'], 'লাগিয়েছি, ছবি অফিসে দিয়েছি');
    expect(payload['requestedAt'], at.toIso8601String());

    // Back online: the mutation goes out once, the server moves the task on, the phone agrees.
    h.api.offline = false;
    h.clock.advance(const Duration(minutes: 20));
    await sync();
    t = await row('tk-2');
    task = StaffTask(t);
    expect(t.resolveState, 'synced');
    expect(t.status, 'resolve_requested');
    expect(task.isWaiting, isTrue);
    expect(task.canRequestResolve, isFalse);
    expect(h.api.appliedPayloads.values.where((p) => p['taskId'] == 'tk-2'), hasLength(1));

    h.api.decideTask('tk-2', decision: 'verified', note: 'ঠিক আছে');
    await sync();
    task = StaffTask(await row('tk-2'));
    expect(task.isResolved, isTrue);
    expect(task.isClosed, isTrue);
    expect(task.row.decisionNote, 'ঠিক আছে');
    expect(task.canRequestResolve, isFalse);
  });

  test('sent back with a reason: it is open again with the reason, and I can say "done" again', () async {
    await h.signIn();
    h.api.addTask('tk-3', title: 'ক্যাশ গুনে জমা দিন');
    await sync();
    await h.read(taskServiceProvider).requestResolve('tk-3');
    await sync();
    expect((await row('tk-3')).status, 'resolve_requested');

    h.api.decideTask('tk-3', decision: 'rejected', note: 'ব্যাংকের স্লিপ নেই');
    await sync();
    var task = StaffTask(await row('tk-3'));
    expect(task.isOpen, isTrue);
    expect(task.wasRejected, isTrue);
    expect(task.row.decisionNote, 'ব্যাংকের স্লিপ নেই');
    expect(task.row.resolveState, 'none');
    expect(task.canRequestResolve, isTrue);

    await h.read(taskServiceProvider).requestResolve('tk-3', note: 'স্লিপ দিয়েছি');
    await sync();
    task = StaffTask(await row('tk-3'));
    expect(task.isWaiting, isTrue);
    expect(task.row.resolveNote, 'স্লিপ দিয়েছি');
    expect(h.api.appliedPayloads.values.where((p) => p['taskId'] == 'tk-3'), hasLength(2));
  });

  test('a task the office cancelled while my "done" was waiting: the phone shows cancelled, not an error', () async {
    await h.signIn();
    h.api.addTask('tk-4', title: 'পুরনো কাজ');
    await sync();
    h.api.offline = true;
    await h.read(taskServiceProvider).requestResolve('tk-4');
    h.api.offline = false;
    h.api.decideTask('tk-4', decision: 'cancelled', note: 'আর দরকার নেই');
    await sync();
    final task = StaffTask(await row('tk-4'));
    expect(task.isCancelled, isTrue);
    expect(task.resolveFailed, isFalse, reason: 'failed only matters while the task is still open');
    expect(task.shownStatus, 'cancelled');
  });

  test('a task the server removes never takes away a "done" that is still waiting to be sent', () async {
    await h.signIn();
    h.api.addTask('tk-5', title: 'কাজ ৫');
    h.api.addTask('tk-6', title: 'কাজ ৬');
    await sync();
    h.api.offline = true;
    await h.read(taskServiceProvider).requestResolve('tk-5');
    final db = h.read(databaseProvider);
    final handler = TaskPullHandler();
    await handler.delete(db, 'tk-5');
    await handler.delete(db, 'tk-6');
    final ids = (await db.select(db.tasks).get()).map((r) => r.serverId);
    expect(ids, contains('tk-5'));
    expect(ids, isNot(contains('tk-6')));
  });

  test('order: overdue first, then by due date, then waiting, finished last; overdue is by Dhaka date', () async {
    await h.signIn();
    final today = h.clock.businessDate(); // 2026-11-15
    expect(today, '2026-11-15');
    h.api.addTask('late', title: 'দেরি', dueDate: '2026-11-14');
    h.api.addTask('soon', title: 'কাছাকাছি', dueDate: '2026-11-16');
    h.api.addTask('far', title: 'দূরে', dueDate: '2026-12-01');
    h.api.addTask('nodate', title: 'তারিখ নেই');
    h.api.addTask('waiting', title: 'অপেক্ষায়', dueDate: '2026-11-10');
    h.api.addTask('done', title: 'শেষ');
    await sync();
    await h.read(taskServiceProvider).requestResolve('waiting');
    h.api.decideTask('done', decision: 'verified');
    await sync();
    final db = h.read(databaseProvider);
    final all = [for (final r in await db.select(db.tasks).get()) StaffTask(r)]..sort((a, b) => compareTasks(a, b, today));
    expect(all.map((t) => t.id), ['late', 'soon', 'far', 'nodate', 'waiting', 'done']);
    expect(all.first.isOverdue(today), isTrue);
    expect(all.firstWhere((t) => t.id == 'soon').isOverdue(today), isFalse);
    expect(all.firstWhere((t) => t.id == 'waiting').isOverdue(today), isFalse, reason: 'it is with the office now');
    expect(all.firstWhere((t) => t.id == 'done').isOverdue(today), isFalse);
  });
}
