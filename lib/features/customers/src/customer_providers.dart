import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/db/app_database.dart';
import '../../../core/location/location_engine.dart';
import '../../../core/providers.dart';
import '../../auth/auth.dart';
import 'data/customer_repository.dart';
import 'domain/customer.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) => CustomerRepository(ref.watch(databaseProvider)));

/// Last known fix, refreshed on demand (distance sorting, Today).
final currentFixProvider = FutureProvider<GeoFix?>((ref) => ref.watch(locationEngineProvider).lastKnown());

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

final customerSearchProvider = StateProvider<String>((ref) => '');
final customerFilterProvider = StateProvider<CustomerFilter>((ref) => CustomerFilter.all);
final customerSortProvider = StateProvider<CustomerSort>((ref) => CustomerSort.daysOverdue);

final filteredCustomersProvider = Provider<AsyncValue<List<Customer>>>((ref) {
  final all = ref.watch(allCustomersProvider);
  final today = ref.watch(todayProvider);
  return all.whenData(
    (l) => applyQuery(
      l,
      today: today,
      search: ref.watch(customerSearchProvider),
      filter: ref.watch(customerFilterProvider),
      sort: ref.watch(customerSortProvider),
      myUserId: ref.watch(myCustomerUserIdProvider),
    ),
  );
});

/// The phone holds customers of more than one branch: rows then show the branch.
final multiBranchProvider = Provider<bool>((ref) {
  final all = ref.watch(allCustomersProvider).value ?? const <Customer>[];
  return all.map((c) => c.branchId).whereType<String>().toSet().length > 1;
});

final todayPrioritiesProvider = Provider<AsyncValue<TodayPriorities>>((ref) {
  final today = ref.watch(todayProvider);
  final me = ref.watch(myCustomerUserIdProvider);
  return ref.watch(allCustomersProvider).whenData((l) => prioritize(l, today, myUserId: me));
});
