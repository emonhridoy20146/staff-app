import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/tasks/src/tasks_data.dart';

import 'helpers.dart';

/// The staff side of tasks on screen (FR-TASK-002/003, master) and the "close the app?" question when
/// back is pressed at the root of the signed-in app.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 8}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  /// The app runs its own sync loop inside the test's fake clock, so the office's tasks are
  /// seeded before sign-in (the first snapshot carries them) and not pulled by hand.
  Future<Harness> start(WidgetTester t, {void Function(Harness h)? seed}) async {
    final h = Harness();
    seed?.call(h);
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    return h;
  }

  testWidgets('Today shows the new task, the list and the detail follow, and "done" with a note is saved for the office', (t) async {
    final h = await start(t, seed: (h) => h.api.addTask('tk-1', title: 'গুদাম থেকে ফ্রিজ আনুন', note: 'রসিদ সাথে রাখবেন', dueDate: '2026-11-20'));

    // Today: one open and new task → the banner names the new ones.
    expect(find.textContaining('অফিস থেকে নতুন কাজ'), findsOneWidget);

    // Me → tasks entry with the count.
    await t.tap(find.text('আমি'));
    await settle(t);
    expect(find.text('আমার কাজ'), findsOneWidget);
    await t.tap(find.text('আমার কাজ'));
    await settle(t);
    expect(find.text('গুদাম থেকে ফ্রিজ আনুন'), findsOneWidget);
    expect(find.text('নতুন'), findsOneWidget);
    await t.tap(find.text('গুদাম থেকে ফ্রিজ আনুন'));
    await settle(t);
    expect(find.text('রসিদ সাথে রাখবেন'), findsOneWidget);

    // The first open clears "new".
    final db = h.read(databaseProvider);
    final seen = await t.runAsync(() => (db.select(db.tasks)..where((r) => r.serverId.equals('tk-1'))).getSingle());
    expect(seen!.seenAt, isNotNull);

    // "Done" with a note, no network: saved on the phone, the screen says it will be sent.
    h.api.offline = true;
    await t.tap(find.text('কাজ হয়েছে'));
    await settle(t, rounds: 3);
    expect(find.text('অফিসকে জানান কাজ হয়েছে'), findsOneWidget);
    await t.enterText(find.byType(TextField).last, 'রসিদসহ এনে দিয়েছি');
    await t.tap(find.text('অফিসকে পাঠান'));
    await settle(t);
    expect(find.textContaining('নেটওয়ার্ক পেলে অফিসে যাবে'), findsOneWidget);
    expect(find.text('কাজ হয়েছে'), findsNothing, reason: 'the button is gone once the tap is saved');
    final row = await t.runAsync(() => (db.select(db.tasks)..where((r) => r.serverId.equals('tk-1'))).getSingle());
    expect(row!.resolveState, 'queued');
    expect(row.resolveNote, 'রসিদসহ এনে দিয়েছি');

    // The phone is online again: the office has the request (waiting), then sends it back with a
    // reason. The pull handler applies what the sync delivers.
    Map<String, Object?> server(String status, {String? decisionNote}) => {
          'id': 'tk-1', 'title': 'গুদাম থেকে ফ্রিজ আনুন', 'note': 'রসিদ সাথে রাখবেন', 'dueDate': '2026-11-20', 'status': status,
          'createdBy': {'id': 'u-bm-001', 'name': 'মোস্তফা কামাল'}, 'resolveNote': 'রসিদসহ এনে দিয়েছি', 'resolveRequestedAt': '2026-11-15T04:30:00.000Z',
          'decisionNote': decisionNote, 'events': <Object>[], 'createdAt': '2026-11-15T03:00:00.000Z', 'updatedAt': '2026-11-15T05:00:00.000Z',
        };
    await t.runAsync(() => TaskPullHandler().upsert(db, 'tk-1', server('resolve_requested')));
    await settle(t);
    expect(find.textContaining('অফিস যাচাই করবে'), findsWidgets);
    await t.runAsync(() => TaskPullHandler().upsert(db, 'tk-1', server('open', decisionNote: 'রসিদের ছবি নেই')));
    await settle(t);
    expect(find.textContaining('অফিস ফেরত দিয়েছে: রসিদের ছবি নেই'), findsOneWidget);
    expect(find.text('কাজ হয়েছে'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    await settle(t, rounds: 2);
  });

  testWidgets('back at the root asks before closing the app; "থাকুন" stays', (t) async {
    final h = await start(t);
    h.read(routerProvider).go('/today');
    await settle(t);
    await t.binding.handlePopRoute();
    await settle(t, rounds: 3);
    expect(find.text('অ্যাপ বন্ধ করবেন?'), findsOneWidget);
    await t.tap(find.text('থাকুন'));
    await settle(t, rounds: 3);
    expect(find.text('অ্যাপ বন্ধ করবেন?'), findsNothing);
    expect(find.text('আজ'), findsWidgets, reason: 'still on Today');
    await t.pumpWidget(const SizedBox());
    await settle(t, rounds: 2);
  });
}
