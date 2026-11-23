import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/customers/src/domain/work_marks.dart';

/// FR-M-038: the four work marks of a customer row for the current Dhaka month.
void main() {
  WorkMarks marks({DateTime? lastVisitAt, int paid = 0, int pending = 0, bool promise = false, bool pin = true, String today = '2026-11-21'}) => workMarksOf(
        today: today,
        lastVisitAt: lastVisitAt,
        erpPaidThisMonthPoisha: paid,
        pendingFieldPoisha: pending,
        hasOpenPromise: promise,
        hasPin: pin,
      );

  test('nothing done this month', () {
    final m = marks();
    expect((m.visit, m.money, m.promise, m.pin), (VisitMark.none, MoneyMark.none, PromiseMark.none, true));
    expect(m.untouched, isTrue);
  });

  test('visit: today, earlier this month, last month; dates are Dhaka dates', () {
    expect(marks(lastVisitAt: DateTime.utc(2026, 11, 21, 4)).visit, VisitMark.today);
    expect(marks(lastVisitAt: DateTime.utc(2026, 11, 3, 4)).visit, VisitMark.month);
    // 31 Oct 23:59 Dhaka = 17:59 UTC: last month
    expect(marks(lastVisitAt: DateTime.utc(2026, 10, 31, 17, 59)).visit, VisitMark.none);
    // 1 Nov 00:00 Dhaka = 31 Oct 18:00 UTC: this month
    expect(marks(lastVisitAt: DateTime.utc(2026, 10, 31, 18)).visit, VisitMark.month);
    // 20 Nov 18:30 UTC is already the 21st in Dhaka
    expect(marks(lastVisitAt: DateTime.utc(2026, 11, 20, 18, 30)).visit, VisitMark.today);
  });

  test('money: ERP money first, else field money still waiting; never mixed', () {
    expect(marks(paid: 50000, pending: 20000).money, MoneyMark.paid);
    expect(marks(pending: 20000).money, MoneyMark.pending);
    expect(marks(pending: 20000).untouched, isFalse);
  });

  test('promise and pin', () {
    expect(marks(promise: true).promise, PromiseMark.open);
    expect(marks(pin: false).pin, isFalse);
  });

  test('ERP money per customer for the month: removed payments and other months are left out', () {
    final m = paidThisMonth([
      (customerId: 'c1', date: '2026-11-02', amountPoisha: 100000, reversed: false),
      (customerId: 'c1', date: '2026-11-18', amountPoisha: 50000, reversed: false),
      (customerId: 'c1', date: '2026-11-19', amountPoisha: 70000, reversed: true),
      (customerId: 'c1', date: '2026-10-31', amountPoisha: 90000, reversed: false),
      (customerId: 'c2', date: '2026-11-01', amountPoisha: 30000, reversed: false),
      (customerId: 'c3', date: '2025-11-05', amountPoisha: 30000, reversed: false),
    ], '2026-11-21');
    expect(m, {'c1': 150000, 'c2': 30000});
  });

  test('invoice totals of the customers in view (FR-M-052): cancelled ones not counted, open = still takes money', () {
    final plans = [
      (customerId: 'a', status: 'active', outstandingPoisha: 5000, kind: 'installment'),
      (customerId: 'a', status: 'closed', outstandingPoisha: 0, kind: 'installment'),
      (customerId: 'a', status: 'cancelled', outstandingPoisha: 900, kind: 'credit'),
      // a cash sale (1.44.0) still owed is `closed`: counted in the total, never open
      (customerId: 'a', status: 'closed', outstandingPoisha: 2000, kind: 'cash'),
      (customerId: 'b', status: 'active', outstandingPoisha: 0, kind: 'installment'), // paid up, still an invoice
      (customerId: 'b', status: 'overdue', outstandingPoisha: 100, kind: 'credit'),
      (customerId: 'c', status: 'active', outstandingPoisha: 100, kind: 'installment'), // not in view
    ];
    expect(invoiceTotals(plans, {'a', 'b'}), (total: 5, open: 2));
    expect(invoiceTotals(plans, {'a'}), (total: 3, open: 1));
    expect(invoiceTotals(plans, {'a', 'b', 'c'}), (total: 6, open: 3));
    expect(invoiceTotals(plans, const {}), (total: 0, open: 0));
    expect(invoiceTotals(const [], {'a'}), (total: 0, open: 0));
  });
}
