import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

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

class _CustomerMapScreenState extends ConsumerState<CustomerMapScreen> {
  final _map = MapController();
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final cs = Theme.of(context).colorScheme;
    final today = ref.watch(todayProvider);
    final all = ref.watch(allCustomersProvider).value ?? const <Customer>[];
    final pinned = all.where((c) => c.hasPin).toList();
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

    return Scaffold(
      body: Stack(children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 14,
            maxZoom: tiles.maxZoom.toDouble(),
            backgroundColor: cs.surfaceContainer,
            onTap: (_, _) => setState(() => _selected = null),
          ),
          children: [
            if (tilesOn) TileLayer(urlTemplate: tiles.urlTemplate, subdomains: tiles.subdomains, userAgentPackageName: 'bd.howlader.field.staff'),
            MarkerLayer(markers: [
              for (final c in sorted)
                Marker(
                  point: LatLng(c.row.lat!, c.row.lng!),
                  width: 48,
                  height: 48,
                  alignment: Alignment.topCenter,
                  child: _Pin(status: c.primaryStatus(today), selected: c.id == _selected, onTap: () => setState(() => _selected = c.id)),
                ),
              if (fix != null)
                Marker(point: LatLng(fix.lat, fix.lng), width: 28, height: 28, child: const _MeDot()),
            ]),
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
            child: Row(children: [
              Material(
                color: cs.surface,
                elevation: 2,
                borderRadius: const BorderRadius.all(Radius.circular(Radii.full)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s8),
                  child: Text(l.mapPinsCount(f.num(pinned.length)), style: Theme.of(context).textTheme.titleSmall),
                ),
              ),
              const Spacer(),
              SyncChip(onTap: () => context.push('/sync')),
            ]),
          ),
        ),
        if (pinned.isEmpty)
          Center(child: Card(child: Padding(padding: const EdgeInsets.all(Space.s16), child: Text(l.mapNoPins)))),
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
          Positioned(left: Space.screen, right: Space.screen, bottom: Space.screen, child: _Preview(customer: selected)),
      ]),
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
      child: Container(width: 14, height: 14, decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
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
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CustomerTile(customer: customer, onTap: () => context.push('/customers/${customer.id}')),
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.s16, 0, Space.s16, Space.s16),
          child: Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => launchNavigate(customer.row.lat!, customer.row.lng!, customer.nameOf(Localizations.localeOf(context).languageCode)),
                icon: const Icon(Icons.directions_rounded),
                label: Text(l.actionNavigate),
              ),
            ),
            const SizedBox(width: Space.s12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.push('/collect/${customer.id}'),
                icon: const Icon(Icons.payments_rounded),
                label: Text(l.actionCollect),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

