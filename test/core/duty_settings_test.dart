import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/settings/duty_settings.dart';

/// FR-M-047: the phone follows the duty hours, geofence and cash rule the
/// office set on the server (field-api contract 1.25.0), not built-in values.
void main() {
  // Friday 20 November 2026; 00:00 Dhaka = 18:00 UTC the day before.
  const friday = '2026-11-20';
  final midnight = DateTime.utc(2026, 11, 19, 18);
  DateTime dhaka(int h, int m) => midnight.add(Duration(hours: h, minutes: m));
  const fridayShift = {
    'attendance.defaultShift': {
      'start': '08:30',
      'end': '19:00',
      'weeklyOff': <int>[],
      'lateGraceMin': 10,
      'maxBreakMin': 45,
      'breakWindows': [
        {'weekday': 5, 'start': '12:30', 'end': '15:30'},
      ],
    },
  };

  test('reads the server value; nothing sent: 09:00–21:00, Friday off, 15 and 60 minutes', () {
    final d = DutySettings.of(fridayShift);
    expect([d.start, d.end, d.lateGraceMin, d.maxBreakMin], ['08:30', '19:00', 10, 45]);
    expect(d.weeklyOff, isEmpty);
    expect(d.windowsOn(friday).single.start, '12:30');
    expect(d.windowsOn('2026-11-21'), isEmpty);

    final none = DutySettings.of(const {});
    // no shift data: 09:00–21:00 (owner 2026-11-22)
    expect([none.start, none.end, none.lateGraceMin, none.maxBreakMin], ['09:00', '21:00', 15, 60]);
    expect(none.isWeeklyOff(friday), isTrue);
    expect(none.isWeeklyOff('2026-11-21'), isFalse);
  });

  test('a branch off on Saturday; old flat keys still work; bad values fall back', () {
    final ulania = DutySettings.of(const {
      'attendance.defaultShift': {'start': '09:00', 'end': '18:00', 'weeklyOff': [6]},
    });
    expect(ulania.isWeeklyOff('2026-11-21'), isTrue);
    expect(ulania.isWeeklyOff(friday), isFalse);

    final flat = DutySettings.of(const {'dutyStart': '10:00', 'dutyEnd': '17:00', 'lateGraceMin': 5, 'maxBreakMin': 30});
    expect([flat.start, flat.end, flat.lateGraceMin, flat.maxBreakMin], ['10:00', '17:00', 5, 30]);

    final bad = DutySettings.of(const {
      'attendance.defaultShift': {
        'start': 'nine',
        'end': 18,
        'maxBreakMin': -5,
        'breakWindows': [
          {'weekday': 5, 'start': '15:30', 'end': '12:30'},
          'x',
        ],
      },
    });
    expect([bad.start, bad.end, bad.maxBreakMin], ['09:00', '21:00', 60]);
    expect(bad.breakWindows, isEmpty);
  });

  test('break inside the Friday window is free; the rest is held against the limit', () {
    final d = DutySettings.of(fridayShift);
    int over(List<({DateTime start, DateTime? end})> breaks, {String date = friday, DateTime? now}) =>
        d.overBreakMin(breaks, businessDate: date, dhakaMidnightUtc: midnight, now: now ?? dhaka(20, 0));

    // the whole window
    expect(over([(start: dhaka(12, 30), end: dhaka(15, 30))]), 0);
    // 20 minutes before and 70 after the window: 90 counted, 45 over
    expect(over([(start: dhaka(12, 10), end: dhaka(16, 40))]), 45);
    // tea in the morning and the window
    expect(over([(start: dhaka(10, 0), end: dhaka(10, 20)), (start: dhaka(12, 30), end: dhaka(15, 30))]), 0);
    // a running break is counted up to now
    expect(over([(start: dhaka(16, 0), end: null)], now: dhaka(16, 50)), 5);
    expect(over([(start: dhaka(13, 0), end: null)], now: dhaka(15, 0)), 0);
    // the same three hours on a Saturday have no window
    final saturdayMidnight = midnight.add(const Duration(days: 1));
    expect(
      d.overBreakMin([(start: saturdayMidnight.add(const Duration(hours: 12, minutes: 30)), end: saturdayMidnight.add(const Duration(hours: 15, minutes: 30)))],
          businessDate: '2026-11-21', dhakaMidnightUtc: saturdayMidnight, now: saturdayMidnight.add(const Duration(hours: 20))),
      135,
    );
  });

  test('geofence, cash rule and late days per absent day come from the server keys', () {
    expect(geofenceRadiusOf(const {'collections.geofenceM': 300}), 300);
    expect(geofenceRadiusOf(const {'geofenceRadiusM': 200}), 200);
    expect(geofenceRadiusOf(const {}), 150);

    expect(cashBlocksOverLimit(const {'cash.limitMode': 'block'}), isTrue);
    expect(cashBlocksOverLimit(const {'cash.limitMode': 'warn'}), isFalse);
    expect(cashBlocksOverLimit(const {}), isFalse);

    expect(lateDaysPerAbsentOf(const {}), 2);
    expect(lateDaysPerAbsentOf(const {'attendance.lateDaysPerAbsent': 3}), 3);
    expect([for (final n in [0, 1, 2, 3, 4, 5]) lateAbsencesOf(n, 2)], [0, 0, 1, 1, 2, 2]);
    expect(lateAbsencesOf(9, 0), 0);
  });
}
