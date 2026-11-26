import 'dart:convert';

import '../../../../core/db/app_database.dart';
import '../../../../core/location/location_engine.dart';
import '../../../../core/text/search_text.dart';
import '../../../../core/theme/status_colors.dart';
import 'bad_tag.dart';
import 'phones.dart';

export '../../../../core/text/search_text.dart' show normalizeSearch, SearchQuery;

/// The newest visit to a customer that the phone holds (the user's own or a colleague's): its outcome and when.
typedef LastVisit = ({String outcome, DateTime at});

/// The later of the user's own newest visit and a colleague's.
LastVisit? latestVisit({LastVisit? own, LastVisit? colleague}) {
  if (own == null || colleague == null) return own ?? colleague;
  return colleague.at.isAfter(own.at) ? colleague : own;
}

/// Read model of a customer for lists, map and Today.
class Customer {
  Customer(this.row, {this.distanceM, this.kinds = InvoiceKinds.none, this.invoiceNos = const [], this.lastVisit});
  final CustomerRow row;

  /// The newest visit on the phone (FR-M-081: a latest visit that says runaway marks the customer).
  final LastVisit? lastVisit;

  /// Distance from the current fix (null when unknown / no pin).
  final int? distanceM;

  /// Open invoices by kind (FR-M-066), counted in the repository's SQL from `plans`.
  final InvoiceKinds kinds;

  /// Invoice numbers of the open invoices, newest sale first (Home row, FR-M-067).
  final List<String> invoiceNos;

  String get id => row.serverId;
  String get code => row.code;
  String nameOf(String lang) => lang == 'en' ? (row.nameEn ?? row.nameBn) : row.nameBn;
  /// The address to show: the ERP address, or when the ERP left it blank its detailed address, or the area
  /// (owner 2026-11-23: a blank ERP address showed the pin icon with nothing beside it). Null when none is known.
  String? get address => _text(row.address) ?? _text(row.detailedAddress) ?? _text(row.areaName);
  String? get areaName => row.areaName;
  bool get hasPin => row.lat != null && row.lng != null && row.locationStatus != 'missing' && row.locationStatus != 'invalid';

  /// A pin the server trusts (`ok` or set by a manager / approved). A swapped
  /// or missing one does not count: a staff map pin then applies at once
  /// under `customers.staffPinApproval = when_missing` (field-api 1.11.0).
  bool get pinUsable => hasPin && (row.locationStatus == 'ok' || row.locationStatus == 'overridden');
  int get outstanding => row.totalOutstandingPoisha;
  int get overdueAmount => row.overduePoisha;
  int? get installment => row.installmentPoisha;
  /// ERP numbers first, then the ones added in the field (FR-M-037).
  List<CustomerPhone> get phoneList => decodePhones(row.phonesJson);
  List<String> get phones => [for (final p in phoneList) p.number];
  bool get tagged => row.tagState == 'tagged';

  /// The bad mark of this customer, or null (FR-M-081): a set tag with severity bad or legal, by its reason,
  /// or a latest visit that says runaway. The rows draw their frame and chip from it.
  late final BadTag? badTag = badTagOf(
    tagState: row.tagState,
    tagSeverity: row.tagSeverity,
    tagReasonCode: row.tagReasonCode,
    lastVisitOutcome: lastVisit?.outcome,
    lastVisitAt: lastVisit?.at,
    lastContactAt: row.lastVisitAt,
  );

  /// The guarantor from the ERP (name and phone), or null when the ERP has
  /// neither. Kept on the phone with the customer, so it shows offline.
  Guarantor? get guarantor => Guarantor.parse(row.guarantorJson);

  /// ERP extras (contract 1.13.0): the ERP's longer address and how to find the house.
  /// Null when it is already shown as [address].
  String? get detailedAddress {
    final d = _text(row.detailedAddress);
    return d == null || d == address ? null : d;
  }

  static String? _text(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
  String? get directions => (row.directions?.trim().isEmpty ?? true) ? null : row.directions;

  /// The ERP's own risk grade, read only (never a FOS tag).
  ErpRisk? get erpRisk => ErpRisk.parse(row.erpRiskJson);

  bool promisedOn(String today) => row.openPromiseDate == today;

  /// Contract 1.19.0: the customer's branch (staff may work in several).
  String? get branchId => row.branchId;
  String? branchName(String lang) {
    final n = lang == 'en' ? (row.branchNameEn ?? row.branchNameBn) : (row.branchNameBn ?? row.branchNameEn);
    return (n == null || n.trim().isEmpty) ? row.branchCode : n;
  }

  String? get assigneeName => row.assigneeName;

  /// Assigned to this user. Without a known user everything counts as theirs.
  bool isMine(String? myUserId) => myUserId == null || row.assigneeId == myUserId;

  /// Someone else's customer in the same branch (staff see the whole branch since 1.19.0).
  bool isOthers(String? myUserId) => myUserId != null && row.assigneeId != null && row.assigneeId != myUserId;

  Customer withDistance(int? d) => Customer(row, distanceM: d, kinds: kinds, invoiceNos: invoiceNos, lastVisit: lastVisit);

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
    final list = ((m['phones'] as List?) ?? const []).whereType<String>().map((p) => p.trim()).where((p) => p.isNotEmpty);
    final phone = (((m['phone'] as String?) ?? '').trim().isNotEmpty ? (m['phone'] as String).trim() : (list.isEmpty ? '' : list.first));
    if (name.isEmpty && phone.isEmpty) return null;
    return Guarantor(name: name, phone: phone);
  }
}

/// The ERP's customer risk snapshot (grade A–E, level Low/Medium/High).
class ErpRisk {
  const ErpRisk({required this.grade, this.level, this.overdueCount = 0, this.maxDaysLate = 0});
  final String grade;
  final String? level;
  final int overdueCount;
  final int maxDaysLate;

  /// low | medium | high | null
  String? get levelKey => switch (level?.toLowerCase()) { 'low' => 'low', 'medium' => 'medium', 'high' => 'high', _ => null };

  static ErpRisk? parse(String? json) {
    if (json == null || json.isEmpty) return null;
    final m = jsonDecode(json);
    if (m is! Map) return null;
    final grade = ((m['grade'] as String?) ?? '').trim();
    if (grade.isEmpty || grade.toUpperCase() == 'N/A') return null;
    return ErpRisk(
      grade: grade,
      level: m['level'] as String?,
      overdueCount: (m['overdueCount'] as num?)?.toInt() ?? 0,
      maxDaysLate: (m['maxDaysLate'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A product on an ERP invoice.
class PlanItem {
  const PlanItem({required this.name, this.model, this.qty = 1, this.serials = const []});
  final String name;
  final String? model;
  final int qty;
  final List<String> serials;

  /// "Walton fridge WFC-3F5 ×2"
  String get label => [name, if (model != null && model!.isNotEmpty) model!, if (qty > 1) '×$qty'].join(' ');
}

List<PlanItem> decodePlanItems(String? json) {
  if (json == null || json.isEmpty) return const [];
  final l = jsonDecode(json);
  if (l is! List) return const [];
  return [
    for (final m in l.whereType<Map<String, dynamic>>())
      if (((m['name'] as String?) ?? '').trim().isNotEmpty)
        PlanItem(
          name: (m['name'] as String).trim(),
          model: m['model'] as String?,
          qty: (m['qty'] as num?)?.toInt() ?? 1,
          serials: ((m['serials'] as List?) ?? const []).whereType<String>().toList(),
        ),
  ];
}

/// Returned (closed), cancelled and settled invoices take no more money.
/// A cash sale (contract 1.44.0) is never collectable, whatever it still shows as owed.
bool isCollectablePlan({required String status, required int outstandingPoisha, String kind = 'installment'}) =>
    !isCashKind(kind) && outstandingPoisha > 0 && status != 'closed' && status != 'cancelled' && status != 'completed';

/// `plans.kind` that is a cash sale: `cash`, and any value this app does not know (contract 1.44.0: "treat
/// unknown values like cash"). A cash plan has no schedule, is `completed` when paid and `closed` when money is
/// still owed, and is never due, overdue, open or collectable.
bool isCashKind(String kind) => kind != 'installment' && kind != 'credit';

/// `paidThisMonth` / `notPaidThisMonth` (FR-M-046): money this month means an
/// ERP payment dated this month or field money still waiting for the ERP,
/// the same rule as the money work mark.
enum CustomerFilter { all, dueToday, overdue, promisedToday, paidThisMonth, notPaidThisMonth, mine, badSuggested, tagged, noPin }

enum CustomerSort { distance, daysOverdue, amount, name }

/// The invoice type of a plan (`plans.kind`): installment (কিস্তি), credit sale (বাকি বিক্রি) or cash sale
/// (নগদ, contract 1.44.0; unknown values count as cash, see [isCashKind]).
enum InvoiceKind { installment, credit, cash }

/// The types the list can filter by (the owner kept the two chips; cash-only customers are in "All").
const filterableKinds = [InvoiceKind.installment, InvoiceKind.credit];

/// `plans.kind` from a contract plan; missing means installment (servers before 1.13.0). Any other value is
/// stored as sent, so a newer server never breaks the phone, and is treated as cash ([isCashKind]).
String planKindOf(Map<String, dynamic> p) {
  final kind = p['kind'];
  return kind is String && kind.trim().isNotEmpty ? kind.trim() : 'installment';
}

/// How many invoices of each kind a customer has (FR-M-066). Installment and credit invoices count while
/// open, the collectable rule ([isCollectablePlan]): something is still owed and the invoice is not returned,
/// cancelled or settled. A cash sale is never open, so it counts while it is not cancelled (its `closed` means
/// money is still owed, not returned). A customer can have several kinds.
class InvoiceKinds {
  const InvoiceKinds({this.installment = 0, this.credit = 0, this.cash = 0});
  static const none = InvoiceKinds();
  final int installment;
  final int credit;
  final int cash;

  int get total => installment + credit + cash;
  bool get isEmpty => total == 0;
  int of(InvoiceKind k) => switch (k) {
        InvoiceKind.installment => installment,
        InvoiceKind.credit => credit,
        InvoiceKind.cash => cash,
      };
  bool has(InvoiceKind k) => of(k) > 0;

  @override
  bool operator ==(Object other) => other is InvoiceKinds && other.installment == installment && other.credit == credit && other.cash == cash;
  @override
  int get hashCode => Object.hash(installment, credit, cash);
}

/// The invoice-type chips (second chip group): null = either kind. Within the
/// group one chip at a time; across groups the filters combine with AND.
bool matchesKind(Customer c, InvoiceKind? kind) => kind == null || c.kinds.has(kind);


/// [paidThisMonth] is ERP money per customer for the month of [today]
/// (`paidThisMonth` in work_marks.dart); without it only field money counts.
bool gaveMoneyThisMonth(Customer c, Map<String, int> paidThisMonth) => (paidThisMonth[c.id] ?? 0) > 0 || c.row.pendingFieldPoisha > 0;

bool matchesFilter(Customer c, CustomerFilter f, {required String today, String? myUserId, Map<String, int> paidThisMonth = const {}}) => switch (f) {
      CustomerFilter.paidThisMonth => gaveMoneyThisMonth(c, paidThisMonth),
      // someone who owes nothing is not "still to pay"
      CustomerFilter.notPaidThisMonth => c.outstanding > 0 && !gaveMoneyThisMonth(c, paidThisMonth),
      CustomerFilter.all => true,
      CustomerFilter.dueToday => c.row.dueToday,
      CustomerFilter.overdue => c.row.daysOverdue > 0,
      CustomerFilter.promisedToday => c.promisedOn(today),
      CustomerFilter.mine => c.isMine(myUserId),
      CustomerFilter.badSuggested => c.row.badSuggested && !c.tagged,
      CustomerFilter.tagged => c.tagged,
      CustomerFilter.noPin => !c.hasPin,
    };

List<Customer> applyQuery(
  List<Customer> all, {
  required String today,
  String search = '',
  CustomerFilter filter = CustomerFilter.all,
  InvoiceKind? kind,
  CustomerSort sort = CustomerSort.daysOverdue,
  String? myUserId,
  Map<String, int> paidThisMonth = const {},
}) {
  final q = SearchQuery(search);
  final out = all
      .where((c) =>
          matchesFilter(c, filter, today: today, myUserId: myUserId, paidThisMonth: paidThisMonth) &&
          matchesKind(c, kind) &&
          q.matches(c.row.searchText))
      .toList();
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
/// Since 1.19.0 the phone holds the whole branch; Today lists the user's own
/// customers and the ones nobody is assigned to, never a colleague's.
/// Customers of the branch picked in the top bar; null = all branches
/// (FR-M-045). One rule for the list, Today, the map and the pickers.
List<Customer> inBranch(List<Customer> all, String? branchId) => branchId == null ? all : [for (final c in all) if (c.branchId == branchId) c];

class TodayPriorities {
  const TodayPriorities({required this.promised, required this.due, required this.overdue});
  final List<Customer> promised;
  final List<Customer> due;
  final List<Customer> overdue;

  bool get isEmpty => promised.isEmpty && due.isEmpty && overdue.isEmpty;
}

TodayPriorities prioritize(List<Customer> everyone, String today, {String? myUserId}) {
  final all = everyone.where((c) => !c.isOthers(myUserId)).toList();
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


/// One ERP payment that went to a schedule line (FR-M-054, contract 1.14.0).
typedef LinePayment = ({String date, int amountPoisha, String? receiptNo});

/// Reads `schedule_lines.payments_json`; empty when the ERP sent none.
List<LinePayment> decodeLinePayments(String? json) {
  if (json == null || json.isEmpty) return const [];
  final raw = jsonDecode(json);
  if (raw is! List) return const [];
  return [
    for (final x in raw)
      if (x is Map && x['date'] is String)
        (date: x['date'] as String, amountPoisha: (x['amountPoisha'] as num?)?.toInt() ?? 0, receiptNo: x['receiptNo'] as String?),
  ];
}
