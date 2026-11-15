import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/attendance/attendance.dart';
import 'package:staff_app/features/collections/src/domain/collection_rules.dart';
import 'package:staff_app/features/tags/tags.dart';

void main() {
  group('collection rules', () {
    test('amount must be positive', () {
      expect(validateCollection(amountPoisha: 0, method: PaymentMethod.cash), CollectionValidation.amountZero);
      expect(validateCollection(amountPoisha: 100, method: PaymentMethod.cash), CollectionValidation.ok);
    });

    test('mobile money needs a valid transaction id', () {
      expect(validateCollection(amountPoisha: 100, method: PaymentMethod.bkash), CollectionValidation.txnMissing);
      expect(validateCollection(amountPoisha: 100, method: PaymentMethod.bkash, txnRef: 'abc'), CollectionValidation.txnInvalid);
      expect(validateCollection(amountPoisha: 100, method: PaymentMethod.bkash, txnRef: ' 9ab3 kd72x1 '), CollectionValidation.ok);
    });

    test('receipt numbers', () {
      expect(formatReceiptNo('BRL01-FS014', '2026-11-15', 7), 'BRL01-FS014-261115-0007');
      expect(formatReceiptNo('BRL01-FS014', '2026-11-15', 3, offline: true), 'BRL01-FS014-261115-OFF003');
    });

    test('cash on hand and warning at 80 %', () {
      expect(cashOnHand(serverOnHand: 820000, unsyncedCash: 150000, unsyncedDeposits: 500000), 470000);
      expect(cashState(3999999, 5000000), CashState.ok);
      expect(cashState(4000000, 5000000), CashState.warning);
      expect(cashState(5000000, 5000000), CashState.exceeded);
      expect(cashState(1, 0), CashState.ok);
    });
  });

  group('attendance', () {
    final midnight = DateTime.utc(2026, 11, 14, 18); // 00:00 Dhaka on the 15th
    DateTime at(int h, int m) => midnight.add(Duration(hours: h, minutes: m));

    test('late is counted after the grace period', () {
      final d = computeDay([AttendanceEventIn(AttendanceEventType.workIn, at(9, 25))], dhakaMidnightUtc: midnight);
      expect(d.status, DayStatus.onDuty);
      expect(d.lateMin, 25);
      final onTime = computeDay([AttendanceEventIn(AttendanceEventType.workIn, at(9, 10))], dhakaMidnightUtc: midnight);
      expect(onTime.lateMin, 0);
    });

    test('breaks are subtracted from duty time', () {
      final d = computeDay([
        AttendanceEventIn(AttendanceEventType.workIn, at(9, 0)),
        AttendanceEventIn(AttendanceEventType.breakStart, at(13, 0)),
        AttendanceEventIn(AttendanceEventType.breakEnd, at(13, 30)),
        AttendanceEventIn(AttendanceEventType.workOut, at(18, 0)),
      ], dhakaMidnightUtc: midnight);
      expect(d.status, DayStatus.offDuty);
      expect(d.breakTotal(at(18, 0)), const Duration(minutes: 30));
      expect(d.dutyTotal(at(20, 0)), const Duration(hours: 8, minutes: 30));
    });
  });

  test('tag reason needs at least 10 characters', () {
    expect(isValidTagReason('short'), isFalse);
    expect(isValidTagReason('  ১০ অক্ষরের বেশি কারণ  '), isTrue);
  });
}
