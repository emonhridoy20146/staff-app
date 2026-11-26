import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/settings/duty_settings.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/time/clock.dart';
import '../../../core/ui/common.dart';
import '../../../core/ui/money_text.dart';
import '../../../l10n/app_localizations.dart';
import 'reports_data.dart';

String reportErrorText(AppLocalizations l, ReportError e) => switch (e) {
      ReportError.offline => l.reportOffline,
      ReportError.hidden => l.leaderboardHidden,
      ReportError.failed => l.errorGeneric,
    };

/// My month (FR-M-021, FR-REP-005): collected vs target to date, visits
/// (single / co-work / credit), promises kept, attendance, rank and a
/// daily chart. Online, with the last answer kept for offline reading.
class PerformanceScreen extends ConsumerStatefulWidget {
  const PerformanceScreen({super.key});
  @override
  ConsumerState<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends ConsumerState<PerformanceScreen> {
  int _delta = 0; // 0 = this month, -1 = last month …
  MyPerformance? _data;
  ReportError? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String get _month => monthOf(ref.read(clockProvider).businessDate(), delta: _delta);

  Future<void> _load() async {
    setState(() => _loading = true);
    final (data, err) = await ref.read(reportsServiceProvider).myMonth(_month);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _data = data;
      _error = err;
    });
  }

  void _shift(int by) {
    setState(() {
      _delta += by;
      _data = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final d = _data;
    return Scaffold(
      appBar: AppBar(title: Text(l.perfTitle)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, Space.s32),
          children: [
            _MonthSwitcher(
              label: f.month(_month),
              onPrev: _delta > -11 ? () => _shift(-1) : null,
              onNext: _delta < 0 ? () => _shift(1) : null,
            ),
            const SizedBox(height: Space.s8),
            if (d != null && d.fetchedAt != null && _error != null) ...[
              InfoBanner(icon: Icons.cloud_off_rounded, tone: BannerTone.warning, text: l.perfCachedAt(f.dateTime(d.fetchedAt!))),
              const SizedBox(height: Space.cardGap),
            ],
            if (d == null && _loading)
              const Padding(padding: EdgeInsets.all(Space.s48), child: Center(child: CircularProgressIndicator()))
            else if (d == null)
              EmptyState(
                icon: _error == ReportError.offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                title: reportErrorText(l, _error ?? ReportError.failed),
                body: '',
                action: OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh_rounded), label: Text(l.actionRetry)),
              )
            else ...[
              _AmountCard(d: d),
              const SizedBox(height: Space.cardGap),
              _VisitsCard(d: d),
              const SizedBox(height: Space.cardGap),
              _StatsRow(d: d),
              // FR-M-040: every two late days in a month count as one absent day.
              if (d.lateDays > 0) ...[
                const SizedBox(height: Space.cardGap),
                InfoBanner(icon: Icons.warning_amber_rounded, tone: BannerTone.warning, text: l.attHubLateMonth(f.num(d.lateDays), f.num(lateAbsencesOf(d.lateDays, lateDaysPerAbsentOf(ref.watch(serverSettingsProvider)))))),
              ],
              const SizedBox(height: Space.cardGap),
              // FR-M-041: the work of each day of this month.
              OutlinedButton.icon(
                onPressed: () => context.push(_delta == 0 ? '/today-work' : '/today-work?date=${lastDayOfMonth(_month)}'),
                icon: const Icon(Icons.history_rounded),
                label: Text(l.perfWorkHistory),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(Sizes.minTarget)),
              ),
              if (d.rank != null) ...[
                const SizedBox(height: Space.cardGap),
                _RankCard(rank: d.rank!, of: d.rankOf ?? 0, isCurrentMonth: _delta == 0),
              ],
              if (d.days.isNotEmpty) ...[
                const SizedBox(height: Space.cardGap),
                _DailyChart(days: d.days),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _MonthSwitcher extends StatelessWidget {
  const _MonthSwitcher({required this.label, this.onPrev, this.onNext});
  final String label;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(children: [
      IconButton(onPressed: onPrev, tooltip: l.perfPrevMonth, icon: const Icon(Icons.chevron_left_rounded)),
      Expanded(child: Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium)),
      IconButton(onPressed: onNext, tooltip: l.perfNextMonth, icon: const Icon(Icons.chevron_right_rounded)),
    ]);
  }
}

/// Progress bar with the "met" colour at 100 %.
class _Bar extends StatelessWidget {
  const _Bar({required this.ratio, this.height = 10});
  final double ratio;
  final double height;
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(Radii.full)),
        child: LinearProgressIndicator(
          value: ratio.clamp(0.0, 1.0),
          minHeight: height,
          color: ratio >= 1 ? context.semanticColors.success.fg : Theme.of(context).colorScheme.primary,
        ),
      );
}

class _AmountCard extends ConsumerWidget {
  const _AmountCard({required this.d});
  final MyPerformance d;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final hasTarget = d.targetToDatePoisha > 0;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.perfCollected, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          MoneyText(d.collectedPoisha, style: t.headlineMedium!.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          if (hasTarget)
            Text(f.pct(d.amountAchievement), style: AppTheme.tabular(t.titleLarge!).copyWith(color: d.amountAchievement >= 1 ? context.semanticColors.success.fg : cs.primary)),
        ]),
        if (hasTarget) ...[
          const SizedBox(height: Space.s8),
          _Bar(ratio: d.amountAchievement),
          const SizedBox(height: Space.s8),
          Text(l.perfTargetToDate(f.money(d.targetToDatePoisha), f.money(d.targetPoisha)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        ] else
          Text(l.todayNoTarget, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        const Divider(height: Space.s24),
        // Field-recorded money is not official until ERP posts it.
        Row(children: [
          Expanded(child: _KV(label: l.perfPosted, value: f.money(d.postedPoisha))),
          Expanded(child: _KV(label: l.perfPendingErp, value: f.money(d.pendingPoisha), color: context.statusColors.of(AppStatus.pending).fg)),
        ]),
      ]),
    );
  }
}

class _VisitsCard extends ConsumerWidget {
  const _VisitsCard({required this.d});
  final MyPerformance d;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final hasTarget = d.visitTargetToDate > 0;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(l.perfVisitCredit, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant))),
          if (hasTarget) Text(f.pct(d.visitAchievement), style: AppTheme.tabular(t.titleMedium!).copyWith(color: d.visitAchievement >= 1 ? context.semanticColors.success.fg : cs.primary)),
        ]),
        const SizedBox(height: 2),
        Text(
          hasTarget ? l.todayVisitTargetOf(f.dec(d.visitCredit), f.dec(d.visitTargetToDate)) : f.dec(d.visitCredit),
          style: AppTheme.tabular(t.headlineSmall!).copyWith(fontWeight: FontWeight.w700),
        ),
        if (hasTarget) ...[const SizedBox(height: Space.s8), _Bar(ratio: d.visitAchievement, height: 8)],
        const SizedBox(height: Space.s12),
        Row(children: [
          Expanded(child: _KV(label: l.perfSoloVisits, value: f.num(d.soloVisits))),
          Expanded(child: _KV(label: l.perfCoWorkVisits, value: f.num(d.coWorkVisits), color: cs.primary)),
        ]),
      ]),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  const _StatsRow({required this.d});
  final MyPerformance d;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final late = context.statusColors.of(AppStatus.overdue).fg;
    return Row(children: [
      Expanded(child: _Tile(icon: Icons.handshake_rounded, label: l.perfPromisesKept, value: l.perfOf(f.num(d.promisesKept), f.num(d.promisesDue)))),
      const SizedBox(width: Space.s8),
      Expanded(child: _Tile(icon: Icons.event_available_rounded, label: l.perfPresentDays, value: f.num(d.presentDays))),
      const SizedBox(width: Space.s8),
      Expanded(child: _Tile(icon: Icons.schedule_rounded, label: l.perfLateDays, value: f.num(d.lateDays), color: d.lateDays > 0 ? late : null)),
    ]);
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.value, this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(Space.s12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: cs.onSurfaceVariant),
        const SizedBox(height: Space.s4),
        Text(value, style: AppTheme.tabular(t.titleLarge!).copyWith(color: color)),
        Text(label, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant), maxLines: 2),
      ]),
    );
  }
}

class _KV extends StatelessWidget {
  const _KV({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: t.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      Text(value, style: AppTheme.tabular(t.titleMedium!).copyWith(color: color)),
    ]);
  }
}

class _RankCard extends ConsumerWidget {
  const _RankCard({required this.rank, required this.of, required this.isCurrentMonth});
  final int rank;
  final int of;
  final bool isCurrentMonth;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    return AppCard(
      color: cs.primaryContainer,
      padding: EdgeInsets.zero,
      onTap: isCurrentMonth ? () => context.push('/leaderboard') : null,
      child: ListTile(
        minTileHeight: 72,
        leading: Icon(Icons.emoji_events_rounded, color: cs.onPrimaryContainer, size: 32),
        title: Text(l.perfRank(f.num(rank), f.num(of)), style: Theme.of(context).textTheme.titleMedium!.copyWith(color: cs.onPrimaryContainer)),
        subtitle: Text(l.perfRankBy, style: TextStyle(color: cs.onPrimaryContainer)),
        trailing: isCurrentMonth ? Icon(Icons.chevron_right_rounded, color: cs.onPrimaryContainer) : null,
      ),
    );
  }
}

/// Collected per day as bars, with each day's target as a tick. Days off
/// are shown muted. Tokens only; no chart library.
class _DailyChart extends ConsumerWidget {
  const _DailyChart({required this.days});
  final List<PerfDay> days;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final max = days.fold<int>(1, (m, d) => [m, d.collectedPoisha, d.targetPoisha].reduce((a, b) => a > b ? a : b));
    final met = context.semanticColors.success.fg;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.perfDaily, style: t.titleSmall),
        const SizedBox(height: Space.s4),
        Row(children: [
          _Legend(color: cs.primary, label: l.perfLegendCollected),
          const SizedBox(width: Space.s12),
          _Legend(color: met, label: l.perfLegendMet),
          const SizedBox(width: Space.s12),
          _Legend(color: cs.onSurface, label: l.perfLegendTarget, line: true),
        ]),
        const SizedBox(height: Space.s12),
        Semantics(
          label: l.perfDailySemantics(f.money(days.fold(0, (s, d) => s + d.collectedPoisha))),
          child: SizedBox(
            height: 140,
            child: CustomPaint(
              size: Size.infinite,
              painter: _BarsPainter(days: days, max: max, bar: cs.primary, met: met, off: cs.surfaceContainerHighest, tick: cs.onSurface),
            ),
          ),
        ),
        const SizedBox(height: Space.s4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(f.date(days.first.date), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          Text(f.date(days.last.date), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        ]),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, this.line = false});
  final Color color;
  final String label;
  final bool line;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: line ? 12 : 10, height: line ? 2 : 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(line ? 1 : 2))),
        const SizedBox(width: Space.s4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ]);
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({required this.days, required this.max, required this.bar, required this.met, required this.off, required this.tick});
  final List<PerfDay> days;
  final int max;
  final Color bar;
  final Color met;
  final Color off;
  final Color tick;

  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty) return;
    final slot = size.width / days.length;
    final w = (slot * 0.62).clamp(2.0, 18.0);
    for (var i = 0; i < days.length; i++) {
      final d = days[i];
      final x = slot * i + (slot - w) / 2;
      if (!d.workingDay) {
        canvas.drawRRect(RRect.fromLTRBR(x, size.height - 4, x + w, size.height, const Radius.circular(2)), Paint()..color = off);
        continue;
      }
      final h = size.height * d.collectedPoisha / max;
      final color = d.targetPoisha > 0 && d.collectedPoisha >= d.targetPoisha ? met : bar;
      if (h > 0) {
        canvas.drawRRect(RRect.fromLTRBAndCorners(x, size.height - h, x + w, size.height, topLeft: const Radius.circular(3), topRight: const Radius.circular(3)), Paint()..color = color);
      }
      if (d.targetPoisha > 0) {
        final y = size.height - size.height * d.targetPoisha / max;
        canvas.drawLine(Offset(x - 1, y), Offset(x + w + 1, y), Paint()
          ..color = tick
          ..strokeWidth = 2);
      }
    }
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), Paint()
      ..color = off
      ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(_BarsPainter old) => old.days != days || old.max != max || old.bar != bar;
}
