/// Who did this month's work on a customer (FR-M-068, owner request 2026-11-23): the visit, the payment and the
/// promise lines of the customer page say who did each. Pure rules, no I/O.
///
/// Only names already on the phone are used: a visit made on this phone (the user), a colleague's visit
/// (`colleague_activities.staff_name`), the ERP payment's `collectorName` (contract 1.13.0) and the promise's
/// `createdByName` (1.31.0). A name the phone does not have stays null and nothing is shown for it.
library;

import '../../../../core/time/clock.dart';

class MonthPeople {
  const MonthPeople({this.visitBy, this.paidBy = const [], this.promiseBy});
  static const none = MonthPeople();

  /// Who made the latest visit of the month.
  final String? visitBy;

  /// The collectors (or, for an office payment, the person the ERP recorded) of this month's ERP payments,
  /// newest first, each once.
  final List<String> paidBy;

  /// Who took the open promise.
  final String? promiseBy;
}

String? _clean(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();

/// The maker of an open promise: its `createdByName`; a promise row of this phone without one was made by the
/// user ([myName]); otherwise a colleague's promise from the colleague activity.
String? promiseMakerName({required bool ownRow, required String? createdByName, required String? colleagueName, required String? myName}) =>
    _clean(createdByName) ?? (ownRow ? _clean(myName) : null) ?? _clean(colleagueName);

/// [today] is the Dhaka business date; visit instants are compared as Dhaka dates (the month of a visit at
/// 23:59 on the last day is that month).
MonthPeople monthPeopleOf({
  required String today,
  required String? myName,
  required List<({DateTime at, String? userName, bool byMe})> myVisits,
  required List<({DateTime at, String name})> colleagueVisits,
  required List<String?> paymentCollectors,
  required String? promiseBy,
}) {
  final month = today.substring(0, 7);
  bool inMonth(DateTime at) => businessDateOf(at).startsWith(month);
  ({DateTime at, String? name})? latest;
  for (final v in myVisits) {
    if (!inMonth(v.at)) continue;
    final name = _clean(v.userName) ?? (v.byMe ? _clean(myName) : null);
    if (latest == null || v.at.isAfter(latest.at)) latest = (at: v.at, name: name);
  }
  for (final v in colleagueVisits) {
    if (!inMonth(v.at)) continue;
    if (latest == null || v.at.isAfter(latest.at)) latest = (at: v.at, name: _clean(v.name));
  }
  final paid = <String>[];
  for (final c in paymentCollectors) {
    final n = _clean(c);
    if (n != null && !paid.contains(n)) paid.add(n);
  }
  return MonthPeople(visitBy: latest?.name, paidBy: paid, promiseBy: _clean(promiseBy));
}
