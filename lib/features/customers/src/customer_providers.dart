import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/db/app_database.dart';
import '../../../core/location/location_engine.dart';
import '../../../core/providers.dart';
import '../../attendance/attendance.dart';
import '../../auth/auth.dart';
import 'data/customer_repository.dart';
import 'domain/customer.dart';
import 'domain/month_people.dart';
import 'domain/work_marks.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) => CustomerRepository(ref.watch(databaseProvider)));

/// Where the phone is, for distances (sorting, Today, map). The phone's last known position first; while the
/// user is on duty (CLAUDE.md §2.6) a fresh foreground fix, then again every [fixRefresh]. Only shown on this
/// phone, never stored or sent. Before 0.12.4 it was read once from the last known position, which Android
/// often does not have, so Today showed no distance (FR-M-005).
final currentFixProvider = StreamProvider<GeoFix?>((ref) {
  final engine = ref.watch(locationEngineProvider);
  final onDuty = ref.watch(todayAttendanceProvider.select((a) {
    final s = a.value?.status;
    return s == DayStatus.onDuty || s == DayStatus.onBreak;
  }));
  final out = StreamController<GeoFix?>();
  Timer? timer;
  var alive = true;
  Future<void> fresh() async {
    final now = await engine.currentFix(timeout: const Duration(seconds: 15));
    if (alive && now != null) out.add(now);
  }

  ref.onDispose(() {
    alive = false;
    timer?.cancel();
    out.close();
  });
  engine.lastKnown().then((f) {
    if (!alive) return;
    out.add(f);
    if (!onDuty) return;
    fresh();
    timer = Timer.periodic(fixRefresh, (_) => fresh());
  });
  return out.stream;
});

/// Owner 2026-11-23: a new fix re-sorts the near-me lists, which looked like the page reloading; at most every
/// 15 minutes. Opening a list or pulling it down still reads a fresh position.
const fixRefresh = Duration(minutes: 15);

/// Business date "today" in Dhaka, server-corrected.
final todayProvider = Provider<String>((ref) => ref.watch(clockProvider).businessDate());

/// The signed-in user's id (whose customers are "mine").
final myCustomerUserIdProvider = Provider<String?>((ref) => ref.watch(sessionProvider.select((s) => s.user?.id)));

final allCustomersProvider = StreamProvider<List<Customer>>((ref) {
  final fix = ref.watch(currentFixProvider).value;
  return ref.watch(customerRepositoryProvider).watchAll().map((l) => withDistances(l, fix));
});

final customerProvider = StreamProvider.family<Customer?, String>((ref, id) {
  final fix = ref.watch(currentFixProvider).value;
  return ref.watch(customerRepositoryProvider).watchOne(id).map((c) {
    if (c == null || fix == null || !c.hasPin) return c;
    return c.withDistance(distanceMeters(fix.lat, fix.lng, c.row.lat!, c.row.lng!));
  });
});

final customerPlansProvider = StreamProvider.family<List<PlanWithSchedule>, String>(
  (ref, id) => ref.watch(customerRepositoryProvider).watchPlans(id),
);

/// Plans (invoices) of a customer that already have an ERP payment today (OD-27).
final plansPaidTodayProvider = StreamProvider.family<Set<String>, String>(
  (ref, id) => ref.watch(customerRepositoryProvider).watchPlansPaidOn(id, ref.watch(todayProvider)),
);

final customerPaymentsProvider = StreamProvider.family<List<ErpPaymentRow>, String>(
  (ref, id) => ref.watch(customerRepositoryProvider).watchPayments(id),
);

/// ERP money per customer this month, for the work marks (FR-M-038).
final paidThisMonthProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(customerRepositoryProvider).watchPaidThisMonth(ref.watch(todayProvider)),
);

/// Invoices of the customers in view (the branch picked in the top bar, or all my
/// branches), for the list header (FR-M-052): all, and those with a balance.
final branchInvoiceTotalsProvider = Provider<({int total, int open})>((ref) {
  final customers = ref.watch(branchCustomersProvider).value ?? const <Customer>[];
  final plans = ref.watch(_planSummariesProvider).value ?? const [];
  return invoiceTotals(plans, {for (final c in customers) c.id});
});

final _planSummariesProvider = StreamProvider<List<({String customerId, String status, int outstandingPoisha, String kind})>>(
  (ref) => ref.watch(customerRepositoryProvider).watchPlanSummaries(),
);

/// The four work marks of one customer: visited, money, promise, map pin.
WorkMarks workMarksFor(WidgetRef ref, Customer c) => workMarksOf(
      today: ref.watch(todayProvider),
      lastVisitAt: c.row.lastVisitAt,
      erpPaidThisMonthPoisha: ref.watch(paidThisMonthProvider.select((m) => m.value?[c.id] ?? 0)),
      pendingFieldPoisha: c.row.pendingFieldPoisha,
      hasOpenPromise: c.row.openPromiseDate != null,
      hasPin: c.hasPin,
    );

final customerSearchProvider = StateProvider<String>((ref) => '');
final customerFilterProvider = StateProvider<CustomerFilter>((ref) => CustomerFilter.all);

/// The invoice-type chip picked on the list (FR-M-066): null = either kind. ANDs with [customerFilterProvider].
final customerKindFilterProvider = StateProvider<InvoiceKind?>((ref) => null);

/// The signed-in user's name in the app language, for "who did it" lines about the user's own work.
final myDisplayNameProvider = Provider<String?>((ref) {
  final lang = ref.watch(languageCodeProvider);
  return ref.watch(sessionProvider.select((s) => s.user?.name.of(lang)));
});

/// Who took each customer's open promise (FR-M-067): {customerId: name}; a customer whose maker is unknown is absent.
final promiseMakersProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(customerRepositoryProvider).watchPromiseMakers(myName: ref.watch(myDisplayNameProvider)),
);

/// Who did this month's visit, payments and promise on one customer (FR-M-068).
final monthPeopleProvider = StreamProvider.family<MonthPeople, String>(
  (ref, id) => ref.watch(customerRepositoryProvider).watchMonthPeople(
        id,
        today: ref.watch(todayProvider),
        myName: ref.watch(myDisplayNameProvider),
        myUserId: ref.watch(myCustomerUserIdProvider),
      ),
);
final customerSortProvider = StateProvider<CustomerSort>((ref) => CustomerSort.daysOverdue);

final filteredCustomersProvider = Provider<AsyncValue<List<Customer>>>((ref) {
  final all = ref.watch(branchCustomersProvider);
  final today = ref.watch(todayProvider);
  return all.whenData(
    (l) => applyQuery(
      l,
      today: today,
      search: ref.watch(customerSearchProvider),
      filter: ref.watch(customerFilterProvider),
      kind: ref.watch(customerKindFilterProvider),
      sort: ref.watch(customerSortProvider),
      myUserId: ref.watch(myCustomerUserIdProvider),
      paidThisMonth: ref.watch(paidThisMonthProvider).value ?? const {},
    ),
  );
});

/// The phone holds customers of more than one branch: rows then show the branch.
final multiBranchProvider = Provider<bool>((ref) {
  final all = ref.watch(allCustomersProvider).value ?? const <Customer>[];
  return all.map((c) => c.branchId).whereType<String>().toSet().length > 1;
});

/// null = all branches (no filter).
final selectedBranchIdProvider = StateProvider<String?>((ref) => null);

/// The customers the user is looking at: those of the branch picked in the
/// top bar, or everyone (FR-M-045). The list, Today, the map and the
/// collect picker all read this, so a branch switch changes them together.
final branchCustomersProvider = Provider<AsyncValue<List<Customer>>>(
  (ref) {
    final branch = ref.watch(selectedBranchIdProvider);
    return ref.watch(allCustomersProvider).whenData((l) => inBranch(l, branch));
  },
);

/// Distinct branches from the customer list: {id: name}.
final branchListProvider = Provider<Map<String, String>>((ref) {
  final all = ref.watch(allCustomersProvider).value ?? const <Customer>[];
  final lang = ref.watch(languageCodeProvider);
  final map = <String, String>{};
  for (final c in all) {
    final bid = c.branchId;
    if (bid != null && !map.containsKey(bid)) {
      map[bid] = c.branchName(lang) ?? bid;
    }
  }
  return map;
});

final todayPrioritiesProvider = Provider<AsyncValue<TodayPriorities>>((ref) {
  final today = ref.watch(todayProvider);
  final me = ref.watch(myCustomerUserIdProvider);
  return ref.watch(branchCustomersProvider).whenData((l) => prioritize(l, today, myUserId: me));
});
