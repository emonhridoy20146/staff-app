import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/attendance/attendance.dart';

import 'helpers.dart';

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await h.dispose();
  });

  test('reinstalled phone: today\'s work-in comes back from the server, staff are on duty, nothing is sent again (FR-M-061)', () async {
    await h.signIn();
    final s = h.read(attendanceServiceProvider);
    final now = h.read(clockProvider).nowUtc();
    h.api.todayAttendanceEvents = [
      {'id': 'e1', 'clientId': '0193a5e2-0000-7000-8000-0000000000e1', 'type': 'work_in', 'at': now.subtract(const Duration(hours: 2)).toIso8601String(), 'source': 'app'},
    ];
    expect(await s.restoreTodayIfMissing(), 1);
    final day = computeDay(await s.watchToday().first, dhakaMidnightUtc: s.dhakaMidnightUtc());
    expect(day.status, DayStatus.onDuty);
    final db = h.read(databaseProvider);
    expect((await db.select(db.outbox).get()).where((o) => o.entity == 'attendance_event'), isEmpty);
    // asked once per day per app run
    expect(await s.restoreTodayIfMissing(), 0);
    expect(h.api.meTodayCalls, 1);
  });

  test('the phone has its own events today: the server is not asked and nothing changes', () async {
    h.api.selfieRequired = false;
    await h.signIn();
    final s = h.read(attendanceServiceProvider);
    await s.record(AttendanceEventType.workIn);
    h.api.todayAttendanceEvents = [
      {'id': 'x', 'clientId': 'other', 'type': 'work_in', 'at': h.read(clockProvider).nowUtc().toIso8601String(), 'source': 'app'},
    ];
    expect(await s.restoreTodayIfMissing(), 0);
    expect(h.api.meTodayCalls, 0);
    final db = h.read(databaseProvider);
    expect((await db.select(db.attendanceEvents).get()).length, 1);
  });

  test('nothing on the server today: still not started', () async {
    await h.signIn();
    final s = h.read(attendanceServiceProvider);
    expect(await s.restoreTodayIfMissing(), 0);
    expect(computeDay(await s.watchToday().first, dhakaMidnightUtc: s.dhakaMidnightUtc()).status, DayStatus.notStarted);
  });
}
