import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/time/clock.dart';

void main() {
  test('business date follows Dhaka (+6), not UTC', () {
    // 19:30 UTC on the 14th is 01:30 on the 15th in Dhaka.
    expect(businessDateOf(DateTime.utc(2026, 11, 14, 19, 30)), '2026-11-15');
    expect(businessDateOf(DateTime.utc(2026, 11, 14, 17, 59)), '2026-11-14');
  });

  test('days between business dates', () {
    expect(daysBetween('2026-11-15', '2026-11-22'), 7);
    expect(daysBetween('2026-02-28', '2026-03-01'), 1);
  });

  test('server offset corrects device time', () {
    final c = FixedClock(DateTime.utc(2026, 11, 15, 4));
    c.syncWithServer(DateTime.utc(2026, 11, 15, 4, 10));
    expect(c.nowUtc(), DateTime.utc(2026, 11, 15, 4, 10));
    expect(c.deviceNowUtc(), DateTime.utc(2026, 11, 15, 4));
  });

  test('the last day of a month, also December and a leap February', () {
    expect(lastDayOfMonth('2026-11'), '2026-11-30');
    expect(lastDayOfMonth('2026-12'), '2026-12-31');
    expect(lastDayOfMonth('2026-02'), '2026-02-28');
    expect(lastDayOfMonth('2028-02'), '2028-02-29');
  });
}
