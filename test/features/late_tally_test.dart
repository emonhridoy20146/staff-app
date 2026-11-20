import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/attendance/src/attendance_domain.dart';

/// FR-M-040: every two late days in a month count as one absent day.
void main() {
  final days = [
    (date: '2026-11-02', lateMin: 12),
    (date: '2026-11-03', lateMin: 0),
    (date: '2026-11-10', lateMin: 5),
    (date: '2026-11-11', lateMin: 40),
    (date: '2026-11-20', lateMin: 1),
    (date: '2026-11-21', lateMin: 9),
    (date: '2026-10-30', lateMin: 30),
    (date: '2026-10-31', lateMin: 30),
  ];

  test('the 2nd and 4th late day of the month count as absent days; they need not be next to each other', () {
    final t = lateTally(days, month: '2026-11');
    expect(t.lateDays, 5);
    expect(t.absences, 2);
    expect(t.absenceDates, {'2026-11-10', '2026-11-20'});
  });

  test('months are counted apart and the order of the rows does not matter', () {
    expect(lateTally(days.reversed, month: '2026-10').absenceDates, {'2026-10-31'});
    expect(lateTally(days.reversed, month: '2026-11').absenceDates, {'2026-11-10', '2026-11-20'});
    expect(lateTally(days, month: '2026-09').lateDays, 0);
  });

  test('one late day is a warning only; the pair size can change', () {
    final one = lateTally([(date: '2026-11-02', lateMin: 3)], month: '2026-11');
    expect((one.lateDays, one.absences), (1, 0));
    expect(lateTally(days, month: '2026-11', latePerAbsence: 3).absenceDates, {'2026-11-11'});
    expect(lateTally(days, month: '2026-11', latePerAbsence: 0).absences, 0);
  });
}
