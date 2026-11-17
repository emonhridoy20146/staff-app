import 'dart:convert';

import '../../../../core/db/app_database.dart';
import '../../../../core/location/location_engine.dart';
import '../../../../core/theme/status_colors.dart';

/// Read model of a customer for lists, map and Today.
class Customer {
  Customer(this.row, {this.distanceM});
  final CustomerRow row;

  /// Distance from the current fix (null when unknown / no pin).
  final int? distanceM;

  String get id => row.serverId;
  String get code => row.code;
  String nameOf(String lang) => lang == 'en' ? (row.nameEn ?? row.nameBn) : row.nameBn;
  String? get address => row.address;
  String? get areaName => row.areaName;
  bool get hasPin => row.lat != null && row.lng != null && row.locationStatus != 'missing' && row.locationStatus != 'invalid';

  /// A pin the server trusts (`ok` or set by a manager / approved). A swapped
  /// or missing one does not count: a staff map pin then applies at once
  /// under `customers.staffPinApproval = when_missing` (field-api 1.11.0).
  bool get pinUsable => hasPin && (row.locationStatus == 'ok' || row.locationStatus == 'overridden');
  int get outstanding => row.totalOutstandingPoisha;
  int get overdueAmount => row.overduePoisha;
  int? get installment => row.installmentPoisha;
  List<String> get phones => (jsonDecode(row.phonesJson) as List).cast<String>();
  bool get tagged => row.tagState == 'tagged';

  /// The guarantor from the ERP (name and phone), or null when the ERP has
  /// neither. Kept on the phone with the customer, so it shows offline.
  Guarantor? get guarantor => Guarantor.parse(row.guarantorJson);

  bool promisedOn(String today) => row.openPromiseDate == today;

  Customer withDistance(int? d) => Customer(row, distanceM: d);

  /// Badges in display order (max 2 shown in a tile).
  List<AppStatus> badges(String today) => [
        if (tagged) AppStatus.tagged,
        if (promisedOn(today)) AppStatus.promised,
        if (row.dueToday) AppStatus.dueToday,
        if (row.daysOverdue > 0) AppStatus.overdue,
        if (row.badSuggested && !tagged) AppStatus.badSuggested,
        if (outstanding <= 0) AppStatus.paid,
        if (outstanding > 0 && row.daysOverdue == 0 && !row.dueToday && !promisedOn(today)) AppStatus.current,
      ];

  /// Single status used to tint avatar / map pin.
  AppStatus primaryStatus(String today) {
    if (tagged) return AppStatus.tagged;
    if (promisedOn(today)) return AppStatus.promised;
    if (row.dueToday) return AppStatus.dueToday;
    if (row.daysOverdue > 0) return AppStatus.overdue;
    if (outstanding <= 0) return AppStatus.paid;
    return AppStatus.current;
  }
}

/// Guarantor of a customer's plan (ERP data, read only).
class Guarantor {
  const Guarantor({required this.name, required this.phone});
  final String name;
  final String phone;

  bool get canCall => phone.replaceAll(RegExp(r'[^0-9+]'), '').length >= 6;

  static Guarantor? parse(String? json) {
    if (json == null || json.isEmpty) return null;
    final m = jsonDecode(json);
    if (m is! Map) return null;
    final name = ((m['name'] as String?) ?? '').trim();
    final phone = ((m['phone'] as String?) ?? '').trim();
    if (name.isEmpty && phone.isEmpty) return null;
    return Guarantor(name: name, phone: phone);
  }
}

enum CustomerFilter { all, dueToday, overdue, promisedToday, mine, badSuggested, tagged, noPin }

enum CustomerSort { distance, daysOverdue, amount, name }

/// Normalises text for search: lower-case, Bangla digits → Latin, no
/// punctuation. Applied to name bn/en, code, phones, address.
String normalizeSearch(String s) {
  final b = StringBuffer();
  for (final r in s.toLowerCase().runes) {
    final d = r - 0x09E6;
    if (d >= 0 && d <= 9) {
      b.writeCharCode(0x30 + d);
    } else if (r == 0x20 || r >= 0x30) {
      b.writeCharCode(r);
    }
  }
  return b.toString().replaceAll(RegExp(r'[\-\.,/]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool matchesFilter(Customer c, CustomerFilter f, {required String today, String? myUserId}) => switch (f) {
      CustomerFilter.all => true,
      CustomerFilter.dueToday => c.row.dueToday,
      CustomerFilter.overdue => c.row.daysOverdue > 0,
      CustomerFilter.promisedToday => c.promisedOn(today),
      CustomerFilter.mine => myUserId == null || c.row.assigneeId == myUserId,
      CustomerFilter.badSuggested => c.row.badSuggested && !c.tagged,
      CustomerFilter.tagged => c.tagged,
      CustomerFilter.noPin => !c.hasPin,
    };

List<Customer> applyQuery(
  List<Customer> all, {
  required String today,
  String search = '',
  CustomerFilter filter = CustomerFilter.all,
  CustomerSort sort = CustomerSort.daysOverdue,
  String? myUserId,
}) {
  final q = normalizeSearch(search);
  final out = all.where((c) => matchesFilter(c, filter, today: today, myUserId: myUserId) && (q.isEmpty || c.row.searchText.contains(q))).toList();
  int byName(Customer a, Customer b) => a.row.nameBn.compareTo(b.row.nameBn);
  switch (sort) {
    case CustomerSort.distance:
      out.sort((a, b) {
        final da = a.distanceM ?? 1 << 30, db = b.distanceM ?? 1 << 30;
        return da != db ? da.compareTo(db) : byName(a, b);
      });
    case CustomerSort.daysOverdue:
      out.sort((a, b) => b.row.daysOverdue != a.row.daysOverdue ? b.row.daysOverdue.compareTo(a.row.daysOverdue) : b.outstanding.compareTo(a.outstanding));
    case CustomerSort.amount:
      out.sort((a, b) => b.outstanding.compareTo(a.outstanding));
    case CustomerSort.name:
      out.sort(byName);
  }
  return out;
}

/// Today priorities (FR-M-005): promised today → due today → overdue by
/// distance → others. Each customer appears once, in its first group.
class TodayPriorities {
  const TodayPriorities({required this.promised, required this.due, required this.overdue});
  final List<Customer> promised;
  final List<Customer> due;
  final List<Customer> overdue;

  bool get isEmpty => promised.isEmpty && due.isEmpty && overdue.isEmpty;
}

TodayPriorities prioritize(List<Customer> all, String today) {
  int dist(Customer c) => c.distanceM ?? 1 << 30;
  final promised = all.where((c) => c.promisedOn(today)).toList()..sort((a, b) => dist(a).compareTo(dist(b)));
  final seen = promised.map((c) => c.id).toSet();
  final due = all.where((c) => !seen.contains(c.id) && c.row.dueToday).toList()..sort((a, b) => dist(a).compareTo(dist(b)));
  seen.addAll(due.map((c) => c.id));
  final overdue = all.where((c) => !seen.contains(c.id) && c.row.daysOverdue > 0).toList()
    ..sort((a, b) {
      final d = dist(a).compareTo(dist(b));
      return d != 0 ? d : b.row.daysOverdue.compareTo(a.row.daysOverdue);
    });
  return TodayPriorities(promised: promised, due: due, overdue: overdue);
}

/// Attaches distances from [fix] (straight line).
List<Customer> withDistances(List<Customer> list, GeoFix? fix) {
  if (fix == null) return list;
  return [
    for (final c in list) c.hasPin ? c.withDistance(distanceMeters(fix.lat, fix.lng, c.row.lat!, c.row.lng!)) : c,
  ];
}
