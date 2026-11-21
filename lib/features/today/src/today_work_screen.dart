import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/db/app_database.dart' show ColleagueActivityRow;
import '../../../core/feature/feature_manifest.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/time/clock.dart';
import '../../../core/ui/common.dart';
import '../../../core/ui/money_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../customers/customers.dart';
import 'team_activity.dart';
import 'work_summary.dart';

/// Today's Work (FR-M-041): everything the signed-in user did on one day,
/// latest first: visits, collections, promises, notes, map pins, calls and
/// tasks reported done. Each feature supplies its own entries through the
/// `workLogSources` extension point; this screen only merges and shows them.
/// The arrows go to earlier days. All from the phone's own data (offline).
class TodayWorkScreen extends ConsumerStatefulWidget {
  const TodayWorkScreen({super.key, this.date});

  /// A business date to open on (`YYYY-MM-DD`); today when null.
  final String? date;

  @override
  ConsumerState<TodayWorkScreen> createState() => _TodayWorkState();
}

class _TodayWorkState extends ConsumerState<TodayWorkScreen> {
  final _sources = <String, List<WorkLogEntry>>{};
  final _subs = <StreamSubscription<List<WorkLogEntry>>>[];
  String? _date;
  bool _team = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_date == null) _show(widget.date ?? ref.read(todayProvider));
  }

  void _show(String date) {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _sources.clear();
    _date = date;
    for (final m in ref.read(featureManifestsProvider)) {
      for (final s in m.workLogSources) {
        _subs.add(
          s.watch(context, ref, date).listen((v) {
            if (mounted) setState(() => _sources['${m.name}/${s.id}'] = v);
          }),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    final sc = context.statusColors;
    final lang = Localizations.localeOf(context).languageCode;
    final today = ref.watch(todayProvider);
    final date = _date ?? today;
    final names = {
      for (final c
          in ref.watch(allCustomersProvider).value ?? const <Customer>[])
        c.id: c.nameOf(lang),
    };
    final items = orderWork([for (final v in _sources.values) ...v]);
    final sum = summarizeWork(items);
    final team = _team
        ? (ref.watch(teamActivityProvider(date)).value ?? const [])
        : const <ColleagueActivityRow>[];

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: cs.surfaceContainer,
            title: Text(
              date == today ? l.todayWorkBtn : f.date(date, withYear: true),
            ),
            actions: [
              IconButton(
                tooltip: l.workPrevDay,
                onPressed: () =>
                    setState(() => _show(shiftBusinessDate(date, -1))),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                tooltip: l.workNextDay,
                onPressed: date.compareTo(today) >= 0
                    ? null
                    : () => setState(() => _show(shiftBusinessDate(date, 1))),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                Space.s12,
                Space.screen,
                0,
              ),
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.person_rounded),
                    label: Text(l.workTabMine),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.groups_rounded),
                    label: Text(l.workTabTeam),
                  ),
                ],
                selected: {_team},
                onSelectionChanged: (s) => setState(() => _team = s.first),
              ),
            ),
          ),
          if (_team)
            if (team.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.groups_rounded,
                  title: l.teamEmptyTitle,
                  body: l.teamEmptyBody,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  Space.screen,
                  Space.s16,
                  Space.screen,
                  Space.s32,
                ),
                sliver: SliverList.list(
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (var i = 0; i < team.length; i++) ...[
                            if (i > 0)
                              const Divider(
                                height: 1,
                                indent: Space.s16,
                                endIndent: Space.s16,
                              ),
                            TeamActivityTile(
                              row: team[i],
                              customerName: names[team[i].customerId],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.screen,
                  Space.s12,
                  Space.screen,
                  0,
                ),
                child: Wrap(
                  spacing: Space.s8,
                  runSpacing: Space.s8,
                  children: [
                    _StatChip(
                      icon: Icons.directions_walk_rounded,
                      text: '${l.todayVisits}: ${f.num(sum.visits)}',
                      style: sem.info,
                    ),
                    _StatChip(
                      icon: Icons.payments_rounded,
                      text: '${l.workPosted}: ${f.money(sum.postedPoisha)}',
                      style: sc.of(AppStatus.paid),
                    ),
                    if (sum.pendingPoisha > 0)
                      _StatChip(
                        icon: Icons.cloud_upload_outlined,
                        text:
                            '${l.perfPendingErp}: ${f.money(sum.pendingPoisha)}',
                        style: sc.of(AppStatus.pending),
                      ),
                    if (sum.promises > 0)
                      _StatChip(
                        icon: Icons.handshake_rounded,
                        text: '${l.workPromises}: ${f.num(sum.promises)}',
                        style: sc.of(AppStatus.promised),
                      ),
                  ],
                ),
              ),
            ),
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.work_history_rounded,
                  title: l.workEmptyTitle,
                  body: l.workEmptyBody,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  Space.screen,
                  Space.s16,
                  Space.screen,
                  Space.s32,
                ),
                sliver: SliverList.list(
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (var i = 0; i < items.length; i++) ...[
                            if (i > 0)
                              const Divider(
                                height: 1,
                                indent: Space.s16,
                                endIndent: Space.s16,
                              ),
                            _WorkTile(
                              item: items[i],
                              customerName: items[i].customerId == null
                                  ? null
                                  : names[items[i].customerId],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _WorkTile extends ConsumerWidget {
  const _WorkTile({required this.item, required this.customerName});
  final WorkLogEntry item;
  final String? customerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(fmtProvider);
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    final sc = context.statusColors;
    final style = switch (item.kind) {
      WorkKind.visit => sem.info,
      WorkKind.collection =>
        item.pending ? sc.of(AppStatus.pending) : sc.of(AppStatus.paid),
      WorkKind.promise => sc.of(AppStatus.promised),
      WorkKind.pin => sem.success,
      WorkKind.task => sem.success,
      WorkKind.note || WorkKind.call => StatusStyle(
        fg: cs.onSurfaceVariant,
        bg: cs.surfaceContainerHigh,
      ),
    };
    // an entry's own page (a receipt, a task) comes first; otherwise its customer
    final target =
        item.route ??
        (item.customerId != null ? '/customers/${item.customerId}' : null);
    // The customer's name leads when there is one; what was done follows.
    final lines = [
      if (customerName != null) item.title,
      if (item.subtitle != null && item.subtitle!.isNotEmpty) item.subtitle!,
      if (item.kind == WorkKind.collection && item.pending) l.receiptPendingErp,
      if (item.kind == WorkKind.pin && item.pending) l.pinPending,
    ];
    return ListTile(
      onTap: target == null ? null : () => context.push(target),
      minTileHeight: Sizes.row3,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: style.bg, borderRadius: Radii.brMd),
        child: Icon(item.icon, size: 20, color: style.fg),
      ),
      title: Text(
        customerName ?? item.title,
        style: t.bodyLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: lines.isEmpty
          ? null
          : Text(
              lines.join(' · '),
              style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(f.time(item.at), style: t.labelMedium),
          if (item.amountPoisha != null)
            MoneyText(item.amountPoisha!, style: t.titleSmall!),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.text,
    required this.style,
  });
  final IconData icon;
  final String text;
  final StatusStyle style;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.s12,
        vertical: Space.s8,
      ),
      decoration: BoxDecoration(color: style.bg, borderRadius: Radii.brMd),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: style.fg),
          const SizedBox(width: Space.s4),
          Text(
            text,
            style: t.labelMedium!.copyWith(
              color: style.fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
