import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/customers/src/domain/schedule.dart';

/// FR-M-030: installment lines. `amountPoisha` includes the late fee, so the
/// fee is never added again, and a partly paid line keeps its overdue state.
void main() {
  group('line money', () {
    test('left = amount − paid; the late fee inside the amount is not added twice', () {
      // 5,000 due incl. 200 late fee, 2,000 paid → 3,000 left (not 3,200).
      final m = lineMoney(amountPoisha: 500000, paidPoisha: 200000);
      expect(m.leftPoisha, 300000);
      expect(m.partlyPaid, isTrue);
      expect(m.settled, isFalse);
    });

    test('paid in full, over-paid and negative values stay inside the line', () {
      expect(lineMoney(amountPoisha: 500000, paidPoisha: 500000).settled, isTrue);
      expect(lineMoney(amountPoisha: 500000, paidPoisha: 900000).leftPoisha, 0);
      final none = lineMoney(amountPoisha: 500000, paidPoisha: -5);
      expect(none.paidPoisha, 0);
      expect(none.partlyPaid, isFalse);
    });
  });

  group('line state', () {
    test('a partly paid line past its date stays overdue', () {
      expect(lineState(status: 'overdue', amountPoisha: 500000, paidPoisha: 200000), 'overdue');
    });

    test('a partly paid line of today stays due, a future one is partial', () {
      expect(lineState(status: 'due', amountPoisha: 500000, paidPoisha: 200000), 'due');
      expect(lineState(status: 'partial', amountPoisha: 500000, paidPoisha: 200000), 'partial');
      expect(lineState(status: 'upcoming', amountPoisha: 500000, paidPoisha: 200000), 'partial');
    });

    test('nothing left is paid whatever the stored status says; unknown values are upcoming', () {
      expect(lineState(status: 'overdue', amountPoisha: 500000, paidPoisha: 500000), 'paid');
      expect(lineState(status: 'paid', amountPoisha: 500000, paidPoisha: 0), 'upcoming');
      expect(lineState(status: 'something', amountPoisha: 500000, paidPoisha: 0), 'upcoming');
    });
  });

  test('invoice dues count open lines and only the unpaid part of overdue lines', () {
    final d = planDues([
      (status: 'paid', amountPoisha: 500000, paidPoisha: 500000),
      (status: 'overdue', amountPoisha: 500000, paidPoisha: 200000), // 3,000 left
      (status: 'overdue', amountPoisha: 500000, paidPoisha: 0), // 5,000 left
      (status: 'due', amountPoisha: 500000, paidPoisha: 0),
      (status: 'upcoming', amountPoisha: 500000, paidPoisha: 100000),
    ]);
    expect(d.remainingCount, 4);
    expect(d.overdueCount, 2);
    expect(d.overduePoisha, 800000);

    final clear = planDues([(status: 'paid', amountPoisha: 1, paidPoisha: 1)]);
    expect(clear.remainingCount, 0);
    expect(clear.overduePoisha, 0);
  });
}
