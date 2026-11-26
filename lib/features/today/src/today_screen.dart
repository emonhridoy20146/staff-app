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
import '../../../core/theme/tag_colors.dart';
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
import 'home_work.dart';

/// How many overdue customers the "All" list shows before "N more".
const todayOverdueLimit = 8;

String greetingFor(AppLocalizations l, int dhakaHour, String name) =>
    dhakaHour < 12 ? l.greetingMorning(name) : (dhakaHour < 17 ? l.greetingAfternoon(name) : l.greetingEvening(name));

/// Today (FR-M-004, FR-M-005). Home v2 (owner request 2026-11-26, design guide §5.1, `docs/design/home-settings-v2.md`):
/// header (greeting, date, sync) → summary card (today's collection and the three work counts) → duty → what is
/// wrong or waiting (alerts) → the quick-action grid → the features' cards → the work list with its filter
/// chips. A filter shows only that list; All keeps the three sections in priority order. Skeleton rows while
/// loading, a calm card when a list is empty.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  final _listKey = GlobalKey(debugLabel: 'today-work-list');

  /// A count in the summary card, "N more" and "show all" pick a filter and bring the work list up.
  void _show(HomeFilter f) {
    ref.read(homeFilterProvider.notifier).pick(f);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _listKey.currentContext;
      if (!mounted || ctx == null) return;
      final reduce = MediaQuery.disableAnimationsOf(context);
      Scrollable.ensureVisible(ctx, duration: reduce ? Duration.zero : Motion.slow, curve: Motion.standard);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final access = ref.watch(accessProvider);
    ref.watch(minuteTickerProvider);
    final work = ref.watch(homeWorkProvider);
    final filters = ref.watch(homeFiltersProvider);
    final picked = ref.watch(homeFilterProvider);
    // A filter that is no longer offered (its module was turned off) falls back to All.
    final filter = filters.contains(picked) ? picked : HomeFilter.all;
    final cards = [
      for (final m in ref.watch(featureManifestsProvider))
        if (access.flag(m.flag))
          for (final c in m.todayCards)
            if (c.permission == null || access.can(c.permission!)) c,
    ]..sort((a, b) => a.order.compareTo(b.order));
    final canCollect = access.flag('module.collections') && access.can(Perm.collectionRecord);

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      // Owner request 2026-11-23: no floating Collect button; each row has its own Collect.
      body: RefreshIndicator(
        onRefresh: () => ref.read(syncEngineProvider).syncNow(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: _HomeHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(Space.screen, 0, Space.screen, 0),
              sliver: SliverList.list(children: [
                _ProgressCard(priorities: work.value?.priorities, onKpi: _show),
                if (ref.watch(attendanceShownProvider)) const _Gap(child: DutyCard()),
                // v2: what is wrong or waiting comes before the shortcuts, so nine tiles never push it under the fold.
                for (final c in cards)
                  if (c.alert) _Gap(child: c.builder(context)),
                const _CashWarning(),
                const _Gap(child: _QuickGrid()),
                for (final c in cards)
                  if (!c.alert) _Gap(child: c.builder(context)),
              ]),
            ),
            SliverToBoxAdapter(child: KeyedSubtree(key: _listKey, child: const _WorkListTitle())),
            ...work.when(
              loading: () => [const SliverToBoxAdapter(child: _WorkSkeleton())],
              error: (_, _) => [
                SliverToBoxAdapter(child: _CalmCard(child: EmptyState(icon: Icons.error_outline_rounded, title: l.errorGeneric, body: ''))),
              ],
              data: (w) => [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _FilterBarDelegate(background: cs.surfaceContainerLowest, child: _FilterBar(filters: filters, picked: filter, work: w)),
                ),
                ..._list(context, w, filter, canCollect),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: Space.s48)),
          ],
        ),
      ),
    );
  }

  /// All: the three sections in priority order, overdue cut at [todayOverdueLimit]. A filter: only that list, whole.
  List<Widget> _list(BuildContext context, HomeWork w, HomeFilter filter, bool canCollect) {
    final l = AppLocalizations.of(context);
    if (filter == HomeFilter.all) {
      final p = w.priorities;
      if (p.isEmpty) {
        return [SliverToBoxAdapter(child: _CalmCard(child: EmptyState(icon: Icons.task_alt_rounded, title: l.todayAllDone, body: l.todayAllDoneBody)))];
      }
      return [
        ..._section(context, HomeFilter.promised, p.promised, canCollect),
        ..._section(context, HomeFilter.due, p.due, canCollect),
        ..._section(context, HomeFilter.overdue, p.overdue.take(todayOverdueLimit).toList(), canCollect, total: p.overdue.length),
        if (p.overdue.length > todayOverdueLimit)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, 0),
              child: OutlinedButton.icon(
                key: const Key('today-more'),
                onPressed: () => _show(HomeFilter.overdue),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(l.todayMore(ref.read(fmtProvider).num(p.overdue.length - todayOverdueLimit))),
              ),
            ),
          ),
      ];
    }
    final list = w.listOf(filter);
    if (list.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: _CalmCard(
            child: EmptyState(
              icon: Icons.inbox_rounded,
              title: l.homeFilterEmpty,
              body: l.homeFilterEmptyBody,
              action: TextButton(key: const Key('home-filter-show-all'), onPressed: () => _show(HomeFilter.all), child: Text(l.homeFilterShowAll)),
            ),
          ),
        ),
      ];
    }
    return _section(context, filter, list, canCollect);
  }

  List<Widget> _section(BuildContext context, HomeFilter group, List<Customer> list, bool canCollect, {int? total}) {
    if (list.isEmpty) return const [];
    final look = _lookOf(context, group);
    return [
      SliverToBoxAdapter(child: _ToneHeader(title: look.title, icon: look.icon, count: total ?? list.length, style: look.style)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: Space.screen),
        sliver: _RowsCard(customers: list, canCollect: canCollect),
      ),
    ];
  }
}

/// How one list of the work list looks: its chip word, its section title, its icon and tone.
typedef _Look = ({String chip, String title, IconData icon, StatusStyle style});

_Look _lookOf(BuildContext context, HomeFilter f) {
  final l = AppLocalizations.of(context);
  final cs = Theme.of(context).colorScheme;
  final st = context.statusColors;
  return switch (f) {
    HomeFilter.all => (chip: l.filterAll, title: l.homeWorkListTitle, icon: Icons.checklist_rounded, style: StatusStyle(fg: cs.onSurfaceVariant, bg: cs.surfaceContainerHigh)),
    HomeFilter.promised => (chip: l.todayPromisedSection, title: l.todayPromisedSection, icon: Icons.handshake_rounded, style: st.of(AppStatus.promised)),
    HomeFilter.due => (chip: l.todayDueSection, title: l.todayDueSection, icon: Icons.event_available_rounded, style: st.of(AppStatus.dueToday)),
    HomeFilter.overdue => (chip: l.filterOverdue, title: l.todayOverdueSection, icon: Icons.near_me_rounded, style: st.of(AppStatus.overdue)),
    HomeFilter.badTag => (chip: l.tagKindOther, title: l.tagKindOther, icon: Icons.flag_rounded, style: context.tagColors.of(TagKind.other)),
    HomeFilter.brokenPromise => (chip: l.homeFilterBroken, title: l.homeFilterBroken, icon: Icons.heart_broken_rounded, style: context.semanticColors.danger),
  };
}

/// The filter chips (FR-M-082): one choice, each with the number of rows it shows; the two lenses sit after a
/// divider. Scrolls sideways; every chip is a 48 dp target.
class _FilterBar extends ConsumerStatefulWidget {
  const _FilterBar({required this.filters, required this.picked, required this.work});
  final List<HomeFilter> filters;
  final HomeFilter picked;
  final HomeWork work;

  @override
  ConsumerState<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends ConsumerState<_FilterBar> {
  final _scroll = ScrollController();
  final _chipKeys = {for (final x in HomeFilter.values) x: GlobalKey(debugLabel: 'home-filter-${x.name}')};

  @override
  void initState() {
    super.initState();
    _reveal(animate: false);
  }

  @override
  void didUpdateWidget(_FilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.picked != widget.picked) _reveal(animate: true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// The picked chip is always in sight: a count in the summary card, "N more" or the choice kept for the
  /// session can pick one that sits past the edge. Only the chip row moves, never the page.
  void _reveal({required bool animate}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final chip = _chipKeys[widget.picked]?.currentContext?.findRenderObject();
      if (chip == null) return;
      final still = !animate || MediaQuery.disableAnimationsOf(context);
      _scroll.position.ensureVisible(chip, alignment: 0.5, duration: still ? Duration.zero : Motion.fast, curve: Motion.standard);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final filters = widget.filters, picked = widget.picked, work = widget.work;
    return Semantics(
      container: true,
      label: AppLocalizations.of(context).homeFiltersA11y,
      // A Row, not a lazy list: there are at most six chips, and TalkBack must reach the ones past the edge.
      child: SingleChildScrollView(
        key: const Key('home-filters'),
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Space.screen, vertical: Space.s4),
        child: Row(children: [
          for (final x in filters) ...[
            if (x == HomeFilter.badTag)
              Padding(
                padding: const EdgeInsets.only(right: Space.s8),
                child: VerticalDivider(width: Space.s8, indent: Space.s8, endIndent: Space.s8, color: cs.outlineVariant),
              ),
            Padding(
              key: _chipKeys[x],
              padding: const EdgeInsets.only(right: Space.s8),
              child: Builder(builder: (context) {
                final look = _lookOf(context, x);
                final on = x == picked;
                return FilterChip(
                  key: ValueKey('home-filter-${x.name}'),
                  selected: on,
                  showCheckmark: false,
                  avatar: Icon(look.icon, size: 18, color: on ? cs.onPrimaryContainer : look.style.fg),
                  label: Text.rich(TextSpan(children: [
                    TextSpan(text: look.chip),
                    TextSpan(text: '  ${f.num(work.count(x))}', style: AppTheme.tabular(t.labelMedium!).copyWith(fontWeight: FontWeight.w700)),
                  ])),
                  onSelected: (_) => ref.read(homeFilterProvider.notifier).pick(x),
                );
              }),
            ),
          ],
        ]),
      ),
    );
  }
}

/// Keeps the filter chips under the top bar while the list scrolls; a hairline shows once rows pass under it.
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  _FilterBarDelegate({required this.background, required this.child});
  final Color background;
  final Widget child;

  static const _height = Sizes.minTarget + Space.s8;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Material(
        color: background,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: overlapsContent ? Theme.of(context).colorScheme.outlineVariant : Colors.transparent))),
          child: child,
        ),
      );

  @override
  bool shouldRebuild(_FilterBarDelegate oldDelegate) => oldDelegate.child != child || oldDelegate.background != background;
}

/// The rows of one list in the Home card style, built lazily: a filter can hold hundreds of customers and
/// only the rows on screen exist.
class _RowsCard extends StatelessWidget {
  const _RowsCard({required this.customers, required this.canCollect});
  final List<Customer> customers;
  final bool canCollect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const r = Radius.circular(Radii.xl);
    return DecoratedSliver(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: Radii.brXl,
        border: Border.all(color: cs.outlineVariant),
        boxShadow: Shadows.of(Theme.of(context).brightness, Shadows.sm),
      ),
      sliver: SliverList.separated(
        itemCount: customers.length,
        // Two frames in a row are already apart: a line between them would be one line too many.
        separatorBuilder: (_, i) => customers[i].badTag != null && customers[i + 1].badTag != null
            ? const SizedBox.shrink()
            : const Divider(height: 1, indent: Space.s16, endIndent: Space.s16),
        itemBuilder: (context, i) {
          final c = customers[i];
          final row = Material(
            type: MaterialType.transparency,
            child: CustomerWorkRow(
              key: ValueKey('home-row-${c.id}'),
              customer: c,
              onTap: () => context.push('/customers/${c.id}'),
              action: canCollect ? _QuickCollect(customerId: c.id) : null,
            ),
          );
          final first = i == 0, last = i == customers.length - 1;
          // The ripple of the first and last row follows the card's corners.
          return first || last ? ClipRRect(borderRadius: BorderRadius.vertical(top: first ? r : Radius.zero, bottom: last ? r : Radius.zero), child: row) : row;
        },
      ),
    );
  }
}

/// Greeting, date and sync state; the greeting may wrap at large text sizes instead of being cut.
class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final user = ref.watch(sessionProvider).user;
    final now = ref.watch(clockProvider).nowDhaka();
    final name = user?.name.of(lang).split(' ').first ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.screen, Space.s20, Space.s12, Space.s16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Semantics(
              header: true,
              child: Text(greetingFor(l, now.hour, name), style: t.headlineSmall!.copyWith(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: Space.s2),
            Row(children: [
              Icon(Icons.calendar_today_rounded, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: Space.s4),
              Flexible(
                child: Text(f.date(ref.watch(todayProvider), withYear: true), style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ]),
          ]),
        ),
        const SizedBox(width: Space.s8),
        SyncChip(onTap: () => context.push('/sync')),
      ]),
    );
  }
}

/// "Today's work list" over the sections.
class _WorkListTitle extends StatelessWidget {
  const _WorkListTitle();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.screen, Space.s32, Space.screen, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Semantics(header: true, child: Text(l.homeWorkListTitle, style: t.titleLarge)),
        const SizedBox(height: Space.s2),
        Text(l.homeWorkListBody, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
      ]),
    );
  }
}

/// Section header: a toned icon square, the title and a toned count pill.
class _ToneHeader extends ConsumerWidget {
  const _ToneHeader({required this.title, required this.icon, required this.count, required this.style});
  final String title;
  final IconData icon;
  final int count;
  final StatusStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final n = ref.watch(fmtProvider).num(count);
    return Semantics(
      header: true,
      label: '$title, $n',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s20, Space.screen, Space.s12),
        child: Row(children: [
          Container(
            width: Space.s32,
            height: Space.s32,
            decoration: BoxDecoration(color: style.bg, borderRadius: Radii.brMd),
            child: Icon(icon, size: 18, color: style.fg),
          ),
          const SizedBox(width: Space.s12),
          Flexible(child: Text(title, style: t.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: Space.s8),
          DecoratedBox(
            decoration: BoxDecoration(color: style.bg, borderRadius: const BorderRadius.all(Radius.circular(Radii.full))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s8 + 2, vertical: Space.s2),
              child: Text(n, style: AppTheme.tabular(t.labelMedium!).copyWith(color: style.fg, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}

/// The one card style of Home: surface, 16 dp corners, hairline border, a soft shadow in light mode.
class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: Radii.brXl,
        border: Border.all(color: cs.outlineVariant),
        boxShadow: Shadows.of(Theme.of(context).brightness, Shadows.sm),
      ),
      child: ClipRRect(borderRadius: Radii.brXl, child: Material(type: MaterialType.transparency, child: child)),
    );
  }
}

/// An empty or error state inside the card style, so the page keeps its rhythm.
class _CalmCard extends StatelessWidget {
  const _CalmCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, 0),
        child: _SurfaceCard(child: SizedBox(width: double.infinity, child: child)),
      );
}

/// Loading: three skeleton rows in the shape of the work rows (no spinner, no layout jump).
class _WorkSkeleton extends StatelessWidget {
  const _WorkSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget bar(double w, double h) => Container(width: w, height: h, decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: Radii.brSm));
    Widget row() => Padding(
          padding: const EdgeInsets.all(Space.s16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Align(alignment: AlignmentDirectional.centerStart, child: bar(160, 18))), bar(72, 18)]),
            const SizedBox(height: Space.s8),
            bar(120, 12),
            const SizedBox(height: Space.s12),
            Row(children: [
              for (var i = 0; i < 4; i++) ...[bar(Space.s32, Space.s32), const SizedBox(width: Space.s8)],
              const Spacer(),
              bar(96, Sizes.minTarget - Space.s8),
            ]),
          ]),
        );
    return Semantics(
      label: AppLocalizations.of(context).homeLoading,
      liveRegion: true,
      excludeSemantics: true,
      child: Padding(
        key: const Key('today-skeleton'),
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s20, Space.screen, 0),
        child: _SurfaceCard(
          child: Column(children: [
            for (var i = 0; i < 3; i++) ...[if (i > 0) const Divider(height: 1, indent: Space.s16, endIndent: Space.s16), row()],
          ]),
        ),
      ),
    );
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

/// Quick actions (FR-M-083, design guide §5.1): the shortcuts features give through their manifests
/// (`quickActions`), as one card with full rows of three equal cells: nine, six or three. A feature that is
/// off, or that the user may not use, gives none, and the rest move up.
class _QuickGrid extends ConsumerWidget {
  const _QuickGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(accessProvider);
    final all = [
      for (final m in ref.watch(featureManifestsProvider))
        if (access.flag(m.flag))
          for (final a in m.quickActions)
            if ((a.permission == null || access.can(a.permission!)) && (a.visible?.call(ref) ?? true)) a,
    ]..sort((a, b) => a.order.compareTo(b.order));
    final shown = all.take(quickGridCount(all.length)).toList();
    if (shown.isEmpty) return const SizedBox.shrink();
    final perRow = shown.length < 3 ? shown.length : 3;
    return Semantics(
      container: true,
      label: AppLocalizations.of(context).quickActionsA11y,
      child: _SurfaceCard(
        child: Padding(
          padding: const EdgeInsets.all(Space.s4),
          // Every row as tall as the tallest: the cells are one size whatever their labels need.
          child: IntrinsicHeight(
            key: const Key('quick-grid'),
            child: Column(children: [
              for (var i = 0; i < shown.length; i += perRow)
                Expanded(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    for (final a in shown.sublist(i, i + perRow)) Expanded(child: _QuickCell(action: a)),
                  ]),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// One shortcut: the icon in its tone's circle (`action.*`), the label on up to two lines, a count badge for
/// what waits behind it, and for attendance the done / still-to-do mark with its words.
class _QuickCell extends ConsumerWidget {
  const _QuickCell({required this.action});
  final QuickActionDef action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final tone = context.actionColors.of(action.tone);
    final label = action.label(l);
    final count = action.badge?.call(ref) ?? 0;
    final state = action.state?.call(ref, l);
    final mark = state == null ? null : (state.done ? context.semanticColors.success : context.semanticColors.warning);
    void open() => context.push(action.route);
    return Semantics(
      button: true,
      label: [count > 0 ? l.quickBadgeA11y(label, f.num(count)) : label, if (state != null) state.label].join(', '),
      excludeSemantics: true,
      onTap: open,
      child: InkWell(
        key: ValueKey('quick-${action.id}'),
        borderRadius: Radii.brLg,
        onTap: open,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Sizes.row3),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Space.s4, Space.s12, Space.s4, Space.s12),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Badge(
                isLabelVisible: count > 0,
                label: Text(f.num(count)),
                child: Stack(clipBehavior: Clip.none, children: [
                  Container(
                    width: Space.s40,
                    height: Space.s40,
                    decoration: BoxDecoration(color: tone.bg, shape: BoxShape.circle),
                    child: Icon(action.icon, size: 22, color: tone.fg),
                  ),
                  if (state != null && mark != null)
                    PositionedDirectional(
                      top: -Space.s4,
                      end: -Space.s8,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(color: mark.bg, shape: BoxShape.circle, border: Border.all(color: mark.fg)),
                        child: Icon(state.done ? Icons.check_rounded : Icons.priority_high_rounded, size: 12, color: mark.fg),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: Space.s8),
              Text(label, style: t.labelMedium!.copyWith(color: cs.onSurface), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              if (state != null && mark != null) ...[
                const SizedBox(height: Space.s2),
                Text(state.label, style: t.labelSmall!.copyWith(color: mark.fg, fontWeight: FontWeight.w700), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

/// The summary card (the Home's "hero"). Owner request 2026-11-23: compact by default (amount, target and its
/// bar); a tap opens the visit target, cash / mobile / visits and the cash meter. The "Details ▾" pill says it can
/// be opened. 2026-11-26: the three work counts (promised / due / overdue) sit under the bar as KPI tiles in their
/// status colours; a tap scrolls to that section.
class _ProgressCard extends ConsumerStatefulWidget {
  const _ProgressCard({required this.priorities, required this.onKpi});
  final TodayPriorities? priorities;
  final ValueChanged<HomeFilter> onKpi;
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
    final p = widget.priorities;
    final st = context.statusColors;

    final details = <Widget>[
      const SizedBox(height: Space.s16),
      Container(
        padding: const EdgeInsets.all(Space.s12),
        decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: Radii.brLg, border: Border.all(color: cs.outlineVariant)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (visitTarget > 0) ...[
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
            const SizedBox(height: Space.s16),
          ],
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _Metric(icon: Icons.payments_outlined, label: l.cashTodayCash, value: f.money(totals.cash))),
            const SizedBox(width: Space.s8),
            Expanded(child: _Metric(icon: Icons.phone_android_rounded, label: l.cashTodayMobile, value: f.money(totals.mobile))),
            const SizedBox(width: Space.s8),
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
        ]),
      ),
    ];

    return DecoratedBox(
      key: const Key('today-progress-card'),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: Radii.brXl,
        border: Border.all(color: cs.outlineVariant),
        boxShadow: Shadows.of(Theme.of(context).brightness, Shadows.md),
      ),
      child: ClipRRect(
        borderRadius: Radii.brXl,
        child: Material(
          type: MaterialType.transparency,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // A brand stripe on top: the one place Home uses the primary colour as a surface accent.
            Container(height: Space.s4, color: cs.primary),
            Semantics(
              button: true,
              expanded: _open,
              label: l.todayCollectedDetails,
              child: InkWell(
                onTap: () => setState(() => _open = !_open),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Space.s16, Space.s12, Space.s12, Space.s16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        width: Space.s32,
                        height: Space.s32,
                        decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: Radii.brMd),
                        child: Icon(Icons.account_balance_wallet_rounded, size: 18, color: cs.onPrimaryContainer),
                      ),
                      const SizedBox(width: Space.s8),
                      Expanded(child: Text(l.todayCollected, style: t.titleSmall!.copyWith(color: cs.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: Space.s8),
                      ExpandHint(open: _open),
                    ]),
                    const SizedBox(height: Space.s8),
                    MoneyText(totals.total, style: t.headlineMedium!.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: Space.s2),
                    Wrap(spacing: Space.s8, runSpacing: Space.s4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      Text(
                        target > 0 ? l.todayOfTarget(f.money(target)) : (offDay ? l.todayOffDay : l.todayNoTarget),
                        style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                      ),
                      if (ratio >= 1)
                        _TargetMet(label: l.todayTargetMet)
                      else if (mine?.source == 'personal' && target > 0)
                        Text(l.todayTargetPersonal, style: t.labelMedium!.copyWith(color: cs.primary)),
                    ]),
                    if (target > 0) ...[
                      const SizedBox(height: Space.s12),
                      Row(children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(Radii.full)),
                            child: LinearProgressIndicator(value: ratio, minHeight: 10, color: ratio >= 1 ? done : cs.primary),
                          ),
                        ),
                        const SizedBox(width: Space.s12),
                        Text(l.homeTargetPct(f.num((ratio * 100).floor())), style: AppTheme.tabular(t.labelMedium!).copyWith(color: ratio >= 1 ? done : cs.onSurfaceVariant)),
                      ]),
                    ],
                    AnimatedSize(
                      duration: Motion.base,
                      curve: Motion.standard,
                      alignment: Alignment.topCenter,
                      child: _open ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: details) : const SizedBox(width: double.infinity),
                    ),
                  ]),
                ),
              ),
            ),
            if (p != null) ...[
              Divider(height: 1, color: cs.outlineVariant),
              Padding(
                padding: const EdgeInsets.all(Space.s12),
                child: IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Expanded(child: _Kpi(label: l.homeKpiPromised, count: p.promised.length, style: st.of(AppStatus.promised), onTap: () => widget.onKpi(HomeFilter.promised))),
                    const SizedBox(width: Space.s8),
                    Expanded(child: _Kpi(label: l.homeKpiDue, count: p.due.length, style: st.of(AppStatus.dueToday), onTap: () => widget.onKpi(HomeFilter.due))),
                    const SizedBox(width: Space.s8),
                    Expanded(child: _Kpi(label: l.homeKpiOverdue, count: p.overdue.length, style: st.of(AppStatus.overdue), onTap: () => widget.onKpi(HomeFilter.overdue))),
                  ]),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

/// One work count in its status colour (a zero is shown quietly, in the neutral tone).
class _Kpi extends ConsumerWidget {
  const _Kpi({required this.label, required this.count, required this.style, required this.onTap});
  final String label;
  final int count;
  final StatusStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final n = ref.watch(fmtProvider).num(count);
    final zero = count == 0;
    final fg = zero ? cs.onSurfaceVariant : style.fg;
    return Semantics(
      button: true,
      label: l.homeKpiLabel(label, n),
      excludeSemantics: true,
      child: Material(
        color: zero ? cs.surfaceContainer : style.bg,
        borderRadius: Radii.brLg,
        child: InkWell(
          borderRadius: Radii.brLg,
          onTap: count == 0 ? null : onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Sizes.minTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: Space.s8),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(n, style: AppTheme.tabular(t.titleLarge!).copyWith(color: fg, fontWeight: FontWeight.w700), maxLines: 1),
                Text(label, style: t.labelSmall!.copyWith(color: fg), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ),
        ),
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
