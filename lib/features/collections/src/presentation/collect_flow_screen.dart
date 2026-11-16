import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/location/location_engine.dart';
import '../../../../core/providers.dart';
import '../../../../core/settings/ui_prefs.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/status_colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/amount_keypad.dart';
import '../../../../core/ui/common.dart';
import '../../../../core/ui/hold_to_confirm.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/customers.dart';
import '../application/record_collection.dart';
import '../collection_providers.dart';
import '../domain/collection_rules.dart';
import 'method_visuals.dart';

/// Full-screen 3-step collect flow (design guide §5.4, FR-M-006).
class CollectFlowScreen extends ConsumerStatefulWidget {
  const CollectFlowScreen({super.key, required this.customerId});
  final String customerId;
  @override
  ConsumerState<CollectFlowScreen> createState() => _CollectFlowScreenState();
}

class _CollectFlowScreenState extends ConsumerState<CollectFlowScreen> {
  int _step = 0;
  String _amount = ''; // taka digits
  PaymentMethod _method = PaymentMethod.cash;
  String? _planId;
  final _txn = TextEditingController();
  final _paper = TextEditingController();
  final _payer = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;
  Future<GeoFix?>? _fix;

  int get _poisha => (int.tryParse(_amount) ?? 0) * 100;

  @override
  void dispose() {
    _txn.dispose();
    _paper.dispose();
    _payer.dispose();
    _note.dispose();
    super.dispose();
  }

  void _go(int step) {
    HapticFeedback.selectionClick();
    if (step == 2) _fix ??= ref.read(locationEngineProvider).currentFix();
    setState(() => _step = step);
  }

  Future<void> _confirm(Customer c) async {
    if (_saving) return;
    setState(() => _saving = true);
    final fix = await (_fix ?? Future.value(null));
    try {
      final r = await ref.read(recordCollectionProvider)(
        CollectionInput(
          customerId: c.id,
          customerName: c.row.nameBn,
          customerCode: c.code,
          erpPlanId: _planId,
          amountPoisha: _poisha,
          method: _method,
          txnRef: _txn.text,
          physicalReceiptNo: _paper.text.trim().isEmpty ? null : _paper.text.trim(),
          payerName: _payer.text.trim().isEmpty ? null : _payer.text.trim(),
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          outstandingPoisha: c.outstanding,
        ),
        fix: fix,
        noFixReason: fix == null ? ref.read(locationEngineProvider).lastFailureReason : null,
      );
      unawaited(HapticFeedback.heavyImpact());
      if (mounted) context.pushReplacement('/collect/success/${r.clientId}');
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnack(context, AppLocalizations.of(context).errorGeneric, icon: Icons.error_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = ref.watch(customerProvider(widget.customerId)).value;
    final plans = ref.watch(customerPlansProvider(widget.customerId)).value ?? const <PlanWithSchedule>[];
    if (c == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    _planId ??= plans.isNotEmpty ? plans.first.plan.erpPlanId : null;
    final steps = [l.collectStepAmount, l.collectStepMethod, l.collectStepReview];

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0) _go(_step - 1);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          leading: IconButton(
            tooltip: _step == 0 ? l.actionCancel : l.actionBack,
            icon: Icon(_step == 0 ? Icons.close_rounded : Icons.arrow_back_rounded),
            onPressed: () => _step == 0 ? context.pop() : _go(_step - 1),
          ),
          title: Text(l.collectTitle),
        ),
        body: Column(
          children: [
            _StepIndicator(steps: steps, current: _step),
            _CustomerStrip(customer: c),
            Expanded(
              child: AnimatedSwitcher(
                duration: Motion.base,
                switchInCurve: Motion.standard,
                child: switch (_step) {
                  0 => _AmountStep(
                    key: const ValueKey(0),
                    customer: c,
                    plans: plans,
                    planId: _planId,
                    onPlan: (p) => setState(() => _planId = p),
                    amount: _amount,
                    onAmount: (v) => setState(() => _amount = v),
                    onNext: _poisha > 0 ? () => _go(1) : null,
                  ),
                  1 => _MethodStep(
                    key: const ValueKey(1),
                    method: _method,
                    onMethod: (m) => setState(() => _method = m),
                    txn: _txn,
                    paper: _paper,
                    payer: _payer,
                    note: _note,
                    onNext: () => _go(2),
                  ),
                  _ => _ReviewStep(
                    key: const ValueKey(2),
                    customer: c,
                    plan: plans.where((p) => p.plan.erpPlanId == _planId).firstOrNull,
                    poisha: _poisha,
                    method: _method,
                    txn: _txn.text,
                    fix: _fix,
                    saving: _saving,
                    onConfirm: () => _confirm(c),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.steps, required this.current});
  final List<String> steps;
  final int current;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.screen, 0, Space.screen, Space.s12),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: Motion.base,
                    height: 4,
                    decoration: BoxDecoration(color: i <= current ? cs.primary : cs.surfaceContainerHighest, borderRadius: Radii.brXs),
                  ),
                  const SizedBox(height: Space.s4),
                  Text(steps[i], style: t.labelMedium!.copyWith(color: i == current ? cs.primary : cs.onSurfaceVariant)),
                ],
              ),
            ),
            if (i < steps.length - 1) const SizedBox(width: Space.s8),
          ],
        ],
      ),
    );
  }
}

class _CustomerStrip extends ConsumerWidget {
  const _CustomerStrip({required this.customer});
  final Customer customer;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final f = ref.watch(fmtProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Space.screen),
      padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s8),
      decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: Radii.brLg),
      child: Row(
        children: [
          Icon(Icons.person_rounded, color: cs.onSurfaceVariant, size: 20),
          const SizedBox(width: Space.s8),
          Expanded(
            child: Text(
              '${customer.nameOf(lang)} · ${customer.code}',
              style: t.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(f.money(customer.outstanding), style: AppTheme.tabular(t.bodyMedium!.copyWith(color: cs.onSurfaceVariant))),
        ],
      ),
    );
  }
}

class _AmountStep extends ConsumerWidget {
  const _AmountStep({
    super.key,
    required this.customer,
    required this.plans,
    required this.planId,
    required this.onPlan,
    required this.amount,
    required this.onAmount,
    required this.onNext,
  });
  final Customer customer;
  final List<PlanWithSchedule> plans;
  final String? planId;
  final ValueChanged<String> onPlan;
  final String amount;
  final ValueChanged<String> onAmount;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final poisha = (int.tryParse(amount) ?? 0) * 100;
    final over = poisha > customer.outstanding && customer.outstanding > 0;
    final chips = <(String, int)>[
      if (customer.installment != null && customer.installment! > 0) (l.collectChipInstallment(f.money(customer.installment!)), customer.installment!),
      if (customer.overdueAmount > 0) (l.collectChipOverdue(f.money(customer.overdueAmount)), customer.overdueAmount),
      if (customer.row.openPromisePoisha != null) (l.collectChipPromise(f.money(customer.row.openPromisePoisha!)), customer.row.openPromisePoisha!),
    ];
    return Column(
      children: [
        if (plans.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.screen, Space.s12, Space.screen, 0),
            child: DropdownButtonFormField<String>(
              initialValue: planId,
              items: [for (final p in plans) DropdownMenuItem(value: p.plan.erpPlanId, child: Text(p.plan.product))],
              onChanged: (v) => v == null ? null : onPlan(v),
            ),
          ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  liveRegion: true,
                  label: poisha == 0 ? l.collectEnterAmount : f.words(poisha),
                  child: ExcludeSemantics(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        poisha == 0 ? f.money(0) : f.money(poisha),
                        style: AppTheme.tabular(t.displaySmall!.copyWith(color: poisha == 0 ? cs.outline : cs.onSurface, fontSize: 44)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Space.s4),
                SizedBox(
                  height: 24,
                  child: Text(poisha == 0 ? l.collectEnterAmount : f.words(poisha), style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                ),
                if (over)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Space.s24, Space.s8, Space.s24, 0),
                    child: InfoBanner(icon: Icons.info_rounded, text: l.collectOverOutstanding, tone: BannerTone.warning),
                  ),
              ],
            ),
          ),
        ),
        if (chips.isNotEmpty)
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Space.screen),
              children: [
                for (final (label, value) in chips)
                  Padding(
                    padding: const EdgeInsets.only(right: Space.s8),
                    child: ActionChip(
                      avatar: Icon(Icons.bolt_rounded, size: 18, color: cs.primary),
                      label: Text(label),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onAmount('${value ~/ 100}');
                      },
                    ),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, Space.s8),
          child: AmountKeypad(value: amount, onChanged: onAmount),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Space.screen, 0, Space.screen, Space.s16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: onNext, child: Text(l.actionContinue)),
            ),
          ),
        ),
      ],
    );
  }
}

class _MethodStep extends StatelessWidget {
  const _MethodStep({
    super.key,
    required this.method,
    required this.onMethod,
    required this.txn,
    required this.paper,
    required this.payer,
    required this.note,
    required this.onNext,
  });
  final PaymentMethod method;
  final ValueChanged<PaymentMethod> onMethod;
  final TextEditingController txn;
  final TextEditingController paper;
  final TextEditingController payer;
  final TextEditingController note;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s16),
            children: [
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: Space.s8,
                crossAxisSpacing: Space.s8,
                childAspectRatio: 1.05,
                children: [
                  for (final m in PaymentMethod.values)
                    _MethodTile(
                      method: m,
                      selected: m == method,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onMethod(m);
                      },
                    ),
                ],
              ),
              if (method.needsTxnRef) ...[
                const SizedBox(height: Space.s20),
                ListenableBuilder(
                  listenable: txn,
                  builder: (context, _) => TextField(
                    controller: txn,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), _UpperCase()],
                    style: AppTheme.mono(t.bodyLarge!),
                    decoration: InputDecoration(
                      labelText: l.collectTxnId,
                      prefixIcon: const Icon(Icons.tag_rounded),
                      errorText: txn.text.length >= 8 && !isValidTxnRef(txn.text) ? l.collectTxnInvalid : null,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: Space.s16),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(l.collectNote, style: t.titleSmall!.copyWith(color: cs.onSurfaceVariant)),
                  children: [
                    TextField(
                      controller: paper,
                      decoration: InputDecoration(labelText: l.collectPhysicalReceipt),
                    ),
                    const SizedBox(height: Space.s12),
                    TextField(
                      controller: payer,
                      decoration: InputDecoration(labelText: l.collectPayerName),
                    ),
                    const SizedBox(height: Space.s12),
                    TextField(
                      controller: note,
                      maxLength: 500,
                      maxLines: 2,
                      decoration: InputDecoration(labelText: l.collectNote),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Space.screen, 0, Space.screen, Space.s16),
            child: ListenableBuilder(
              listenable: txn,
              builder: (_, _) => SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: !method.needsTxnRef || isValidTxnRef(txn.text) ? onNext : null, child: Text(l.actionContinue)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UpperCase extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) => newValue.copyWith(text: newValue.text.toUpperCase());
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.method, required this.selected, required this.onTap});
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final accent = methodColor(method);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? accent.withValues(alpha: 0.10) : cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.brXl,
          side: BorderSide(color: selected ? accent : cs.outlineVariant, width: selected ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: Radii.brXl,
          onTap: onTap,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), shape: BoxShape.circle),
                      child: Icon(methodIcon(method), color: accent),
                    ),
                    const SizedBox(height: Space.s8),
                    Text(methodLabel(l, method), style: t.labelLarge, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (selected)
                Positioned(
                  top: Space.s8,
                  right: Space.s8,
                  child: Icon(Icons.check_circle_rounded, color: accent, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewStep extends ConsumerWidget {
  const _ReviewStep({
    super.key,
    required this.customer,
    required this.plan,
    required this.poisha,
    required this.method,
    required this.txn,
    required this.fix,
    required this.saving,
    required this.onConfirm,
  });
  final Customer customer;
  final PlanWithSchedule? plan;
  final int poisha;
  final PaymentMethod method;
  final String txn;
  final Future<GeoFix?>? fix;
  final bool saving;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final cash = ref.watch(cashOnHandProvider).value;
    final settings = ref.watch(serverSettingsProvider);
    final blockOverLimit = settings['cashBlockOverLimit'] == true;
    final overLimit = method == PaymentMethod.cash && cash != null && cash.limit > 0 && cash.onHand + poisha > cash.limit;
    final blocked = overLimit && blockOverLimit;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Space.s20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.collectReviewAmount, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                      Text(f.money(poisha), style: AppTheme.tabular(t.displaySmall!)),
                      Text(
                        f.words(poisha),
                        style: t.bodyLarge!.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: Space.s12),
                      const Divider(height: 1),
                      const SizedBox(height: Space.s4),
                      KeyValueRow(label: l.collectReviewCustomer, value: Text('${customer.nameOf(lang)}\n${customer.code}')),
                      if (plan != null) KeyValueRow(label: l.collectReviewPlan, value: Text(plan!.plan.product)),
                      KeyValueRow(
                        label: l.collectReviewMethod,
                        value: Row(
                          children: [
                            Icon(methodIcon(method), size: 18, color: methodColor(method)),
                            const SizedBox(width: Space.s8),
                            Flexible(child: Text(method.needsTxnRef ? '${methodLabel(l, method)} · ${normalizeTxnRef(txn)}' : methodLabel(l, method))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Space.cardGap),
              FutureBuilder<GeoFix?>(
                future: fix,
                builder: (context, snap) {
                  final sem = context.semanticColors;
                  if (snap.connectionState != ConnectionState.done) {
                    return InfoBanner(
                      icon: Icons.my_location_rounded,
                      text: l.collectGpsSearching,
                      trailing: const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  final g = snap.data;
                  if (g == null) return InfoBanner(icon: Icons.location_disabled_rounded, text: l.collectGpsNone, tone: BannerTone.warning);
                  if (g.mock) return InfoBanner(icon: Icons.gpp_maybe_rounded, text: l.collectGpsMock, tone: BannerTone.danger);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s12),
                    decoration: BoxDecoration(color: sem.success.bg, borderRadius: Radii.brLg),
                    child: Row(
                      children: [
                        Icon(Icons.gps_fixed_rounded, color: sem.success.fg),
                        const SizedBox(width: Space.s12),
                        Text(
                          l.collectGpsAccurate(f.num(g.accuracyM.round())),
                          style: t.bodyMedium!.copyWith(color: sem.success.fg, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (overLimit) ...[
                const SizedBox(height: Space.cardGap),
                InfoBanner(
                  icon: Icons.account_balance_wallet_rounded,
                  text: blocked ? l.collectCashLimitBlocked : l.todayCashWarning(f.num(((cash.onHand + poisha) * 100 / cash.limit).round())),
                  tone: blocked ? BannerTone.danger : BannerTone.warning,
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Space.screen, 0, Space.screen, Space.s16),
            child: saving
                ? const SizedBox(
                    height: Sizes.primaryButton,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : HoldToConfirmButton(label: l.collectHoldToConfirm, holdingLabel: l.collectHoldHint, enabled: !blocked, onConfirmed: onConfirm),
          ),
        ),
      ],
    );
  }
}
