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
import '../../../../core/time/clock.dart';
import '../../../../core/ui/dashed_border.dart';
import '../../../../core/ui/back_button.dart';
import '../../../../core/ui/common.dart';
import '../../../../core/ui/money_text.dart';
import '../../../../core/ui/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../contact_attempts.dart';
import '../customer_refresh.dart';
import '../pin_correction.dart';
import '../customer_providers.dart';
import '../data/customer_repository.dart';
import '../domain/customer.dart';
import '../domain/month_people.dart';
import '../domain/phones.dart';
import '../domain/schedule.dart';
import '../domain/work_marks.dart';
import '../phone_numbers.dart';
import 'invoice_kind_label.dart';

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
  bool _refreshing = false;
  final _pull = GlobalKey<RefreshIndicatorState>();

  /// FR-M-063: the reload button and pull down both ask the server for this customer, then sync.
  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    final r = await ref.read(customerRefreshServiceProvider).refresh(widget.customer.id);
    if (!mounted) return;
    setState(() => _refreshing = false);
    final l = AppLocalizations.of(context);
    final (text, icon) = switch (r.outcome) {
      CustomerRefreshOutcome.ok => (l.customerRefreshDone, Icons.check_circle_rounded),
      CustomerRefreshOutcome.offline => (l.customerRefreshOffline, Icons.cloud_off_rounded),
      CustomerRefreshOutcome.busy => (l.customerRefreshBusy, Icons.hourglass_top_rounded),
      CustomerRefreshOutcome.notFound => (l.customerRefreshNotFound, Icons.error_outline_rounded),
      CustomerRefreshOutcome.denied => (l.customerRefreshDenied, Icons.block_rounded),
      CustomerRefreshOutcome.failed => (l.customerRefreshFailed(r.code ?? '—'), Icons.error_outline_rounded),
    };
    showAppSnack(context, text, icon: icon);
  }

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

    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: RefreshIndicator(
        key: _pull,
        onRefresh: _refresh,
        child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: cs.surfaceContainer,
            // Owner request 2026-11-23: a bigger back button with a tonal background and a visible ripple.
            automaticallyImplyLeading: false,
            leading: Navigator.of(context).canPop() ? const AppBackButton() : null,
            leadingWidth: Sizes.minTarget + Space.s16 + Space.s8,
            title: Text(customer.code, style: AppTheme.mono(Theme.of(context).textTheme.titleMedium!)),
            actions: [
              IconButton(
                tooltip: l.customerRefresh,
                // Same as pulling down: the indicator shows while the server is asked.
                onPressed: _refreshing ? null : () => _pull.currentState?.show() ?? _refresh(),
                icon: _refreshing
                    ? const SizedBox.square(dimension: Space.s20, child: CircularProgressIndicator(strokeWidth: 2.5))
                    : const Icon(Icons.refresh_rounded),
              ),
              const SizedBox(width: Space.s4),
            ],
          ),
          SliverToBoxAdapter(child: _Header(customer: customer)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s8),
            sliver: SliverList.list(children: [
              _BalanceCard(customer: customer),
              const SizedBox(height: Space.cardGap),
              _MonthCard(customer: customer),
              if (customer.guarantor != null) ...[const SizedBox(height: Space.cardGap), _GuarantorCard(customer: customer)],
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

/// Branch and assignee (contract 1.19.0): staff see the whole branch, so a
/// colleague's or an unassigned customer says whose it is.
class _OwnerRow extends ConsumerWidget {
  const _OwnerRow({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final me = ref.watch(myCustomerUserIdProvider);
    final branch = customer.branchName(lang);
    final owner = customer.isMine(me)
        ? l.customerAssignedToMe
        : customer.row.assigneeId == null
            ? l.customerUnassigned
            : l.customerAssignedTo(customer.assigneeName ?? '—');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: Icon(Icons.storefront_rounded, size: 20, color: cs.onSurfaceVariant)),
        const SizedBox(width: Space.s8),
        Expanded(child: Text([if (branch != null) l.customerBranch(branch), owner].join(' · '), style: t.bodyMedium)),
      ],
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
    final phones = customer.phoneList;
    final badges = customer.badges(today);
    final access = ref.watch(accessProvider);
    final canPropose = access.flag('module.customers') && access.can(Perm.customerLocationPropose);
    return Container(
      color: cs.surfaceContainer,
      padding: const EdgeInsets.fromLTRB(Space.screen, Space.s4, Space.screen, Space.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FR-M-066: the open invoices by type at the right of the name ("১ কিস্তি · ২ বাকি").
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(customer.row.nameBn, style: t.titleLarge)),
              if (!customer.kinds.isEmpty) ...[
                const SizedBox(width: Space.s8),
                Padding(
                  padding: const EdgeInsets.only(top: Space.s4),
                  child: InvoiceKindLabel(key: const Key('header-kinds'), kinds: customer.kinds, counted: true),
                ),
              ],
            ],
          ),
          if (customer.row.nameEn != null) Text(customer.row.nameEn!, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: Space.s12),
          Wrap(
            spacing: Space.s8,
            runSpacing: Space.s8,
            children: [
              for (final b in badges)
                StatusBadge(b, label: b == AppStatus.overdue ? l.statusOverdueDays(f.daySpan(customer.row.daysOverdue)) : null),
              if (customer.erpRisk != null) _ErpRiskChip(risk: customer.erpRisk!),
            ],
          ),
          const SizedBox(height: Space.s16),
          // Always shown, so a customer without an address in the ERP says so instead of a lone icon.
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(top: 2), child: Icon(Icons.place_rounded, size: 20, color: cs.onSurfaceVariant)),
                const SizedBox(width: Space.s8),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      customer.address ?? l.detailNoAddress,
                      key: const Key('detail-address'),
                      style: customer.address == null ? t.bodyMedium!.copyWith(color: cs.onSurfaceVariant, fontStyle: FontStyle.italic) : t.bodyMedium,
                    ),
                    if (customer.detailedAddress != null) Text(customer.detailedAddress!, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                  ]),
                ),
                if (customer.distanceM != null) Text(f.distance(customer.distanceM!), style: t.labelMedium!.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          if (ref.watch(multiBranchProvider) || !customer.isMine(ref.watch(myCustomerUserIdProvider))) ...[
            const SizedBox(height: Space.s8),
            _OwnerRow(customer: customer),
          ],
          if (customer.directions != null) ...[
            const SizedBox(height: Space.s8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(top: 2), child: Icon(Icons.signpost_rounded, size: 20, color: cs.onSurfaceVariant)),
                const SizedBox(width: Space.s8),
                Expanded(
                  child: Semantics(
                    label: l.detailDirections,
                    child: Text(customer.directions!, style: t.bodyMedium),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: Space.s16),
          if (phones.isNotEmpty) ...[
            _PhonesRow(customer: customer, phones: phones),
            const SizedBox(height: Space.s8),
          ],
          // FR-M-037: add more numbers (several at once); they are kept in the field system, not in the ERP.
          if (access.can(Perm.customerPhoneManage) && phoneRoom(phones) > 0) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => showAddPhonesSheet(context, customerId: customer.id, existing: phones),
                icon: const Icon(Icons.add_call),
                label: Text(l.phoneAddNumber),
              ),
            ),
            const SizedBox(height: Space.s4),
          ],
          OutlinedButton.icon(
            onPressed: customer.hasPin
                ? () => launchNavigate(customer.row.lat!, customer.row.lng!, customer.row.nameBn)
                : (canPropose ? () => openPinCorrection(context, customer.id) : null),
            icon: Icon(customer.hasPin ? Icons.directions_rounded : Icons.add_location_alt_rounded),
            label: Text(customer.hasPin ? l.actionNavigate : (canPropose ? l.actionSetLocation : l.filterNoPin)),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(Sizes.primaryButton)),
          ),
          PinProposalStatus(customerId: customer.id),
        ],
      ),
    );
  }
}

/// All phone numbers of the customer (FR-M-037): the ERP's first, marked
/// "ERP" (the main one in the primary colour), then the ones added in the
/// field, marked "added" with whose number it is; one still waiting to reach
/// the server shows a cloud icon. Each row calls the number and logs the
/// attempt by its index (never the number).
class _PhonesRow extends ConsumerWidget {
  const _PhonesRow({required this.customer, required this.phones});
  final Customer customer;
  final List<CustomerPhone> phones;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final numbers = [for (final p in phones) p.number];
    // FR-M-053: an added number that reached the server can be removed again (online; ERP numbers never).
    final canRemove = ref.watch(accessProvider).can(Perm.customerPhoneManage);
    if (phones.length == 1 && phones.first.fromErp) {
      return OutlinedButton.icon(
        onPressed: () => callAndLog(context, ref, customerId: customer.id, phones: numbers),
        icon: const Icon(Icons.call_rounded),
        label: Text(f.num(numbers.first)),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(Sizes.primaryButton)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < phones.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i < phones.length - 1 ? Space.s8 : 0),
            child: Row(children: [
              Expanded(child: OutlinedButton(
              onPressed: () => callAndLog(context, ref, customerId: customer.id, phones: numbers, index: i),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(Sizes.primaryButton), padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s8)),
              child: Row(children: [
                const Icon(Icons.call_rounded, size: 20),
                const SizedBox(width: Space.s8),
                Expanded(
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(f.num(phones[i].number), style: t.bodyMedium),
                    if (phones[i].label != null) Text(phones[i].label!, style: t.labelSmall!.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
                if (phones[i].pending) ...[
                  Icon(Icons.cloud_upload_outlined, size: 18, color: cs.onSurfaceVariant, semanticLabel: l.phonePending),
                  const SizedBox(width: Space.s8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: 2),
                  decoration: BoxDecoration(
                    color: phones[i].primary ? cs.primaryContainer : (phones[i].fromErp ? cs.surfaceContainerHighest : cs.secondaryContainer),
                    borderRadius: Radii.brSm,
                  ),
                  child: Text(
                    phones[i].fromErp ? l.phoneErpPrimary : l.phoneAdded,
                    style: t.labelSmall!.copyWith(color: phones[i].primary ? cs.onPrimaryContainer : (phones[i].fromErp ? cs.onSurfaceVariant : cs.onSecondaryContainer)),
                  ),
                ),
              ]),
              )),
              if (canRemove && !phones[i].fromErp && !phones[i].pending)
                IconButton(
                  key: Key('phone-remove-${phones[i].number}'),
                  tooltip: l.phoneRemove,
                  onPressed: () => confirmRemovePhone(context, ref, customerId: customer.id, phone: phones[i]),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
            ]),
          ),
      ],
    );
  }
}

/// Guarantor's name and phone with a one-tap call (FR-M-029). The call is
/// logged with `target: guarantor` and shows on the timeline.
class _GuarantorCard extends ConsumerWidget {
  const _GuarantorCard({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final g = customer.guarantor!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.s16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: cs.secondaryContainer,
              foregroundColor: cs.onSecondaryContainer,
              child: const Icon(Icons.verified_user_rounded),
            ),
            const SizedBox(width: Space.s12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.detailGuarantor, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                Text(g.name.isEmpty ? l.guarantorNoName : g.name, style: t.titleMedium),
                if (g.phone.isNotEmpty) Text(f.num(g.phone), style: t.bodyLarge!.copyWith(color: cs.onSurfaceVariant)),
              ]),
            ),
            if (g.canCall)
              Tooltip(
                message: l.guarantorCall,
                child: FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(minimumSize: const Size(Sizes.minTarget, Sizes.minTarget)),
                  onPressed: () => callGuarantorAndLog(context, ref, customerId: customer.id, phone: g.phone),
                  icon: const Icon(Icons.call_rounded),
                  label: Text(l.guarantorCallShort),
                ),
              )
            else
              Text(l.guarantorNoPhone, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
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

/// "This month" (FR-M-038): was the customer visited, is there money in the
/// ERP or still waiting for it (two separate lines, never one sum), is a
/// promise open, and how many invoices there are. All from the phone's own
/// data, so it is right at once after a visit or a collection, also offline.
class _MonthCard extends ConsumerWidget {
  const _MonthCard({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final sc = context.statusColors;
    final sem = context.semanticColors;
    final m = workMarksFor(ref, customer);
    final paid = ref.watch(paidThisMonthProvider.select((x) => x.value?[customer.id] ?? 0));
    final plans = ref.watch(customerPlansProvider(customer.id)).value ?? const <PlanWithSchedule>[];
    final invoices = plans.where((p) => p.plan.status != 'cancelled').toList();
    final lastVisit = customer.row.lastVisitAt;
    // FR-M-068: who did each, from the names on the phone; a name the phone does not have is left out.
    final who = ref.watch(monthPeopleProvider(customer.id)).value ?? MonthPeople.none;
    final promiseAmount = customer.row.openPromisePoisha;
    String? name(Who? w) => w == null ? null : [w.office ? l.monthOffice : w.name, if (w.more > 0) l.monthMore(f.num(w.more))].join(' ');
    final visitBy = name(who.visitBy);
    final paidBy = name(who.paidBy);
    final pendingBy = name(who.pendingBy);
    final promiseBy = name(who.promiseBy);
    Widget line(IconData icon, Color color, String text) => Padding(
          padding: const EdgeInsets.only(top: Space.s8),
          child: Row(children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: Space.s8),
            Expanded(child: Text(text, style: t.bodyMedium!.copyWith(color: color == cs.outline ? cs.onSurfaceVariant : null))),
          ]),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.s16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(l.monthTitle, style: t.titleSmall)),
            if (invoices.isNotEmpty) ...[
              const SizedBox(width: Space.s8),
              // Flexible: the English line is longer than the title's row on a narrow phone.
              Flexible(
                child: Text(
                  l.monthInvoices(f.num(invoices.length), f.num(invoices.where((p) => p.collectable).length)),
                  style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ]),
          switch (m.visit) {
            VisitMark.today => line(Icons.directions_walk_rounded, sem.success.fg,
                visitBy == null ? l.marksVisitToday : '${l.monthVisitWho(visitBy)} · ${l.monthToday}'),
            VisitMark.month => line(Icons.directions_walk_rounded, sem.info.fg,
                visitBy == null ? l.monthLastVisit(f.date(businessDateOf(lastVisit!))) : '${l.monthVisitWho(visitBy)} · ${f.date(businessDateOf(lastVisit!))}'),
            VisitMark.none => line(Icons.directions_walk_rounded, cs.outline, l.marksVisitNone),
          },
          // ERP money of the month, with the collector the ERP recorded (an office payment: the person it names).
          if (paid > 0) line(Icons.payments_rounded, sc.of(AppStatus.paid).fg, [l.monthPaidAmount(f.money(paid)), ?paidBy].join(' · ')),
          if (customer.row.pendingFieldPoisha > 0) line(Icons.cloud_upload_outlined, sc.of(AppStatus.pending).fg, [l.monthPending(f.money(customer.row.pendingFieldPoisha)), ?pendingBy].join(' · ')),
          if (paid == 0 && customer.row.pendingFieldPoisha == 0) line(Icons.payments_rounded, cs.outline, l.marksPaidNone),
          if (customer.row.openPromiseDate != null)
            line(
              Icons.handshake_rounded,
              sc.of(AppStatus.promised).fg,
              promiseAmount == null
                  ? [l.monthPromise(f.date(customer.row.openPromiseDate!)), ?promiseBy].join(' · ')
                  : [l.monthPromiseAmount(f.money(promiseAmount)), ?promiseBy, f.date(customer.row.openPromiseDate!)].join(' · '),
            )
          else
            line(Icons.handshake_rounded, cs.outline, l.marksPromiseNone),
        ]),
      ),
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
          for (final p in sortedPlans(plans))
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: plans.length == 1,
                tilePadding: const EdgeInsets.symmetric(horizontal: Space.s16),
                childrenPadding: const EdgeInsets.fromLTRB(Space.s16, 0, Space.s16, Space.s12),
                expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                title: Text(p.plan.product, style: t.titleMedium!.copyWith(color: p.closedInErp ? cs.onSurfaceVariant : null)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Space.s4),
                    Text(
                      [
                        if (p.plan.invoiceNo != null) p.plan.invoiceNo!,
                        if (p.cash) l.planCashSale else if (p.credit) l.planCreditSale else l.detailInstallments(f.num(p.paidCount), f.num(p.shownCount)),
                        ?_frequency(l, f, p),
                      ].join(' · '),
                      style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                    ),
                    if (p.closedInErp) ...[
                      const SizedBox(height: Space.s4),
                      Text(p.plan.status == 'cancelled' ? l.planCancelled : l.planReturned, style: t.bodySmall!.copyWith(color: context.semanticColors.warning.fg, fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: Space.s8),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(Radii.full)),
                      child: LinearProgressIndicator(
                        value: p.plan.totalPayablePoisha == 0 ? 0 : p.plan.paidPoisha / p.plan.totalPayablePoisha,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: Space.s4),
                    Text(
                      [
                        // A cash sale has no due date (contract 1.44.0); the sale date stands instead when known.
                        if (p.cash)
                          ?(p.plan.saleDate == null ? null : f.date(p.plan.saleDate!, withYear: true))
                        else
                          p.credit ? l.planPayBy(f.date(p.plan.finalDueDate, withYear: true)) : l.detailFinalDue(f.date(p.plan.finalDueDate, withYear: true)),
                        if (p.plan.writtenOffPoisha > 0) l.planWrittenOff(f.money(p.plan.writtenOffPoisha)),
                      ].join(' · '),
                      style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                    ),
                    if (!p.closedInErp && p.dues.remainingCount > 0) ...[
                      const SizedBox(height: Space.s4),
                      Text(
                        [
                          if (!p.credit && !p.cash) l.planRemainingInstallments(f.num(p.dues.remainingCount)),
                          if (p.dues.overduePoisha > 0) l.collectChipOverdue(f.money(p.dues.overduePoisha)),
                        ].join(' · '),
                        style: t.bodySmall!.copyWith(
                          color: p.dues.overduePoisha > 0 ? context.statusColors.of(AppStatus.overdue).fg : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: Space.s12),
                    _InvoiceSummary(plan: p),
                    const SizedBox(height: Space.s4),
                  ],
                ),
                children: [
                  if (p.items.isNotEmpty || p.guarantor != null) _PlanFacts(plan: p),
                  for (final s in p.visibleSchedule) _ScheduleRow(line: s),
                  if (p.rolledCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: Space.s4),
                      child: Text(l.planRolledHidden(f.num(p.rolledCount)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Three-column invoice money summary: Total | Paid | Outstanding.
class _InvoiceSummary extends ConsumerWidget {
  const _InvoiceSummary({required this.plan});
  final PlanWithSchedule plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    return Container(
      decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: Radii.brMd),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _SummaryCell(label: l.planTotal, value: f.money(plan.plan.totalPayablePoisha))),
            VerticalDivider(width: 1, color: cs.outlineVariant),
            Expanded(child: _SummaryCell(label: l.planPaidSoFar, value: f.money(plan.plan.paidPoisha))),
            VerticalDivider(width: 1, color: cs.outlineVariant),
            Expanded(
              child: _SummaryCell(
                label: l.planLeft,
                value: f.money(plan.plan.outstandingPoisha),
                valueStyle: t.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: plan.plan.outstandingPoisha > 0 && !plan.closedInErp ? cs.error : cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({required this.label, required this.value, this.valueStyle});
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: Space.s8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: t.labelSmall!.copyWith(color: cs.onSurfaceVariant), maxLines: 1),
        const SizedBox(height: 2),
        Text(value, style: valueStyle ?? t.bodyMedium!.copyWith(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
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
    // amountPoisha already includes the late fee (contract), so left = amount − paid.
    final money = lineMoney(amountPoisha: line.amountPoisha, paidPoisha: line.paidPoisha);
    final state = lineState(status: line.status, amountPoisha: line.amountPoisha, paidPoisha: line.paidPoisha);
    // A line past its date stays "overdue" when partly paid; the paid and left amounts are shown under the date.
    final (icon, color, label) = switch (state) {
      'paid' => (Icons.check_circle_rounded, sc.of(AppStatus.paid).fg, l.schedulePaid),
      'overdue' => (Icons.error_rounded, sc.of(AppStatus.overdue).fg, l.scheduleOverdue),
      'due' => (Icons.event_rounded, sc.of(AppStatus.dueToday).fg, l.scheduleDue),
      'partial' => (Icons.timelapse_rounded, sc.of(AppStatus.dueToday).fg, l.schedulePartial),
      _ => (Icons.radio_button_unchecked_rounded, cs.outline, l.scheduleUpcoming),
    };
    final payments = decodeLinePayments(line.paymentsJson);
    final detail = [
      if (line.paidOn != null) l.scheduleLinePaidOn(f.date(line.paidOn!)),
      if (line.daysLate > 0) l.scheduleDaysLate(f.num(line.daysLate)),
      if (line.missed) l.scheduleMissed,
    ].join(' · ');
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(width: 28, child: Text(f.num(line.seq), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant))),
        Icon(icon, size: 18, color: color),
        const SizedBox(width: Space.s8),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.date(line.dueDate, withYear: true), style: t.bodyMedium),
              if (money.partlyPaid)
                Text(
                  l.schedulePaidOf(f.money(money.paidPoisha), f.money(money.leftPoisha)),
                  style: t.labelSmall!.copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              // FR-M-054: the ERP's record of the line: paid on which day, how late, or missed.
              if (detail.isNotEmpty)
                Text(
                  detail,
                  key: Key('schedule-detail-${line.seq}'),
                  style: t.labelSmall!.copyWith(color: line.missed || line.daysLate > 0 ? sc.of(AppStatus.overdue).fg : cs.onSurfaceVariant),
                ),
            ],
          ),
        ),
        Text(label, style: t.labelMedium!.copyWith(color: color)),
        const SizedBox(width: Space.s12),
        SizedBox(
          width: 96,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
            MoneyText(line.amountPoisha, style: t.bodyMedium, textAlign: TextAlign.end),
            if (line.lateFeePoisha > 0)
              Text(l.scheduleLateFee(f.money(line.lateFeePoisha)), style: t.labelSmall!.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ]),
    );
    if (payments.isEmpty) return row;
    // Tap a line to see the ERP payments that went to it (date, receipt, amount).
    return InkWell(
      key: Key('schedule-line-${line.seq}'),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(Space.s16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.scheduleLinePayments(f.num(line.seq)), style: t.titleMedium),
            const SizedBox(height: Space.s8),
            for (final p in payments)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt_long_rounded),
                title: Text(f.date(p.date, withYear: true)),
                subtitle: p.receiptNo == null ? null : Text(l.scheduleReceiptNo(p.receiptNo!)),
                trailing: MoneyText(p.amountPoisha, style: t.bodyMedium),
              ),
          ]),
        ),
      ),
      child: row,
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
          subtitle: [
            f.date(p.date, withYear: true),
            if (p.receiptNo != null) p.receiptNo!,
            if (p.methodLabel != null) p.methodLabel!,
            if (p.collectorName != null) l.timelineCollector(p.collectorName!),
            if (p.advance) l.timelineAdvance,
            if (p.reversed) l.timelineRemoved,
          ].join(' · '),
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
                            // an entry's own action (e.g. the receipt of a collection)
                            if (entries[i].trailing != null) Align(alignment: AlignmentDirectional.centerStart, child: entries[i].trailing),
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

/// Collectable plans first (newest final due first); returned and cancelled ones last.
List<PlanWithSchedule> sortedPlans(List<PlanWithSchedule> plans) => [...plans]
  ..sort((a, b) {
    final c = (a.closedInErp ? 1 : 0).compareTo(b.closedInErp ? 1 : 0);
    return c != 0 ? c : b.plan.finalDueDate.compareTo(a.plan.finalDueDate);
  });

String? _frequency(AppLocalizations l, Fmt f, PlanWithSchedule p) {
  if (p.credit || p.cash) return null;
  return switch (p.plan.frequency) {
    'monthly' => l.planFreqMonthly,
    'weekly' => l.planFreqWeekly,
    'daily' => l.planFreqDaily,
    'custom' => p.plan.customDays != null ? l.planFreqEveryNDays(f.num(p.plan.customDays!)) : l.planFreqCustom,
    _ => null,
  };
}

/// Products (with serial numbers) and the guarantor of this sale.
class _PlanFacts extends ConsumerWidget {
  const _PlanFacts({required this.plan});
  final PlanWithSchedule plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final g = plan.guarantor;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.items.isNotEmpty) ...[
            Text(l.planProducts, style: t.labelMedium!.copyWith(color: cs.onSurfaceVariant)),
            for (final it in plan.items) ...[
              Text(it.label, style: t.bodyMedium),
              if (it.serials.isNotEmpty) Text(l.planSerials(it.serials.join(', ')), style: AppTheme.mono(t.bodySmall!.copyWith(color: cs.onSurfaceVariant))),
            ],
            const SizedBox(height: Space.s8),
          ],
          if (g != null) ...[
            Text(l.planGuarantor, style: t.labelMedium!.copyWith(color: cs.onSurfaceVariant)),
            Text([if (g.name.isNotEmpty) g.name, if (g.phone.isNotEmpty) f.num(g.phone)].join(' · '), style: t.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// The ERP's own risk grade, read only, next to the status badges.
class _ErpRiskChip extends StatelessWidget {
  const _ErpRiskChip({required this.risk});
  final ErpRisk risk;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    final (fg, bg, level) = switch (risk.levelKey) {
      'high' => (sem.danger.fg, sem.danger.bg, l.erpRiskHigh),
      'medium' => (sem.warning.fg, sem.warning.bg, l.erpRiskMedium),
      'low' => (cs.onSurfaceVariant, cs.surfaceContainerHighest, l.erpRiskLow),
      _ => (cs.onSurfaceVariant, cs.surfaceContainerHighest, null),
    };
    final label = l.erpRiskBadge(risk.grade);
    // Medium and high risk say so in words too (colour + icon + label); low risk shows the grade only.
    final shown = risk.levelKey == 'medium' || risk.levelKey == 'high' ? '$label · $level' : label;
    return Semantics(
      label: [label, ?level].join(', '),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: Space.s4),
        decoration: BoxDecoration(color: bg, borderRadius: Radii.brSm),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.speed_rounded, size: 16, color: fg),
          const SizedBox(width: Space.s4),
          Text(shown, style: t.labelMedium!.copyWith(color: fg, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
