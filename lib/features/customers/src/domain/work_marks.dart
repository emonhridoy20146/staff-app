/// Work marks of a customer for the current month (FR-M-038, master
/// FR-CUS-017). Pure rules, no I/O.
///
/// Four marks tell a staff member at a glance, in every filter, what has
/// already been done with a customer: visited, money, promise, map pin. They
/// are worked out on the phone from what it already holds, so they are right
/// the moment a visit or a collection is saved, also offline.
library;

import '../../../../core/time/clock.dart';

enum VisitMark { none, month, today }

/// `paid` = the ERP has a payment dated this month; `pending` = money
/// collected in the field that is not in the ERP yet. Never one number.
enum MoneyMark { none, paid, pending }

enum PromiseMark { none, open }

class WorkMarks {
  const WorkMarks({this.visit = VisitMark.none, this.money = MoneyMark.none, this.promise = PromiseMark.none, this.pin = false});
  final VisitMark visit;
  final MoneyMark money;
  final PromiseMark promise;
  final bool pin;

  /// Nothing done with the customer this month.
  bool get untouched => visit == VisitMark.none && money == MoneyMark.none && promise == PromiseMark.none;
}

/// [today] is the Dhaka business date (`YYYY-MM-DD`); [lastVisitAt] is a UTC
/// instant and is compared as a Dhaka date, so a visit at 23:59 on the last
/// day of a month does not count for the next month.
WorkMarks workMarksOf({
  required String today,
  required DateTime? lastVisitAt,
  required int erpPaidThisMonthPoisha,
  required int pendingFieldPoisha,
  required bool hasOpenPromise,
  required bool hasPin,
}) {
  final visitDate = lastVisitAt == null ? null : businessDateOf(lastVisitAt);
  final month = today.substring(0, 7);
  return WorkMarks(
    visit: visitDate == today
        ? VisitMark.today
        : (visitDate != null && visitDate.startsWith(month) ? VisitMark.month : VisitMark.none),
    money: erpPaidThisMonthPoisha > 0 ? MoneyMark.paid : (pendingFieldPoisha > 0 ? MoneyMark.pending : MoneyMark.none),
    promise: hasOpenPromise ? PromiseMark.open : PromiseMark.none,
    pin: hasPin,
  );
}

/// ERP money per customer for the month of [today], from the ERP payments on
/// the phone: removed (reversed) payments are left out.
Map<String, int> paidThisMonth(Iterable<({String customerId, String date, int amountPoisha, bool reversed})> payments, String today) {
  final month = today.substring(0, 7);
  final out = <String, int>{};
  for (final p in payments) {
    if (p.reversed || !p.date.startsWith(month)) continue;
    out[p.customerId] = (out[p.customerId] ?? 0) + p.amountPoisha;
  }
  return out;
}
