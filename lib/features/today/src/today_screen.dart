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
      floatingActionButton: canCollect
          ? FloatingActionButton.extended(
              heroTag: 'collect',
              onPressed: () => context.push('/collect'),
              icon: const Icon(Icons.payments_rounded),
              label: Text(l.todayCollectFab),
            )
          : null,
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
              if (access.flag('module.attendance') && access.can(Perm.attendanceRecord)) ...[const DutyCard(), const SizedBox(height: Space.cardGap)],
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
          const SliverToBoxAdapter(child: SizedBox(height: 112)),
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
                CustomerTile(
                  customer: list[i],
                  onTap: () => context.push('/customers/${list[i].id}'),
                  trailing: canCollect ? _QuickCollect(customerId: list[i].id) : null,
                ),
              ],
            ]),
          ),
        ),
      ),
    ];
  }
}

class _Gap extends StatelessWidget {
  const _Gap({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: Space.cardGap), child: child);
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
    return IconButton.filledTonal(
      tooltip: l.actionCollect,
      constraints: const BoxConstraints.tightFor(width: Sizes.minTarget, height: Sizes.minTarget),
      onPressed: () => context.push('/collect/$customerId'),
      icon: const Icon(Icons.payments_rounded),
    );
  }
}

class _ProgressCard extends ConsumerWidget {
  const _ProgressCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final access = ref.watch(accessProvider);
    final totals = ref.watch(todayTotalsProvider).value ?? const DayTotals();
    final visits = ref.watch(todayVisitCountProvider).value ?? 0;
    final target = ((ref.watch(serverSettingsProvider)['dailyTargetPoisha'] as num?) ?? 0).toInt();
    final ratio = target <= 0 ? 0.0 : (totals.total / target).clamp(0.0, 1.0);
    final showCash = access.flag('module.cash') && access.can(Perm.cashView);

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.todayCollected, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          MoneyText(totals.total, style: t.headlineMedium!.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: Space.s8),
          Expanded(
            child: Text(target > 0 ? l.todayOfTarget(f.money(target)) : l.todayNoTarget, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ]),
        if (target > 0) ...[
          const SizedBox(height: Space.s8),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(Radii.full)),
            child: LinearProgressIndicator(value: ratio, minHeight: 10, color: ratio >= 1 ? context.semanticColors.success.fg : cs.primary),
          ),
        ],
        const SizedBox(height: Space.s16),
        Row(children: [
          Expanded(child: _Metric(icon: Icons.payments_outlined, label: l.cashTodayCash, value: f.money(totals.cash))),
          Expanded(child: _Metric(icon: Icons.phone_android_rounded, label: l.cashTodayMobile, value: f.money(totals.mobile))),
          Expanded(child: _Metric(icon: Icons.where_to_vote_outlined, label: l.todayVisits, value: f.num(visits))),
        ]),
        if (showCash) ...[
          const Divider(height: Space.s32),
          const CashMeter(compact: true),
        ],
      ]),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
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
