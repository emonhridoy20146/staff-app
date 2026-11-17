import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import 'performance_screen.dart' show reportErrorText;
import 'reports_data.dart';

String metricLabel(AppLocalizations l, LeaderMetric m) => switch (m) {
      LeaderMetric.collected => l.leaderMetricCollected,
      LeaderMetric.visitCredit => l.leaderMetricVisits,
      LeaderMetric.promisesKept => l.leaderMetricPromises,
      LeaderMetric.targetAchievement => l.leaderMetricTarget,
    };

String metricValue(Fmt f, LeaderMetric m, double v) => switch (m) {
      LeaderMetric.collected => f.money(v.round()),
      LeaderMetric.visitCredit => f.dec(v),
      LeaderMetric.promisesKept => f.num(v.round()),
      LeaderMetric.targetAchievement => f.pct(v),
    };

/// My branch's leaderboard (FR-REP-005), only when the admin lets staff
/// see it (`reports.leaderboardVisibleToStaff`; the server answers 403
/// otherwise). Online.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _period = 'month';
  LeaderMetric _metric = LeaderMetric.collected;
  Leaderboard? _data;
  ReportError? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final (data, err) = await ref.read(reportsServiceProvider).leaderboard(period: _period, metric: _metric);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _data = data;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final d = _data;
    return Scaffold(
      appBar: AppBar(title: Text(l.leaderboardTitle)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, Space.s32),
          children: [
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'day', label: Text(l.leaderToday), icon: const Icon(Icons.today_rounded)),
                ButtonSegment(value: 'month', label: Text(l.leaderMonth), icon: const Icon(Icons.calendar_month_rounded)),
              ],
              selected: {_period},
              onSelectionChanged: (s) {
                setState(() => _period = s.first);
                _load();
              },
            ),
            const SizedBox(height: Space.s12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final m in LeaderMetric.values) ...[
                  ChoiceChip(
                    label: Text(metricLabel(l, m)),
                    selected: _metric == m,
                    onSelected: (_) {
                      setState(() => _metric = m);
                      _load();
                    },
                  ),
                  const SizedBox(width: Space.s8),
                ],
              ]),
            ),
            const SizedBox(height: Space.s16),
            if (d == null && _loading)
              const Padding(padding: EdgeInsets.all(Space.s48), child: Center(child: CircularProgressIndicator()))
            else if (d == null)
              EmptyState(
                icon: switch (_error) {
                  ReportError.offline => Icons.wifi_off_rounded,
                  ReportError.hidden => Icons.visibility_off_rounded,
                  _ => Icons.error_outline_rounded,
                },
                title: reportErrorText(l, _error ?? ReportError.failed),
                body: _error == ReportError.hidden ? l.leaderboardHiddenBody : '',
                action: _error == ReportError.hidden ? null : OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh_rounded), label: Text(l.actionRetry)),
              )
            else ...[
              if (d.myRank != null)
                InfoBanner(icon: Icons.emoji_events_rounded, text: l.perfRank(f.num(d.myRank!), f.num(d.of ?? d.ranked.length)))
              else
                InfoBanner(icon: Icons.info_outline_rounded, tone: BannerTone.warning, text: l.leaderNotRankedMe),
              const SizedBox(height: Space.cardGap),
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Column(children: [
                  for (var i = 0; i < d.ranked.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: Space.s16, endIndent: Space.s16),
                    _LeaderTile(row: d.ranked[i], value: metricValue(f, _metric, d.ranked[i].value)),
                  ],
                ]),
              ),
              if (d.unranked.isNotEmpty) ...[
                const SizedBox(height: Space.s16),
                Text(l.leaderNotRanked, style: t.titleSmall!.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: Space.s8),
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(children: [
                    for (var i = 0; i < d.unranked.length; i++) ...[
                      if (i > 0) const Divider(height: 1, indent: Space.s16, endIndent: Space.s16),
                      _LeaderTile(row: d.unranked[i], value: metricValue(f, _metric, d.unranked[i].value)),
                    ],
                  ]),
                ),
              ],
              const SizedBox(height: Space.s12),
              Text(l.leaderFootnote, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}

class _LeaderTile extends ConsumerWidget {
  const _LeaderTile({required this.row, required this.value});
  final LeaderRow row;
  final String value;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final top = row.rank != null && row.rank! <= 3;
    return Container(
      color: row.me ? cs.primaryContainer : null,
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s8),
      child: Row(children: [
        SizedBox(
          width: 40,
          child: row.rank == null
              ? Icon(Icons.remove_rounded, color: cs.onSurfaceVariant)
              : top
                  ? Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: row.rank == 1 ? cs.primary : cs.secondaryContainer),
                      child: Text(f.num(row.rank!), style: AppTheme.tabular(t.titleSmall!).copyWith(color: row.rank == 1 ? cs.onPrimary : cs.onSecondaryContainer, fontWeight: FontWeight.w700)),
                    )
                  : Text(f.num(row.rank!), textAlign: TextAlign.center, style: AppTheme.tabular(t.titleMedium!).copyWith(color: cs.onSurfaceVariant)),
        ),
        const SizedBox(width: Space.s12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(row.me ? l.coworkYou(row.name) : row.name, style: t.bodyLarge!.copyWith(fontWeight: row.me ? FontWeight.w700 : null), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(row.employeeCode, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          ]),
        ),
        Text(value, style: AppTheme.tabular(t.titleMedium!).copyWith(fontWeight: row.me ? FontWeight.w700 : null)),
      ]),
    );
  }
}
