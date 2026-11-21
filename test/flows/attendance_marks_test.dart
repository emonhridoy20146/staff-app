import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/attendance/src/attendance_data.dart';

import 'helpers.dart';

/// FR-M-051 (field-api FR-ATT-010/011, contract 1.25.0): the server's overtime and over-break
/// minutes of a day reach the phone and are marked on the attendance history.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 8}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Map<String, Object?> serverDay(String date, {String status = 'off_duty', int lateMin = 0, int overtimeMin = 0, int overBreakMin = 0}) => {
        'businessDate': date,
        'status': status,
        'firstIn': '${date}T03:00:00Z',
        'lastOut': '${date}T12:40:00Z',
        'breakMin': 60,
        'lateMin': lateMin,
        'overtimeMin': overtimeMin,
        'overBreakMin': overBreakMin,
      };

  test('the pull handler keeps the server\'s overtime and over-break minutes; a day without them reads 0', () async {
    final h = Harness();
    addTearDown(h.dispose);
    await h.signIn();
    final db = h.read(databaseProvider);
    final handler = AttendanceDayPullHandler();
    await handler.upsert(db, 'd-1', serverDay('2026-11-13', lateMin: 40, overtimeMin: 45, overBreakMin: 12));
    await handler.upsert(db, 'd-2', {'businessDate': '2026-11-12', 'status': 'off_duty', 'lateMin': 0, 'breakMin': 30}); // an older server
    final rows = await db.select(db.attendanceDays).get();
    final d1 = rows.firstWhere((r) => r.businessDate == '2026-11-13');
    final d2 = rows.firstWhere((r) => r.businessDate == '2026-11-12');
    expect([d1.lateMin, d1.overtimeMin, d1.overBreakMin], [40, 45, 12]);
    expect([d2.lateMin, d2.overtimeMin, d2.overBreakMin], [0, 0, 0]);
    // the next pull of the same day replaces the marks
    await handler.upsert(db, 'd-1', serverDay('2026-11-13', overtimeMin: 0, overBreakMin: 0));
    final again = (await db.select(db.attendanceDays).get()).firstWhere((r) => r.businessDate == '2026-11-13');
    expect([again.overtimeMin, again.overBreakMin], [0, 0]);
  });

  testWidgets('attendance history: overtime, break over the limit, late and work on a day off are marked in words on their day', (t) async {
    final h = Harness();
    addTearDown(h.dispose);
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    final db = h.read(databaseProvider);
    final handler = AttendanceDayPullHandler();
    await t.runAsync(() async {
      await handler.upsert(db, 'a', serverDay('2026-11-13', lateMin: 40, overtimeMin: 45, overBreakMin: 12));
      await handler.upsert(db, 'b', serverDay('2026-11-12')); // a plain day: no mark
      await handler.upsert(db, 'c', serverDay('2026-11-14', status: 'weekly_off', overtimeMin: 180)); // worked on the off day
    });
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    h.read(routerProvider).go('/attendance');
    await settle(t);

    // Digits stay Latin (the test profile's default); the history sits under the duty card, so scroll to it.
    await t.dragUntilVisible(find.text('উপস্থিতির ইতিহাস'), find.byType(FieldApp), const Offset(0, -200));
    await settle(t);
    await t.dragUntilVisible(find.text('ছুটির দিনে কাজ: 3 ঘ 0 মি'), find.byType(FieldApp), const Offset(0, -200));
    await settle(t);
    // 13 Nov: late, over-break and overtime, each in words with the minutes
    expect(find.text('40 মি দেরি'), findsOneWidget);
    expect(find.text('বিরতি 12 মি বেশি'), findsOneWidget);
    expect(find.text('ওভারটাইম 45 মি'), findsOneWidget);
    // 14 Nov (weekly off): every minute worked is "work on a day off", not "overtime"
    expect(find.text('ছুটির দিনে কাজ: 3 ঘ 0 মি'), findsOneWidget);
    // one of each mark kind for the two days that have them; the plain day has none
    expect(find.byKey(const Key('day-mark-late')), findsOneWidget);
    expect(find.byKey(const Key('day-mark-over_break')), findsOneWidget);
    expect(find.byKey(const Key('day-mark-overtime')), findsNWidgets(2));
  });
}
