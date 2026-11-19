import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/providers.dart';
import '../../../../core/settings/ui_prefs.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/chips.dart';
import '../../../../core/ui/common.dart';
import '../../../../l10n/app_localizations.dart';
import '../customer_providers.dart';
import '../domain/customer.dart';
import 'customer_tile.dart';

String filterLabel(AppLocalizations l, CustomerFilter f) => switch (f) {
      CustomerFilter.all => l.filterAll,
      CustomerFilter.dueToday => l.filterDueToday,
      CustomerFilter.overdue => l.filterOverdue,
      CustomerFilter.promisedToday => l.filterPromisedToday,
      CustomerFilter.mine => l.filterMine,
      CustomerFilter.badSuggested => l.filterBadSuggested,
      CustomerFilter.tagged => l.filterTagged,
      CustomerFilter.noPin => l.filterNoPin,
    };

String sortLabel(AppLocalizations l, CustomerSort s) => switch (s) {
      CustomerSort.distance => l.sortDistance,
      CustomerSort.daysOverdue => l.sortDaysOverdue,
      CustomerSort.amount => l.sortAmount,
      CustomerSort.name => l.sortName,
    };

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});
  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  late final TextEditingController _q = TextEditingController(text: ref.read(customerSearchProvider));

  @override
  void initState() {
    super.initState();
    // Owner request 2026-11-19: opening the tab with no customer on the phone loads them, no tap needed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final all = await ref.read(allCustomersProvider.future);
      if (!mounted || all.isNotEmpty) return;
      final engine = ref.read(syncEngineProvider);
      if (!engine.current.running) await engine.syncNow();
    });
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final filter = ref.watch(customerFilterProvider);
    final sort = ref.watch(customerSortProvider);
    final list = ref.watch(filteredCustomersProvider);
    final all = ref.watch(allCustomersProvider).value ?? const [];
    final today = ref.watch(todayProvider);
    final me = ref.watch(myCustomerUserIdProvider);
    int countFor(CustomerFilter x) => all.where((c) => matchesFilter(c, x, today: today, myUserId: me)).length;
    // Since 1.19.0 the list holds the whole branch: "Mine" appears once someone else's customers are on the phone.
    final showMine = all.any((c) => c.isOthers(me));
    final sync = ref.watch(syncStatusProvider).value ?? ref.read(syncEngineProvider).current;
    // FR-M-032: the list is filled by sync; pull down or the reload button asks for it now (2026-11-19 owner request).
    Future<void> reload() => ref.read(syncEngineProvider).syncNow();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.customersTitle),
        actions: [
          IconButton(tooltip: l.customersReload, icon: const Icon(Icons.refresh_rounded), onPressed: sync.running ? null : reload),
          const SyncChip(),
          const SizedBox(width: Space.s8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.screen, 0, Space.screen, Space.s8),
            child: TextField(
              controller: _q,
              onChanged: (v) => ref.read(customerSearchProvider.notifier).state = v,
              style: t.bodyLarge,
              decoration: InputDecoration(
                hintText: l.customersSearch,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _q.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l.keypadClear,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _q.clear();
                          ref.read(customerSearchProvider.notifier).state = '';
                        },
                      ),
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(Radii.full)), borderSide: BorderSide.none),
                enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(Radii.full)), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(Radii.full)), borderSide: BorderSide(color: cs.primary, width: 2)),
                fillColor: cs.surfaceContainerHigh,
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Space.screen, vertical: Space.s4),
              children: [
                for (final x in CustomerFilter.values.where((x) => x != CustomerFilter.mine || showMine))
                  Padding(
                    padding: const EdgeInsets.only(right: Space.s8),
                    child: FilterChip(
                      selected: filter == x,
                      showCheckmark: false,
                      label: Text(x == CustomerFilter.all ? filterLabel(l, x) : '${filterLabel(l, x)} ${f.num(countFor(x))}'),
                      onSelected: (_) => ref.read(customerFilterProvider.notifier).state = x,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.screen, Space.s4, Space.s4, 0),
            child: Row(
              children: [
                Expanded(child: Text(l.customersCount(f.num(list.value?.length ?? 0)), style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant), overflow: TextOverflow.ellipsis)),
                PopupMenuButton<CustomerSort>(
                  initialValue: sort,
                  onSelected: (s) => ref.read(customerSortProvider.notifier).state = s,
                  itemBuilder: (_) => [for (final s in CustomerSort.values) PopupMenuItem(value: s, child: Text(sortLabel(l, s)))],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s12),
                    child: Row(children: [
                      Icon(Icons.swap_vert_rounded, size: 20, color: cs.primary),
                      const SizedBox(width: Space.s4),
                      Text(sortLabel(l, sort), style: t.labelLarge!.copyWith(color: cs.primary)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          // While the branch is still downloading, say so above the rows that have arrived (owner request 2026-11-19).
          if (sync.phase == SyncPhase.bootstrapping && all.isNotEmpty) _StillLoading(count: f.num(all.length), progress: sync.bootstrapProgress),
          Expanded(
            child: RefreshIndicator(
              onRefresh: reload,
              child: list.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _Scrollable(child: Text(l.errorGeneric)),
                data: (items) => items.isEmpty
                    ? _Scrollable(
                        child: all.isEmpty
                            ? _NothingYet(sync: sync, onReload: reload)
                            : EmptyState(icon: Icons.person_search_rounded, title: l.customersEmpty, body: l.customersEmptyBody),
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(indent: 76, height: 1),
                        itemBuilder: (_, i) => CustomerTile(customer: items[i], onTap: () => context.push('/customers/${items[i].id}')),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lets pull-to-refresh work on an empty list.
class _Scrollable extends StatelessWidget {
  const _Scrollable({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [ConstrainedBox(constraints: BoxConstraints(minHeight: c.maxHeight), child: Center(child: child))],
        ),
      );
}

/// No customer on the phone at all: say whether the first load is running, failed, or not started, and offer a reload.
class _NothingYet extends StatelessWidget {
  const _NothingYet({required this.sync, required this.onReload});
  final SyncStatus sync;
  final Future<void> Function() onReload;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (sync.phase == SyncPhase.bootstrapping) {
      return EmptyState(
        icon: Icons.cloud_download_rounded,
        title: l.customersLoading,
        body: l.customersLoadingBody,
        action: SizedBox(width: 200, child: LinearProgressIndicator(value: sync.bootstrapProgress)),
      );
    }
    final button = FilledButton.icon(onPressed: sync.running ? null : onReload, icon: const Icon(Icons.refresh_rounded), label: Text(l.customersReload));
    final code = sync.lastErrorCode;
    return code != null
        ? EmptyState(icon: Icons.cloud_off_rounded, title: l.customersLoadFailed, body: l.customersLoadFailedBody(code), action: button)
        : EmptyState(icon: Icons.person_search_rounded, title: l.customersNone, body: l.customersNoneBody, action: button);
  }
}

/// Thin banner while the first load (or a reload) is still bringing customers in.
class _StillLoading extends StatelessWidget {
  const _StillLoading({required this.count, required this.progress});
  final String count;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        color: cs.secondaryContainer,
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, Space.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: cs.onSecondaryContainer)),
              const SizedBox(width: Space.s8),
              Expanded(child: Text(l.customersLoadingCount(count), style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: cs.onSecondaryContainer))),
            ]),
            const SizedBox(height: Space.s8),
            LinearProgressIndicator(value: progress),
          ],
        ),
      ),
    );
  }
}
