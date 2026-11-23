/// Who did this month's work on a customer (FR-M-068, owner request 2026-11-23): the visit, the payment and the
/// promise lines of the customer page say who did each. Pure rules, no I/O.
///
/// The server's `CustomerActivity` (contract 1.44.0: `visitedBy`, `paidBy`, `promisedBy`, `lastVisitByName`,
/// `lastPaidByName`) comes first, newest name with "+N" for the others. Without it (an older server, or a
/// month the server has not sent yet) the names already on the phone are used: a visit made on this phone
/// (the user), a colleague's visit (`colleague_activities.staff_name`), the ERP payment's referrer or
/// `collectorName`, and the open promise's `createdByName`. A name nobody has stays null and nothing is shown.
library;

import 'dart:convert';

import '../../../../core/time/clock.dart';

/// One "who" on a line: the newest name and how many others did the same this month. [office] = an office
/// payment without a name (contract `source: unknown`), shown as "অফিস".
class Who {
  const Who(this.name, {this.more = 0, this.office = false});
  const Who.office({this.more = 0})
      : name = '',
        office = true;
  final String name;
  final int more;
  final bool office;

  @override
  bool operator ==(Object other) => other is Who && other.name == name && other.more == more && other.office == office;
  @override
  int get hashCode => Object.hash(name, more, office);
  @override
  String toString() => office ? 'office+$more' : '$name+$more';
}

class MonthPeople {
  const MonthPeople({this.visitBy, this.paidBy, this.pendingBy, this.promiseBy});
  static const none = MonthPeople();

  /// Who made the latest visit of the month.
  final Who? visitBy;

  /// Who took this month's ERP money (newest first).
  final Who? paidBy;

  /// Who collected field money this month that is not in the ERP yet. Shown on its own line, never added to paid.
  final Who? pendingBy;

  /// Who took the promise.
  final Who? promiseBy;
}

/// One person of the server's month activity (`ActivityPerson` / `ActivityPayer`, contract 1.44.0).
class ActivityEntry {
  const ActivityEntry({required this.name, this.source, this.pending = false});
  final String name;

  /// `staff` | `erp_referrer` | `collector_name` | `unknown` (payers only).
  final String? source;
  final bool pending;

  bool get office => source == 'unknown' || name.trim().isEmpty;
}

/// The server's `CustomerActivity` as stored in `customers.activity_json`.
class ServerActivity {
  const ServerActivity({
    required this.month,
    this.lastVisitByName,
    this.lastPaidByName,
    this.rowLastVisitByName,
    this.visitedBy = const [],
    this.paidBy = const [],
    this.promisedBy = const [],
  });
  final String? month;
  final String? lastVisitByName;
  final String? lastPaidByName;

  /// Who made the visit at the customer's `lastVisitAt`, whatever the month (`CustomerListItem.lastVisitByName`).
  final String? rowLastVisitByName;
  final List<ActivityEntry> visitedBy;
  final List<ActivityEntry> paidBy;
  final List<ActivityEntry> promisedBy;

  static ServerActivity? parse(String? json) {
    if (json == null || json.isEmpty) return null;
    final m = jsonDecode(json);
    if (m is! Map) return null;
    List<ActivityEntry> people(Object? raw) => [
          for (final x in (raw is List ? raw : const []))
            if (x is Map)
              ActivityEntry(
                name: ((x['name'] as String?) ?? '').trim(),
                source: x['source'] as String?,
                pending: x['pending'] == true,
              ),
        ];
    return ServerActivity(
      month: m['month'] as String?,
      lastVisitByName: _clean(m['lastVisitByName'] as String?),
      lastPaidByName: _clean(m['lastPaidByName'] as String?),
      rowLastVisitByName: _clean(m['rowLastVisitByName'] as String?),
      visitedBy: [for (final e in people(m['visitedBy'])) if (e.name.isNotEmpty) e],
      paidBy: people(m['paidBy']),
      promisedBy: [for (final e in people(m['promisedBy'])) if (e.name.isNotEmpty) e],
    );
  }
}

/// What the customer pull stores in `customers.activity_json` (1.44.0): the `activity` object, plus the list
/// row's `lastVisitByName` as `rowLastVisitByName`. That one names the visit at `lastVisitAt` in any month, so it
/// is kept apart from the month's own names. Null when the server sent neither.
String? encodeActivity(Map<String, dynamic> customer) {
  final activity = customer['activity'];
  final rowName = customer['lastVisitByName'];
  if (activity is! Map && rowName == null) return null;
  final out = <String, dynamic>{...(activity is Map ? activity.cast<String, dynamic>() : const <String, dynamic>{})};
  if (rowName != null) out['rowLastVisitByName'] = rowName;
  return jsonEncode(out);
}

String? _clean(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();

Who? _newest(List<ActivityEntry> list) {
  if (list.isEmpty) return null;
  final first = list.first;
  return first.office ? Who.office(more: list.length - 1) : Who(first.name, more: list.length - 1);
}

Who? _who(String? name) => _clean(name) == null ? null : Who(_clean(name)!);

/// The maker of an open promise: its `createdByName`; a promise row of this phone without one was made by the
/// user ([myName]); otherwise a colleague's promise from the colleague activity.
String? promiseMakerName({required bool ownRow, required String? createdByName, required String? colleagueName, required String? myName}) =>
    _clean(createdByName) ?? (ownRow ? _clean(myName) : null) ?? _clean(colleagueName);

/// The name a payment on the phone stands for: an office payment names its ERP referrer first, a field payment
/// its collector first (contract 1.44.0 `referrerName`, 1.13.0 `collectorName`).
String? paymentPersonName({required String source, required String? referrerName, required String? collectorName}) =>
    source == 'office' ? (_clean(referrerName) ?? _clean(collectorName)) : (_clean(collectorName) ?? _clean(referrerName));

/// [today] is the Dhaka business date; visit instants are compared as Dhaka dates (the month of a visit at
/// 23:59 on the last day is that month). [server] is used only when it is for this month.
MonthPeople monthPeopleOf({
  required String today,
  required String? myName,
  required List<({DateTime at, String? userName, bool byMe})> myVisits,
  required List<({DateTime at, String name})> colleagueVisits,
  required List<String?> paymentPeople,
  required String? promiseBy,
  ServerActivity? server,
}) {
  final month = today.substring(0, 7);
  final s = server != null && server.month == month ? server : null;

  // Visit: the server's list, else its last visitor, else the latest visit on the phone.
  var visit = s == null ? null : (_newest(s.visitedBy) ?? _who(s.lastVisitByName));
  if (visit == null) {
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
    // Last, the name of the customer's latest visit. The visit line only shows a name when that visit is in
    // this month, so it never names last month's visitor.
    visit = _who(latest?.name) ?? _who(server?.rowLastVisitByName);
  }

  // Paid: the server's payers in the ERP, else the people of this month's ERP payments on the phone.
  Who? paid;
  Who? pending;
  if (s != null && s.paidBy.isNotEmpty) {
    paid = _newest([for (final p in s.paidBy) if (!p.pending) p]);
    pending = _newest([for (final p in s.paidBy) if (p.pending) p]);
  } else {
    final names = <String>[];
    for (final c in paymentPeople) {
      final n = _clean(c);
      if (n != null && !names.contains(n)) names.add(n);
    }
    paid = names.isEmpty ? (s == null ? null : _who(s.lastPaidByName)) : Who(names.first, more: names.length - 1);
  }

  final promise = (s == null ? null : _newest(s.promisedBy)) ?? _who(promiseBy);
  return MonthPeople(visitBy: visit, paidBy: paid, pendingBy: pending, promiseBy: promise);
}
