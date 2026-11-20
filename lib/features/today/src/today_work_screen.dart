import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../core/ui/money_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../collections/collections.dart';
import '../../visits/src/visits.dart' show outcomeLabel, outcomeIcon, parseBusinessDateUtcStart;

final _todayVisitListProvider = StreamProvider<List<VisitRow>>((ref) {
  final db = ref.watch(databaseProvider);
  final start = parseBusinessDateUtcStart(ref.watch(clockProvider).businessDate());
  return (db.select(db.visits)
        ..where((t) => t.checkInAt.isBiggerOrEqualValue(start))
        ..orderBy([(t) => OrderingTerm.asc(t.checkInAt)]))
      .watch();
});

/// Today's activity log: visits + collections, chronological.
class TodayWorkScreen extends ConsumerWidget {
  const TodayWorkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;

    final visits = ref.watch(_todayVisitListProvider).value ?? const [];
    final collections = ref.watch(todayCollectionsProvider).value ?? const [];

    // Merge into a chronological activity list.
    final items = <_ActivityItem>[
      for (final v in visits)
        _ActivityItem(at: v.checkInAt, kind: _ItemKind.visit, customerId: v.customerId, outcome: v.outcome),
      for (final c in collections)
        _ActivityItem(at: c.recordedAt, kind: _ItemKind.collection, customerId: c.customerId, customerName: c.customerName, amountPoisha: c.amountPoisha, receiptNo: c.receiptNo),
    ]..sort((a, b) => a.at.compareTo(b.at));

    // For visits we need customer names — build a map from today's collections (they carry names)
    // and fall back to customerId for visits that have no collection.
    final nameById = {for (final c in collections) c.customerId: c.customerName};

    final visitCount = visits.length;
    final collectionTotal = collections.fold<int>(0, (s, c) => s + c.amountPoisha);

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: cs.surfaceContainer,
          title: Text(l.todayWorkBtn),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Space.screen, 0, Space.screen, Space.s12),
              child: Row(children: [
                _StatChip(
                  icon: Icons.location_on_rounded,
                  label: l.todayVisits,
                  value: f.num(visitCount),
                  bg: sem.info.bg,
                  fg: sem.info.fg,
                ),
                const SizedBox(width: Space.s8),
                _StatChip(
                  icon: Icons.payments_rounded,
                  label: l.todayCollected,
                  value: f.money(collectionTotal),
                  bg: sem.success.bg,
                  fg: sem.success.fg,
                ),
              ]),
            ),
          ),
        ),
        if (items.isEmpty)
          SliverFillRemaining(
            child: EmptyState(icon: Icons.work_history_rounded, title: l.todayAllDone, body: l.todayAllDoneBody),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
            sliver: SliverList.list(children: [
              Card(
                margin: EdgeInsets.zero,
                child: Column(children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: Space.s16, endIndent: Space.s16),
                    _ActivityTile(
                      item: items[i],
                      name: items[i].customerName ?? nameById[items[i].customerId],
                      onTap: () => context.push('/customers/${items[i].customerId}'),
                    ),
                  ],
                ]),
              ),
            ]),
          ),
      ]),
    );
  }
}

enum _ItemKind { visit, collection }

class _ActivityItem {
  const _ActivityItem({
    required this.at,
    required this.kind,
    required this.customerId,
    this.customerName,
    this.outcome,
    this.amountPoisha,
    this.receiptNo,
  });
  final DateTime at;
  final _ItemKind kind;
  final String customerId;
  final String? customerName;
  final String? outcome;
  final int? amountPoisha;
  final String? receiptNo;
}

class _ActivityTile extends ConsumerWidget {
  const _ActivityTile({required this.item, required this.name, required this.onTap});
  final _ActivityItem item;
  final String? name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(fmtProvider);
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;

    final isVisit = item.kind == _ItemKind.visit;
    final bg = isVisit ? sem.info.bg : sem.success.bg;
    final fg = isVisit ? sem.info.fg : sem.success.fg;
    final icon = isVisit ? (item.outcome != null ? outcomeIcon(item.outcome!) : Icons.person_pin_circle_rounded) : Icons.payments_rounded;

    return ListTile(
      onTap: onTap,
      minTileHeight: Sizes.row3,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: bg, borderRadius: Radii.brMd),
        child: Icon(icon, size: 20, color: fg),
      ),
      title: Text(name ?? item.customerId, style: t.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        isVisit ? outcomeLabel(l, item.outcome ?? 'other') : (item.receiptNo ?? ''),
        style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(f.time(item.at), style: t.labelMedium),
          if (!isVisit && item.amountPoisha != null)
            MoneyText(item.amountPoisha!, style: t.titleSmall!),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, required this.value, required this.bg, required this.fg});
  final IconData icon;
  final String label;
  final String value;
  final Color bg, fg;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s8),
      decoration: BoxDecoration(color: bg, borderRadius: Radii.brMd),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: fg),
        const SizedBox(width: Space.s4),
        Text('$label: $value', style: t.labelMedium!.copyWith(color: fg, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
