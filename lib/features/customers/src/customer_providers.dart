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

const fixRefresh = Duration(minutes: 2);

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
final customerSortProvider = StateProvider<CustomerSort>((ref) => CustomerSort.daysOverdue);

final filteredCustomersProvider = Provider<AsyncValue<List<Customer>>>((ref) {
  final all = ref.watch(allCustomersProvider);
  final today = ref.watch(todayProvider);
  final selectedBranch = ref.watch(selectedBranchIdProvider);
  return all.whenData(
    (l) {
      final branchFiltered = selectedBranch == null ? l : l.where((c) => c.branchId == selectedBranch).toList();
      return applyQuery(
        branchFiltered,
        today: today,
        search: ref.watch(customerSearchProvider),
        filter: ref.watch(customerFilterProvider),
        sort: ref.watch(customerSortProvider),
        myUserId: ref.watch(myCustomerUserIdProvider),
      );
    },
  );
});

/// The phone holds customers of more than one branch: rows then show the branch.
final multiBranchProvider = Provider<bool>((ref) {
  final all = ref.watch(allCustomersProvider).value ?? const <Customer>[];
  return all.map((c) => c.branchId).whereType<String>().toSet().length > 1;
});

/// null = all branches (no filter).
final selectedBranchIdProvider = StateProvider<String?>((ref) => null);

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
  return ref.watch(allCustomersProvider).whenData((l) => prioritize(l, today, myUserId: me));
});
