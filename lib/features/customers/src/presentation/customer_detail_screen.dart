import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/feature/feature_manifest.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../../../core/settings/ui_prefs.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/status_colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/dashed_border.dart';
import '../../../../core/ui/money_text.dart';
import '../../../../core/ui/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../contact_attempts.dart';
import '../customer_providers.dart';
import '../data/customer_repository.dart';
import '../domain/customer.dart';

Future<void> launchCall(String phone) => launchUrl(Uri(scheme: 'tel', path: phone));

/// Opens an external maps app (FR-M-013); no in-app turn-by-turn.
Future<void> launchNavigate(double lat, double lng, String label) async {
  final geo = Uri.parse('geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(label)})');
  if (!await launchUrl(geo)) {
    await launchUrl(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'), mode: LaunchMode.externalApplication);
  }
}

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId, this.initialAction});
  final String customerId;

  /// Customer action id to open once (e.g. `promise` after a receipt).
  final String? initialAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = ref.watch(customerProvider(customerId));
    return c.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(body: Center(child: Text(l.errorGeneric))),
      data: (customer) => customer == null ? Scaffold(appBar: AppBar(), body: Center(child: Text(l.customersEmpty))) : _Detail(customer: customer, initialAction: initialAction),
    );
  }
}

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.customer, this.initialAction});
  final Customer customer;
  final String? initialAction;
  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  bool _actionRun = false;

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final lang = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final access = ref.watch(accessProvider);
    final manifests = ref.watch(featureManifestsProvider);
    final actions = [
      for (final m in manifests)
        if (access.flag(m.flag))
          for (final a in m.customerActions)
            if (access.can(a.permission)) a,
    ]..sort((a, b) => a.order.compareTo(b.order));
    final ctx = CustomerActionContext(customerId: customer.id, customerName: customer.nameOf(lang));
    final primary = actions.where((a) => a.primary).toList();
    final secondary = actions.where((a) => !a.primary).toList();
    if (!_actionRun && widget.initialAction != null) {
      _actionRun = true;
      final a = actions.where((a) => a.id == widget.initialAction).firstOrNull;
      if (a != null) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) a.onTap(context, ref, ctx); });
    }

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: cs.surfaceContainer,
            title: Text(customer.code, style: AppTheme.mono(Theme.of(context).textTheme.titleMedium!)),
          ),
          SliverToBoxAdapter(child: _Header(customer: customer)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s8),
            sliver: SliverList.list(children: [
              _BalanceCard(customer: customer),
              if (customer.tagged || customer.row.badSuggested) ...[const SizedBox(height: Space.cardGap), _TagCard(customer: customer)],
              if (customer.row.openPromiseDate != null) ...[const SizedBox(height: Space.cardGap), _PromiseCard(customer: customer)],
              const SizedBox(height: Space.cardGap),
              _Plans(customerId: customer.id),
              const SizedBox(height: Space.cardGap),
              _Timeline(customerId: customer.id),
              const SizedBox(height: 120),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: actions.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(Space.screen, Space.s12, Space.screen, Space.s12),
                decoration: BoxDecoration(color: cs.surface, border: Border(top: BorderSide(color: cs.outlineVariant))),
                child: Row(
                  children: [
                    for (final a in secondary.take(secondary.length > 3 ? 2 : 3)) ...[
                      Expanded(
                        child: _SecondaryAction(icon: a.icon, label: a.label(context), onTap: () => a.onTap(context, ref, ctx)),
                      ),
                      const SizedBox(width: Space.s8),
                    ],
                    if (secondary.length > 3) ...[
                      Expanded(
                        child: _SecondaryAction(
                          icon: Icons.more_horiz_rounded,
                          label: AppLocalizations.of(context).actionMore,
                          onTap: () => showModalBottomSheet<void>(
                            context: context,
                            useSafeArea: true,
                            builder: (sheet) => SafeArea(
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                for (final a in secondary.skip(2))
                                  ListTile(
                                    minTileHeight: 56,
                                    leading: Icon(a.icon),
                                    title: Text(a.label(context)),
                                    onTap: () {
                                      Navigator.of(sheet).pop();
                                      a.onTap(context, ref, ctx);
                                    },
                                  ),
                              ]),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Space.s8),
                    ],
                    if (primary.isNotEmpty)
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: () => primary.first.onTap(context, ref, ctx),
                          icon: Icon(primary.first.icon),
                          label: Text(primary.first.label(context)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.secondaryContainer,
      borderRadius: Radii.brLg,
      child: InkWell(
        borderRadius: Radii.brLg,
        onTap: onTap,
        child: SizedBox(
          height: Sizes.primaryButton,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: cs.onSecondaryContainer),
              Text(label, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: cs.onSecondaryContainer), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final today = ref.watch(todayProvider);
    final phones = customer.phones;
    final badges = customer.badges(today);
    return Container(
      color: cs.surfaceContainer,
      padding: const EdgeInsets.fromLTRB(Space.screen, Space.s4, Space.screen, Space.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(customer.row.nameBn, style: t.titleLarge),
          if (customer.row.nameEn != null) Text(customer.row.nameEn!, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: Space.s12),
          Wrap(
            spacing: Space.s8,
            runSpacing: Space.s8,
            children: [
              for (final b in badges)
                StatusBadge(b, label: b == AppStatus.overdue ? l.statusOverdueDays(f.num(customer.row.daysOverdue)) : null),
            ],
          ),
          const SizedBox(height: Space.s16),
          if (customer.address != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(top: 2), child: Icon(Icons.place_rounded, size: 20, color: cs.onSurfaceVariant)),
                const SizedBox(width: Space.s8),
                Expanded(child: Text(customer.address!, style: t.bodyMedium)),
                if (customer.distanceM != null) Text(f.distance(customer.distanceM!), style: t.labelMedium!.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          const SizedBox(height: Space.s16),
          Row(
            children: [
              if (phones.isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => callAndLog(context, ref, customerId: customer.id, phones: phones),
                    icon: const Icon(Icons.call_rounded),
                    label: Text(f.num(phones.first)),
                  ),
                ),
              if (phones.isNotEmpty) const SizedBox(width: Space.s8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: customer.hasPin ? () => launchNavigate(customer.row.lat!, customer.row.lng!, customer.row.nameBn) : null,
                  icon: const Icon(Icons.directions_rounded),
                  label: Text(customer.hasPin ? l.actionNavigate : l.filterNoPin),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final pending = customer.row.pendingFieldPoisha;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.detailOutstanding, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: Space.s4),
            MoneyText(customer.outstanding, style: t.headlineMedium),
            if (customer.row.erpFetchedAt != null)
              Text(l.detailAsOfErp(f.dateTime(customer.row.erpFetchedAt!)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
            if (customer.overdueAmount > 0 || customer.installment != null) ...[
              const SizedBox(height: Space.s12),
              const Divider(height: 1),
              const SizedBox(height: Space.s12),
              Row(
                children: [
                  if (customer.installment != null)
                    Expanded(child: _Mini(label: l.detailInstallment, value: MoneyText(customer.installment!, style: t.titleMedium))),
                  if (customer.overdueAmount > 0)
                    Expanded(child: _Mini(label: l.statusOverdue, value: MoneyText(customer.overdueAmount, style: t.titleMedium))),
                ],
              ),
            ],
            if (pending > 0) ...[
              const SizedBox(height: Space.s12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s8),
                decoration: BoxDecoration(color: context.statusColors.of(AppStatus.pending).bg, borderRadius: Radii.brMd),
                child: Row(children: [
                  Icon(Icons.cloud_upload_rounded, size: 18, color: context.statusColors.of(AppStatus.pending).fg),
                  const SizedBox(width: Space.s8),
                  Expanded(child: Text(l.detailPendingField(f.money(pending)), style: t.bodyMedium!.copyWith(color: context.statusColors.of(AppStatus.pending).fg))),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value});
  final String label;
  final Widget value;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(label, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)), value],
      );
}

class _TagCard extends ConsumerWidget {
  const _TagCard({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final f = ref.watch(fmtProvider);
    if (customer.tagged) {
      final st = context.statusColors.of(AppStatus.tagged);
      final info = customer.row.tagReason == null ? const <String, dynamic>{} : jsonDecode(customer.row.tagReason!) as Map<String, dynamic>;
      return Container(
        padding: const EdgeInsets.all(Space.s16),
        decoration: BoxDecoration(color: st.bg, borderRadius: Radii.brXl),
        child: Row(children: [
          Icon(Icons.flag_rounded, color: st.fg),
          const SizedBox(width: Space.s12),
          Expanded(
            child: Text(
              l.detailTaggedBy((info['setBy'] as String?) ?? '—', (info['reason'] as String?) ?? ''),
              style: t.bodyMedium!.copyWith(color: st.fg, fontWeight: FontWeight.w600),
            ),
          ),
        ]),
      );
    }
    final st = context.statusColors.of(AppStatus.badSuggested);
    final info = customer.row.badReasonJson == null ? const <String, dynamic>{} : jsonDecode(customer.row.badReasonJson!) as Map<String, dynamic>;
    return CustomPaint(
      painter: DashedRRectPainter(color: st.fg, radius: Radii.xl, strokeWidth: 1.5),
      child: Container(
        padding: const EdgeInsets.all(Space.s16),
        decoration: BoxDecoration(color: st.bg, borderRadius: Radii.brXl),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.outlined_flag_rounded, color: st.fg),
            const SizedBox(width: Space.s12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.detailBadSuggestion, style: t.titleSmall!.copyWith(color: st.fg)),
                const SizedBox(height: 2),
                Text(
                  l.detailBadSuggestionBody(
                    info['finalDueDate'] == null ? '—' : f.date(info['finalDueDate'] as String, withYear: true),
                    f.money(((info['outstandingPoisha'] as num?) ?? customer.outstanding).toInt()),
                  ),
                  style: t.bodyMedium!.copyWith(color: st.fg),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromiseCard extends ConsumerWidget {
  const _PromiseCard({required this.customer});
  final Customer customer;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final st = context.statusColors.of(AppStatus.promised);
    return Container(
      padding: const EdgeInsets.all(Space.s16),
      decoration: BoxDecoration(color: st.bg, borderRadius: Radii.brXl),
      child: Row(children: [
        Icon(Icons.handshake_rounded, color: st.fg),
        const SizedBox(width: Space.s12),
        Expanded(
          child: Text(
            l.detailOpenPromise(f.money(customer.row.openPromisePoisha ?? 0), f.date(customer.row.openPromiseDate!)),
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: st.fg, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}

class _Plans extends ConsumerWidget {
  const _Plans({required this.customerId});
  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final plans = ref.watch(customerPlansProvider(customerId)).value ?? const <PlanWithSchedule>[];
    if (plans.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(Space.s16, Space.s16, Space.s16, Space.s4), child: Text(l.detailPlans, style: t.titleSmall)),
          for (final p in plans)
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: plans.length == 1,
                tilePadding: const EdgeInsets.symmetric(horizontal: Space.s16),
                childrenPadding: const EdgeInsets.fromLTRB(Space.s16, 0, Space.s16, Space.s12),
                title: Text(p.plan.product, style: t.titleMedium),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Space.s4),
                    Text(l.detailInstallments(f.num(p.paidCount), f.num(p.plan.installmentCount)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: Space.s8),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(Radii.full)),
                      child: LinearProgressIndicator(
                        value: p.plan.totalPayablePoisha == 0 ? 0 : p.plan.paidPoisha / p.plan.totalPayablePoisha,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: Space.s4),
                    Text(l.detailFinalDue(f.date(p.plan.finalDueDate, withYear: true)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
                children: [for (final s in p.schedule) _ScheduleRow(line: s)],
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends ConsumerWidget {
  const _ScheduleRow({required this.line});
  final ScheduleLineRow line;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sc = context.statusColors;
    final (icon, color, label) = switch (line.status) {
      'paid' => (Icons.check_circle_rounded, sc.of(AppStatus.paid).fg, l.schedulePaid),
      'overdue' => (Icons.error_rounded, sc.of(AppStatus.overdue).fg, l.scheduleOverdue),
      'due' => (Icons.event_rounded, sc.of(AppStatus.dueToday).fg, l.scheduleDue),
      'partial' => (Icons.timelapse_rounded, sc.of(AppStatus.dueToday).fg, l.schedulePartial),
      _ => (Icons.radio_button_unchecked_rounded, cs.outline, l.scheduleUpcoming),
    };
    return SizedBox(
      height: Sizes.minTarget,
      child: Row(children: [
        SizedBox(width: 28, child: Text(f.num(line.seq), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant))),
        Icon(icon, size: 18, color: color),
        const SizedBox(width: Space.s8),
        Expanded(child: Text(f.date(line.dueDate, withYear: true), style: t.bodyMedium)),
        Text(label, style: t.labelMedium!.copyWith(color: color)),
        const SizedBox(width: Space.s12),
        SizedBox(width: 92, child: MoneyText(line.amountPoisha, style: t.bodyMedium, textAlign: TextAlign.end)),
      ]),
    );
  }
}

/// Merged timeline: ERP payments (this feature) + entries contributed by
/// other features through `TimelineSourceDef`.
class _Timeline extends ConsumerStatefulWidget {
  const _Timeline({required this.customerId});
  final String customerId;
  @override
  ConsumerState<_Timeline> createState() => _TimelineState();
}

class _TimelineState extends ConsumerState<_Timeline> {
  final _sources = <String, List<TimelineEntry>>{};
  final _subs = <StreamSubscription<List<TimelineEntry>>>[];
  bool _subscribed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subscribed) return;
    _subscribed = true;
    for (final m in ref.read(featureManifestsProvider)) {
      for (final s in m.timelineSources) {
        _subs.add(s.watch(context, ref, widget.customerId).listen((v) => setState(() => _sources[s.id] = v)));
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
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final payments = ref.watch(customerPaymentsProvider(widget.customerId)).value ?? const <ErpPaymentRow>[];
    final entries = <TimelineEntry>[
      for (final p in payments)
        TimelineEntry(
          at: DateTime.parse('${p.date}T06:00:00Z'),
          icon: Icons.receipt_long_rounded,
          title: l.timelineErpPayment(f.money(p.amountPoisha), p.source == 'office' ? l.timelineOffice : l.timelineField),
          subtitle: [f.date(p.date, withYear: true), if (p.receiptNo != null) p.receiptNo!].join(' · '),
        ),
      for (final v in _sources.values) ...v,
    ]..sort((a, b) => b.at.compareTo(a.at));

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(Space.s16, Space.s8, Space.s16, Space.s8), child: Text(l.detailTimeline, style: t.titleSmall)),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(Space.s16),
                child: Text(l.detailNothingYet, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
              ),
            for (var i = 0; i < entries.length && i < 25; i++)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 56,
                      child: Column(children: [
                        Container(
                          margin: const EdgeInsets.only(top: Space.s12),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(color: cs.surfaceContainerHigh, shape: BoxShape.circle),
                          child: Icon(entries[i].icon, size: 18, color: cs.onSurfaceVariant),
                        ),
                        if (i < entries.length - 1) Expanded(child: Container(width: 2, color: cs.outlineVariant)),
                      ]),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, Space.s12, Space.s16, Space.s12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(child: Text(entries[i].title, style: t.bodyLarge!.copyWith(fontWeight: FontWeight.w600))),
                              ?entries[i].statusChip,
                            ]),
                            if (entries[i].subtitle != null) Text(entries[i].subtitle!, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
