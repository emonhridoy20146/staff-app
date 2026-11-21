import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/settings/duty_settings.dart';

/// The duty summary on Today: office end and overtime.
void main() {
  const duty = DutySettings(start: '09:00', end: '18:00');
  // 2026-11-21 00:00 Dhaka (UTC+6) is 2026-11-20 18:00 UTC.
  final midnight = DateTime.utc(2026, 11, 20, 18);
  DateTime dhaka(int h, [int m = 0]) => midnight.add(Duration(hours: h, minutes: m));

  test('office start and end are Dhaka clock times of the business day', () {
    expect(duty.startAt(midnight), dhaka(9));
    expect(duty.endAt(midnight), dhaka(18));
  });

  test('no overtime before work starts or before the office end', () {
    expect(duty.overtimeMin(firstIn: null, lastOut: null, dhakaMidnightUtc: midnight, now: dhaka(20)), 0);
    expect(duty.overtimeMin(firstIn: dhaka(9), lastOut: null, dhakaMidnightUtc: midnight, now: dhaka(17, 59)), 0);
    expect(duty.overtimeMin(firstIn: dhaka(9), lastOut: dhaka(17), dhakaMidnightUtc: midnight, now: dhaka(20)), 0);
  });

  test('still on duty after the office end counts up to now', () {
    expect(duty.overtimeMin(firstIn: dhaka(9), lastOut: null, dhakaMidnightUtc: midnight, now: dhaka(18, 35)), 35);
  });

  test('after work ends overtime stops at the work-out time', () {
    expect(duty.overtimeMin(firstIn: dhaka(9), lastOut: dhaka(19, 10), dhakaMidnightUtc: midnight, now: dhaka(23)), 70);
  });
}
