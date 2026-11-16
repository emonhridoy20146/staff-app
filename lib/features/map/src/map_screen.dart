import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/permissions/permission_service.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/chips.dart';
import '../../../core/ui/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../customers/customers.dart';

/// Map of my customers, pins tinted by status (FR-M-006). Tiles need the
/// network; pins and the preview card work offline.
class CustomerMapScreen extends ConsumerStatefulWidget {
  const CustomerMapScreen({super.key});
  @override
  ConsumerState<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

/// Filters offered on the map / list (multi-select; none = everyone).
const mapFilterOptions = [CustomerFilter.dueToday, CustomerFilter.overdue, CustomerFilter.promisedToday, CustomerFilter.tagged, CustomerFilter.badSuggested];

/// Selected map filters; a customer shows when it matches any of them.
final mapFiltersProvider = StateProvider<Set<CustomerFilter>>((ref) => const {});

/// Map or list view (FR-M-024, owner request 2026-11-16).
final mapListModeProvider = StateProvider<bool>((ref) => false);

/// Customers after the map filters. Works offline: everything is local.
List<Customer> applyMapFilters(List<Customer> all, Set<CustomerFilter> filters, String today) =>
    filters.isEmpty ? all : all.where((c) => filters.any((f) => matchesFilter(c, f, today: today))).toList();

/// Nearest first; customers without a pin go last, then by name.
List<Customer> byDistance(List<Customer> list) => [...list]..sort((a, b) {
    final da = a.distanceM, db = b.distanceM;
    if (da != null && db != null) return da.compareTo(db);
    if (da != null) return -1;
    if (db != null) return 1;
    if (a.hasPin != b.hasPin) return a.hasPin ? -1 : 1;
    return a.row.nameBn.compareTo(b.row.nameBn);
  });

class _CustomerMapScreenState extends ConsumerState<CustomerMapScreen> {
  final _map = MapController();
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final today = ref.watch(todayProvider);
    final everyone = ref.watch(allCustomersProvider).value ?? const <Customer>[];
    final filters = ref.watch(mapFiltersProvider);
    final listMode = ref.watch(mapListModeProvider);
    final all = applyMapFilters(everyone, filters, today);
    final pinned = all.where((c) => c.hasPin).toList();
    final unpinned = everyone.where((c) => !c.hasPin).toList();
    final access = ref.watch(accessProvider);
    final canPropose = access.can(Perm.customerLocationPropose);
    final fix = ref.watch(currentFixProvider).value;
    final tiles = ref.watch(tileConfigProvider);
    final tilesOn = ref.watch(mapTilesEnabledProvider);
    final selected = pinned.where((c) => c.id == _selected).firstOrNull;

    final LatLng center;
    if (fix != null) {
      center = LatLng(fix.lat, fix.lng);
    } else if (pinned.isNotEmpty) {
      center = LatLng(pinned.map((c) => c.row.lat!).reduce((a, b) => a + b) / pinned.length, pinned.map((c) => c.row.lng!).reduce((a, b) => a + b) / pinned.length);
    } else {
      center = const LatLng(22.7010, 90.3535); // Barishal
    }

    // Draw the most urgent pins last so they sit on top.
    final order = {AppStatus.current: 0, AppStatus.paid: 0, AppStatus.dueToday: 2, AppStatus.overdue: 3, AppStatus.promised: 4, AppStatus.tagged: 1};
    final sorted = [...pinned]..sort((a, b) => (order[a.primaryStatus(today)] ?? 0).compareTo(order[b.primaryStatus(today)] ?? 0));

    final controls = _Controls(
      everyone: everyone,
      shown: listMode ? all.length : pinned.length,
      listMode: listMode,
      noPin: unpinned.isNotEmpty && canPropose && !listMode ? _NoPinChip(count: unpinned.length, onTap: () => _showUnpinned(context, unpinned)) : null,
    );

    if (listMode) {
      final list = byDistance(all);
      return Scaffold(
        backgroundColor: cs.surfaceContainerLowest,
        body: SafeArea(
          child: Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(Space.screen, Space.screen, Space.screen, Space.s8), child: controls),
            if (fix == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.screen, 0, Space.screen, Space.s8),
                child: Text(l.mapListNoFix, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
              ),
            Expanded(
              child: list.isEmpty
                  ? Center(child: Padding(padding: const EdgeInsets.all(Space.s24), child: Text(l.mapListEmpty, textAlign: TextAlign.center)))
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: Space.s24),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, indent: Space.screen, endIndent: Space.screen),
                      itemBuilder: (_, i) => CustomerTile(customer: list[i], onTap: () => context.push('/customers/${list[i].id}')),
                    ),
            ),
          ]),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(initialCenter: center, initialZoom: 14, maxZoom: tiles.maxZoom.toDouble(), backgroundColor: cs.surfaceContainer, onTap: (_, _) => setState(() => _selected = null)),
            children: [
              if (tilesOn) TileLayer(urlTemplate: tiles.urlTemplate, subdomains: tiles.subdomains, userAgentPackageName: 'bd.howlader.field.staff'),
              MarkerLayer(
                markers: [
                  for (final c in sorted)
                    Marker(
                      point: LatLng(c.row.lat!, c.row.lng!),
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: _Pin(status: c.primaryStatus(today), selected: c.id == _selected, onTap: () => setState(() => _selected = c.id)),
                    ),
                  if (fix != null) Marker(point: LatLng(fix.lat, fix.lng), width: 28, height: 28, child: const _MeDot()),
                ],
              ),
              if (tilesOn)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(tiles.attribution, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: cs.onSurfaceVariant)),
                  ),
                ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Space.screen),
              child: controls,
            ),
          ),
          if (pinned.isEmpty)
            Center(
              child: Card(
                child: Padding(padding: const EdgeInsets.all(Space.s16), child: Text(filters.isEmpty ? l.mapNoPins : l.mapListEmpty)),
              ),
            ),
          Positioned(
            right: Space.screen,
            bottom: (selected == null ? 0 : 196) + Space.screen,
            child: FloatingActionButton.small(
              heroTag: 'my-location',
              tooltip: l.mapMyLocation,
              onPressed: fix == null ? null : () => _map.move(LatLng(fix.lat, fix.lng), 15),
              child: const Icon(Icons.my_location_rounded),
            ),
          ),
          if (selected != null)
            Positioned(
              left: Space.screen,
              right: Space.screen,
              bottom: Space.screen,
              child: _Preview(customer: selected),
            ),
        ],
      ),
    );
  }
}

/// Top controls shared by map and list: view toggle, count, sync chip,
/// multi-select filters (with counts), and the "without location" chip.
class _Controls extends ConsumerWidget {
  const _Controls({required this.everyone, required this.shown, required this.listMode, this.noPin});
  final List<Customer> everyone;
  final int shown;
  final bool listMode;
  final Widget? noPin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final cs = Theme.of(context).colorScheme;
    final today = ref.watch(todayProvider);
    final filters = ref.watch(mapFiltersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Material(
            color: cs.surface,
            elevation: 2,
            borderRadius: const BorderRadius.all(Radius.circular(Radii.full)),
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(minimumSize: const Size(48, 48), side: BorderSide.none),
              segments: [
                ButtonSegment(value: false, icon: const Icon(Icons.map_rounded), label: Text(l.mapViewMap)),
                ButtonSegment(value: true, icon: const Icon(Icons.view_list_rounded), label: Text(l.mapViewList)),
              ],
              selected: {listMode},
              onSelectionChanged: (s) => ref.read(mapListModeProvider.notifier).state = s.first,
            ),
          ),
          const Spacer(),
          SyncChip(onTap: () => context.push('/sync')),
        ]),
        const SizedBox(height: Space.s8),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              for (final x in mapFilterOptions)
                Padding(
                  padding: const EdgeInsets.only(right: Space.s8),
                  child: FilterChip(
                    elevation: listMode ? 0 : 2,
                    backgroundColor: cs.surface,
                    selected: filters.contains(x),
                    label: Text('${filterLabel(l, x)} ${f.num(everyone.where((c) => matchesFilter(c, x, today: today)).length)}'),
                    onSelected: (on) {
                      final next = {...filters};
                      on ? next.add(x) : next.remove(x);
                      ref.read(mapFiltersProvider.notifier).state = next;
                    },
                  ),
                ),
              if (filters.isNotEmpty)
                ActionChip(
                  elevation: listMode ? 0 : 2,
                  backgroundColor: cs.surface,
                  avatar: const Icon(Icons.close_rounded, size: 18),
                  label: Text(l.mapFilterClear),
                  onPressed: () => ref.read(mapFiltersProvider.notifier).state = const {},
                ),
            ],
          ),
        ),
        const SizedBox(height: Space.s8),
        Material(
          color: cs.surface,
          elevation: listMode ? 0 : 2,
          borderRadius: const BorderRadius.all(Radius.circular(Radii.full)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s8),
            child: Text(listMode ? l.customersCount(f.num(shown)) : l.mapPinsCount(f.num(shown)), style: Theme.of(context).textTheme.titleSmall),
          ),
        ),
        if (noPin != null) ...[const SizedBox(height: Space.s8), noPin!],
      ],
    );
  }
}

extension on _CustomerMapScreenState {
  void _showUnpinned(BuildContext context, List<Customer> unpinned) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scroll) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.screen, 0, Space.screen, Space.s8),
              child: Text(l.mapNoPinTitle, style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: ListView.builder(
                controller: scroll,
                itemCount: unpinned.length,
                itemBuilder: (_, i) => CustomerTile(
                  customer: unpinned[i],
                  onTap: () {
                    Navigator.of(sheet).pop();
                    openPinCorrection(context, unpinned[i].id);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "N without location" — opens the list to set their pins (FR-CUS-008).
class _NoPinChip extends ConsumerWidget {
  const _NoPinChip({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final st = context.semanticColors.warning;
    return Material(
      color: st.bg,
      elevation: 2,
      borderRadius: const BorderRadius.all(Radius.circular(Radii.full)),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.s16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_location_alt_rounded, size: 20, color: st.fg),
                const SizedBox(width: Space.s8),
                Text(l.mapNoPinCount(ref.watch(fmtProvider).num(count)), style: Theme.of(context).textTheme.titleSmall!.copyWith(color: st.fg)),
                const SizedBox(width: Space.s4),
                Icon(Icons.chevron_right_rounded, size: 20, color: st.fg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.status, required this.selected, required this.onTap});
  final AppStatus status;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final st = context.statusColors.of(status);
    final size = selected ? 44.0 : 34.0;
    return Semantics(
      button: true,
      label: statusLabel(AppLocalizations.of(context), status),
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: Motion.fast,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: st.fg,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: selected ? 4 : 3),
              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Icon(statusIcon(status), size: size * 0.5, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _MeDot extends StatelessWidget {
  const _MeDot();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.2), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: cs.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

class _Preview extends ConsumerWidget {
  const _Preview({required this.customer});
  final Customer customer;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Material(
      elevation: 6,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: Radii.brXl,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomerTile(customer: customer, onTap: () => context.push('/customers/${customer.id}')),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.s16, 0, Space.s16, Space.s16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => launchNavigate(customer.row.lat!, customer.row.lng!, customer.nameOf(Localizations.localeOf(context).languageCode)),
                    icon: const Icon(Icons.directions_rounded),
                    label: Text(l.actionNavigate),
                  ),
                ),
                const SizedBox(width: Space.s12),
                Expanded(
                  child: FilledButton.icon(onPressed: () => context.push('/collect/${customer.id}'), icon: const Icon(Icons.payments_rounded), label: Text(l.actionCollect)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
