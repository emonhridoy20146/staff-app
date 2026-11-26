import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart' show PromiseRow;
import '../../../core/permissions/permission_service.dart';
import '../../auth/auth.dart';
import '../../customers/customers.dart';
import '../../promises/promises.dart';

/// The filters of the Home work list (FR-M-082). The first four are the list itself: All and its three
/// sections, in priority order, each customer in its first group only. The last two are lenses across the same
/// customers and may overlap the others.
enum HomeFilter { all, promised, due, overdue, badTag, brokenPromise }

/// What Home lists for the customers in view. One object for the summary card's counts, the filter chips and
/// the sections, so their numbers can never disagree.
class HomeWork {
  const HomeWork({required this.priorities, required this.badTag, required this.brokenPromise});
  static const empty = HomeWork(priorities: TodayPriorities(promised: [], due: [], overdue: []), badTag: [], brokenPromise: []);

  /// Promised today, due today, overdue: disjoint, nearest first (FR-M-005).
  final TodayPriorities priorities;

  /// Every customer with a bad mark (FR-M-081), nearest first.
  final List<Customer> badTag;

  /// Every customer with a broken promise nobody has followed up (FR-M-072), nearest first.
  final List<Customer> brokenPromise;

  List<Customer> listOf(HomeFilter f) => switch (f) {
        HomeFilter.all => [...priorities.promised, ...priorities.due, ...priorities.overdue],
        HomeFilter.promised => priorities.promised,
        HomeFilter.due => priorities.due,
        HomeFilter.overdue => priorities.overdue,
        HomeFilter.badTag => badTag,
        HomeFilter.brokenPromise => brokenPromise,
      };

  /// The number on a chip: exactly how many rows that filter shows.
  int count(HomeFilter f) => f == HomeFilter.all ? priorities.promised.length + priorities.due.length + priorities.overdue.length : listOf(f).length;
}

/// Builds the work of [inView] (the customers of the branch picked in the top bar). [scopeUserId] is whose
/// work it is: a field staff member's id (their own and unassigned customers, never a colleague's) or null for
/// everyone in view (a branch or area user).
HomeWork homeWorkOf(List<Customer> inView, String today, {required String? scopeUserId, Set<String> brokenPromiseCustomerIds = const {}}) {
  final scope = [for (final c in inView) if (!c.isOthers(scopeUserId)) c];
  int nearest(Customer a, Customer b) {
    final d = (a.distanceM ?? 1 << 30).compareTo(b.distanceM ?? 1 << 30);
    if (d != 0) return d;
    final o = b.row.daysOverdue.compareTo(a.row.daysOverdue);
    return o != 0 ? o : a.row.nameBn.compareTo(b.row.nameBn);
  }

  return HomeWork(
    priorities: prioritize(inView, today, myUserId: scopeUserId),
    badTag: [for (final c in scope) if (c.badTag != null) c]..sort(nearest),
    brokenPromise: [for (final c in scope) if (brokenPromiseCustomerIds.contains(c.id)) c]..sort(nearest),
  );
}

/// How many quick actions Home shows when [available] can be used (FR-M-083): full rows of three only, so
/// 9, 6 or 3; with fewer than three, what there is. What does not fit stays in Me.
int quickGridCount(int available) => available >= 9 ? 9 : (available >= 6 ? 6 : (available >= 3 ? 3 : available));

/// The filter picked last. Kept while the same user stays signed in (a session, not a setting): signing out
/// or another user starts at All again.
class HomeFilterController extends Notifier<HomeFilter> {
  @override
  HomeFilter build() {
    ref.watch(sessionProvider.select((s) => s.user?.id));
    return HomeFilter.all;
  }

  void pick(HomeFilter f) => state = f;
}

final homeFilterProvider = NotifierProvider<HomeFilterController, HomeFilter>(HomeFilterController.new);

/// The filters offered: Broken promise only while promises are on for this user.
final homeFiltersProvider = Provider<List<HomeFilter>>((ref) {
  final a = ref.watch(accessProvider);
  return [
    HomeFilter.all,
    HomeFilter.promised,
    HomeFilter.due,
    HomeFilter.overdue,
    HomeFilter.badTag,
    if (a.flag('module.promises') && a.can(Perm.promiseView)) HomeFilter.brokenPromise,
  ];
});

/// The Home work list, from the phone's own database (offline): the customers of the picked branch, in the
/// user's scope.
final homeWorkProvider = Provider<AsyncValue<HomeWork>>((ref) {
  final today = ref.watch(todayProvider);
  final scope = ref.watch(homeScopeUserIdProvider);
  final broken = ref.watch(brokenWithoutFollowUpProvider).value ?? const <PromiseRow>[];
  final ids = {for (final p in broken) p.customerId};
  return ref.watch(branchCustomersProvider).whenData((l) => homeWorkOf(l, today, scopeUserId: scope, brokenPromiseCustomerIds: ids));
});
