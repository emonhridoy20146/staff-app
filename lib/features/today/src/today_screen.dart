import 'package:flutter/rendering.dart' show RenderShiftedBox, BoxParentData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/feature/feature_manifest.dart';
import '../../../core/permissions/permission_service.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/chips.dart';
import '../../../core/ui/common.dart';
import '../../../core/ui/expand_hint.dart';
import '../../../core/ui/money_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../attendance/attendance.dart';
import '../../auth/auth.dart';
import '../../cash/cash.dart';
import '../../collections/collections.dart';
import '../../customers/customers.dart';
import '../../visits/visits.dart';

/// How many overdue customers Today shows before "N more".
const todayOverdueLimit = 8;

String greetingFor(AppLocalizations l, int dhakaHour, String name) =>
    dhakaHour < 12 ? l.greetingMorning(name) : (dhakaHour < 17 ? l.greetingAfternoon(name) : l.greetingEvening(name));

/// Today (FR-M-004, FR-M-005): duty, progress, problems, then the work list
/// in priority order — promised today, due today, overdue nearest first.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key, this.onSeeOverdue});

  /// Opens the Customers tab filtered to overdue.
  final VoidCallback? onSeeOverdue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final access = ref.watch(accessProvider);
    final user = ref.watch(sessionProvider).user;
    final now = ref.watch(clockProvider).nowDhaka();
    ref.watch(minuteTickerProvider);
    final prio = ref.watch(todayPrioritiesProvider);
    final cards = [
      for (final m in ref.watch(featureManifestsProvider))
        if (access.flag(m.flag))
          for (final c in m.todayCards)
            if (c.permission == null || access.can(c.permission!)) c,
    ]..sort((a, b) => a.order.compareTo(b.order));
    final canCollect = access.flag('module.collections') && access.can(Perm.collectionRecord);
    final name = user?.name.of(lang).split(' ').first ?? '';

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      // Owner request 2026-11-23: no floating Collect button; each row has its own Collect.
      body: RefreshIndicator(
        onRefresh: () => ref.read(syncEngineProvider).syncNow(),
        child: CustomScrollView(slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: cs.surfaceContainer,
            titleSpacing: Space.screen,
            toolbarHeight: 64,
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(greetingFor(l, now.hour, name), style: t.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(f.date(ref.watch(todayProvider), withYear: true), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
            ]),
            actions: [SyncChip(onTap: () => context.push('/sync')), const SizedBox(width: Space.s12)],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, 0),
            sliver: SliverList.list(children: [
              if (ref.watch(attendanceShownProvider)) ...[const DutyCard(), const SizedBox(height: Space.cardGap)],
              _QuickActions(access: access),
              const SizedBox(height: Space.cardGap),
              const _ProgressCard(),
              for (final c in cards) _Gap(child: c.builder(context)),
              const _CashWarning(),
            ]),
          ),
          ...prio.when(
            loading: () => [const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(Space.s32), child: Center(child: CircularProgressIndicator())))],
            error: (_, _) => [SliverToBoxAdapter(child: EmptyState(icon: Icons.error_outline_rounded, title: l.errorGeneric, body: ''))],
            data: (p) => p.isEmpty
                ? [SliverToBoxAdapter(child: EmptyState(icon: Icons.task_alt_rounded, title: l.todayAllDone, body: l.todayAllDoneBody))]
                : [
                    ..._section(context, l.todayPromisedSection, p.promised, AppStatus.promised, canCollect),
                    ..._section(context, l.todayDueSection, p.due, AppStatus.dueToday, canCollect),
                    ..._section(context, l.todayOverdueSection, p.overdue.take(todayOverdueLimit).toList(), AppStatus.overdue, canCollect, total: p.overdue.length),
                    if (p.overdue.length > todayOverdueLimit)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Space.screen),
                          child: TextButton(onPressed: onSeeOverdue, child: Text(l.todayMore(f.num(p.overdue.length - todayOverdueLimit)))),
                        ),
                      ),
                  ],
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Space.s32)),
        ]),
      ),
    );
  }

  List<Widget> _section(BuildContext context, String title, List<Customer> list, AppStatus tone, bool canCollect, {int? total}) {
    if (list.isEmpty) return const [];
    return [
      SliverToBoxAdapter(child: _CountedHeader(title: title, count: total ?? list.length, color: context.statusColors.of(tone).fg)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: Space.screen),
        sliver: SliverToBoxAdapter(
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              for (var i = 0; i < list.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: Space.s16, endIndent: Space.s16),
                CustomerWorkRow(
                  customer: list[i],
                  onTap: () => context.push('/customers/${list[i].id}'),
                  action: canCollect ? _QuickCollect(customerId: list[i].id) : null,
                ),
              ],
            ]),
          ),
        ),
      ),
    ];
  }
}

/// Top gap before an extension card that collapses when the card renders
/// nothing (e.g. no visit suggestion), so hidden cards leave no hole.
class _Gap extends SingleChildRenderObjectWidget {
  const _Gap({required Widget super.child});
  @override
  RenderObject createRenderObject(BuildContext context) => _RenderGap(Space.cardGap);
}

class _RenderGap extends RenderShiftedBox {
  _RenderGap(this.gap) : super(null);
  final double gap;

  @override
  void performLayout() {
    final c = child;
    if (c == null) {
      size = constraints.smallest;
      return;
    }
    c.layout(constraints.deflate(EdgeInsets.only(top: gap)), parentUsesSize: true);
    final shown = c.size.height > 0;
    (c.parentData! as BoxParentData).offset = Offset(0, shown ? gap : 0);
    size = constraints.constrain(Size(c.size.width, shown ? c.size.height + gap : 0));
  }
}

class _CountedHeader extends ConsumerWidget {
  const _CountedHeader({required this.title, required this.count, required this.color});
  final String title;
  final int count;
  final Color color;
  @override
  Widget build(BuildContext context, WidgetRef ref) => SectionHeader(title, count: ref.watch(fmtProvider).num(count), color: color);
}

class _QuickCollect extends StatelessWidget {
  const _QuickCollect({required this.customerId});
  final String customerId;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // A button that looks like one (owner request 2026-11-23): tonal, icon and word, 48 dp high.
    return FilledButton.tonalIcon(
      key: ValueKey('collect-$customerId'),
      style: FilledButton.styleFrom(minimumSize: const Size(0, Sizes.minTarget), padding: const EdgeInsets.symmetric(horizontal: Space.s16)),
      onPressed: () => context.push('/collect/$customerId'),
      icon: const Icon(Icons.payments_rounded),
      label: Text(l.actionCollect),
    );
  }
}

/// Three quick-access tiles: Attendance hub, Today's Work log, Performance.
class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.access});
  final AccessSnapshot access;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    // FR-M-042: the attendance tile says whether today's attendance is still to be given.
    final day = ref.watch(todayAttendanceProvider).value;
    final attended = day != null && day.status != DayStatus.notStarted;
    final showAttendance = ref.watch(attendanceShownProvider); // FR-M-070: never for a super admin
    final showReports = access.flag('module.reports');
    if (!showAttendance && !showReports) return const SizedBox.shrink();
    return Row(children: [
      if (showAttendance) ...[
        Expanded(child: _QuickTile(icon: Icons.work_history_rounded, label: l.attendanceBtn, mark: attended ? _TileMark.done : _TileMark.pending, markLabel: attended ? l.attTileDone : l.attTilePending, onTap: () => context.push('/attendance'))),
        const SizedBox(width: Space.s8),
      ],
      Expanded(child: _QuickTile(icon: Icons.list_alt_rounded, label: l.todayWorkBtn, onTap: () => context.push('/today-work'))),
      if (showReports) ...[
        const SizedBox(width: Space.s8),
        Expanded(child: _QuickTile(icon: Icons.insights_rounded, label: l.performanceBtn, onTap: () => context.push('/performance'))),
      ],
    ]);
  }
}

enum _TileMark { pending, done }

class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.icon, required this.label, required this.onTap, this.mark, this.markLabel});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// A small corner mark: amber "still to do" or green "done" (colour, icon and a spoken label).
  final _TileMark? mark;
  final String? markLabel;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    final markStyle = mark == _TileMark.done ? sem.success : sem.warning;
    return Semantics(
      label: markLabel,
      child: Material(
        color: cs.secondaryContainer,
        borderRadius: Radii.brMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: Radii.brMd,
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.s12, horizontal: Space.s8),
              child: SizedBox(
                width: double.infinity,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, size: 24, color: cs.onSecondaryContainer),
                  const SizedBox(height: Space.s4),
                  Text(label, style: t.labelSmall!.copyWith(color: cs.onSecondaryContainer), textAlign: TextAlign.center, maxLines: 2),
                  if (mark != null && markLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(markLabel!, style: t.labelSmall!.copyWith(color: markStyle.fg, fontWeight: FontWeight.w700), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ]),
              ),
            ),
            if (mark != null)
              PositionedDirectional(
                top: Space.s4,
                end: Space.s4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(color: markStyle.bg, shape: BoxShape.circle, border: Border.all(color: markStyle.fg)),
                  child: Icon(mark == _TileMark.done ? Icons.check_rounded : Icons.priority_high_rounded, size: 12, color: markStyle.fg),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

/// Today's collection. Owner request 2026-11-23: compact by default (amount, target and its bar); a tap opens
/// the visit target, cash / mobile / visits and the cash meter. The "Details ▾" pill says it can be opened.
class _ProgressCard extends ConsumerStatefulWidget {
  const _ProgressCard();
  @override
  ConsumerState<_ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends ConsumerState<_ProgressCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final access = ref.watch(accessProvider);
    final totals = ref.watch(todayTotalsProvider).value ?? const DayTotals();
    final split = ref.watch(todayVisitSplitProvider).value ?? (solo: 0, coWork: 0);
    final visits = split.solo + split.coWork;
    // My target for today (1.10.0, from the last pull; ignored once stale).
    final my = ref.watch(myTargetProvider);
    final mine = access.flag('module.targets') && my != null && my.businessDate == ref.watch(todayProvider) ? my : null;
    final target = mine?.amountPoisha ?? 0;
    final ratio = target <= 0 ? 0.0 : (totals.total / target).clamp(0.0, 1.0);
    final visitTarget = mine?.visits ?? 0.0;
    final credit = ref.watch(todayVisitCreditProvider);
    final visitRatio = visitTarget <= 0 ? 0.0 : (credit / visitTarget).clamp(0.0, 1.0);
    final offDay = mine != null && !mine.workingDay;
    final showCash = access.flag('module.cash') && access.can(Perm.cashView);
    final done = context.semanticColors.success.fg;

    final details = <Widget>[
        if (visitTarget > 0) ...[
          const SizedBox(height: Space.s12),
          Row(children: [
            Icon(Icons.where_to_vote_outlined, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: Space.s4),
            Expanded(child: Text(l.todayVisitTarget, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant))),
            Text(
              l.todayVisitTargetOf(f.dec(credit), f.dec(visitTarget)),
              style: AppTheme.tabular(t.titleSmall!).copyWith(color: visitRatio >= 1 ? done : null),
            ),
          ]),
          const SizedBox(height: Space.s4),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(Radii.full)),
            child: LinearProgressIndicator(value: visitRatio, minHeight: 6, color: visitRatio >= 1 ? done : cs.primary),
          ),
        ],
        const SizedBox(height: Space.s16),
        Row(children: [
          Expanded(child: _Metric(icon: Icons.payments_outlined, label: l.cashTodayCash, value: f.money(totals.cash))),
          Expanded(child: _Metric(icon: Icons.phone_android_rounded, label: l.cashTodayMobile, value: f.money(totals.mobile))),
          Expanded(
            child: _Metric(
              icon: Icons.where_to_vote_outlined,
              label: l.todayVisits,
              value: f.num(visits),
              hint: split.coWork > 0 ? l.todayVisitsJoint(f.num(split.coWork)) : null,
            ),
          ),
        ]),
        if (showCash) ...[
          const Divider(height: Space.s32),
          const CashMeter(compact: true),
        ],
    ];

    return Semantics(
      button: true,
      expanded: _open,
      label: l.todayCollectedDetails,
      child: AppCard(
        key: const Key('today-progress-card'),
        onTap: () => setState(() => _open = !_open),
        padding: const EdgeInsets.fromLTRB(Space.s16, Space.s12, Space.s12, Space.s12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(l.todayCollected, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant))),
          // Flexible: with the Details pill beside them they must shrink at large text sizes, not overflow.
          if (ratio >= 1)
            Flexible(child: _TargetMet(label: l.todayTargetMet))
          else if (mine?.source == 'personal' && target > 0)
            Flexible(child: Text(l.todayTargetPersonal, style: t.labelMedium!.copyWith(color: cs.primary), maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: Space.s8),
          ExpandHint(open: _open),
        ]),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          MoneyText(totals.total, style: t.headlineSmall!.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: Space.s8),
          Expanded(
            child: Text(
              target > 0 ? l.todayOfTarget(f.money(target)) : (offDay ? l.todayOffDay : l.todayNoTarget),
              style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
        if (target > 0) ...[
          const SizedBox(height: Space.s8),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(Radii.full)),
            child: LinearProgressIndicator(value: ratio, minHeight: 10, color: ratio >= 1 ? done : cs.primary),
          ),
        ],
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.topCenter,
          child: _open ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: details) : const SizedBox(width: double.infinity),
        ),
      ]),
      ),
    );
  }
}

/// "Target met" pill (success tone).
class _TargetMet extends StatelessWidget {
  const _TargetMet({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final st = context.semanticColors.success;
    return DecoratedBox(
      decoration: BoxDecoration(color: st.bg, borderRadius: Radii.brSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: Space.s2),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.emoji_events_rounded, size: 16, color: st.fg),
          const SizedBox(width: Space.s4),
          Flexible(child: Text(label, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: st.fg), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value, this.hint});
  final IconData icon;
  final String label;
  final String value;

  /// Small line under the value (e.g. "4 joint").
  final String? hint;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: Space.s4),
        Flexible(child: Text(label, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
      const SizedBox(height: 2),
      Text(value, style: AppTheme.tabular(t.titleMedium!)),
      if (hint != null) Text(hint!, style: t.bodySmall!.copyWith(color: cs.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
    ]);
  }
}

class _CashWarning extends ConsumerWidget {
  const _CashWarning();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cash = ref.watch(cashOnHandProvider).value;
    final access = ref.watch(accessProvider);
    if (cash == null || cash.limit <= 0 || !access.flag('module.cash')) return const SizedBox.shrink();
    final s = cashState(cash.onHand, cash.limit);
    if (s == CashState.ok) return const SizedBox.shrink();
    final pct = (cash.onHand * 100 ~/ cash.limit);
    return _Gap(
      child: InfoBanner(
        icon: Icons.account_balance_wallet_rounded,
        tone: s == CashState.exceeded ? BannerTone.danger : BannerTone.warning,
        text: AppLocalizations.of(context).todayCashWarning(ref.watch(fmtProvider).num(pct)),
        onTap: () => showDepositSheet(context),
      ),
    );
  }
}
