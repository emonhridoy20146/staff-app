import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/sync/sync_handlers.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../core/ui/money_text.dart';
import '../../../core/ui/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../collections/collections.dart';
import 'deposit_rules.dart';
import 'record_deposit.dart';

class DepositPushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'deposit'};
  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) async {
    if (r.result == 'rejected') {
      // FR-M-059: the server refused the deposit (e.g. DEPOSIT_MUST_BE_ALL because something changed
      // meanwhile). It stays in Problems with its reason; the collections it locked are back in hand.
      await (db.update(db.deposits)..where((t) => t.clientId.equals(m.mutationId)))
          .write(DepositsCompanion(syncState: const Value('failed'), failureCode: Value(depositFailureCode(r.error))));
      await (db.update(db.collections)..where((t) => t.depositId.equals(m.mutationId)))
          .write(const CollectionsCompanion(depositId: Value(null), depositedAt: Value(null)));
      return;
    }
    await (db.update(db.deposits)..where((t) => t.clientId.equals(m.mutationId))).write(
      DepositsCompanion(serverId: Value(r.entityId), syncState: const Value('synced'), failureCode: const Value(null)),
    );
  }
}

class DepositPullHandler implements PullHandler {
  @override
  String get entity => 'deposit';
  @override
  Future<void> upsert(AppDatabase db, String id, Json d) async {
    final clientId = (d['clientId'] as String?) ?? id;
    await db.into(db.deposits).insertOnConflictUpdate(DepositsCompanion.insert(
          clientId: clientId,
          serverId: Value(id),
          amountPoisha: (d['amountPoisha'] as num).toInt(),
          destination: (d['destination'] as String?) ?? 'branch_cashier',
          reference: Value(d['reference'] as String?),
          depositedAt: DateTime.parse(d['depositedAt'] as String).toUtc(),
          status: Value((d['status'] as String?) ?? 'pending'),
          rejectReason: Value(d['rejectReason'] as String?),
          syncState: const Value('synced'),
          // 1.35.0: what it handed in besides cash; absent on deposits from before.
          collectionCount: Value((d['collectionCount'] as num?)?.toInt()),
          nonCashPoisha: Value((d['nonCashPoisha'] as num?)?.toInt()),
          nonCashCount: Value((d['nonCashCount'] as num?)?.toInt()),
        ));
  }

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) async {}
}

final depositsProvider = StreamProvider<List<DepositRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.deposits)..orderBy([(t) => OrderingTerm.desc(t.depositedAt)])..limit(30)).watch();
});

/// One deposit by its clientId (= its outbox mutation id), e.g. for Problems.
final depositByClientIdProvider = StreamProvider.family<DepositRow?, String>((ref, clientId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.deposits)..where((t) => t.clientId.equals(clientId))).watchSingleOrNull();
});

/// A deposit saved on this phone and not sent yet: until it is, nothing in hand may be changed.
final unsentDepositProvider = StreamProvider<bool>((ref) => ref.watch(outboxReaderProvider).watchUnsentOf('deposit').map((n) => n > 0));

/// What a deposit would take now; follows the cash meter and my collections in hand.
final depositPlanProvider = StreamProvider<DepositPlan>((ref) {
  final cash = ref.watch(cashOnHandProvider).value;
  final db = ref.watch(databaseProvider);
  final q = db.select(db.collections)..where((t) => t.depositId.isNull() & t.status.isIn(inHandStatuses));
  return q.watch().map((rows) => planDeposit(cashOnHandPoisha: cash?.onHand ?? 0, inHand: [for (final r in rows) (method: r.method, amountPoisha: r.amountPoisha)]));
});

/// The message for a deposit the server refused (Problems, FR-M-059).
String depositFailureText(AppLocalizations l, String? code) => switch (depositFailureOf(code)) {
      DepositFailure.mustBeAll => l.depositFailedMustBeAll,
      DepositFailure.exceedsOnHand => l.depositFailedExceeds,
      DepositFailure.nothing => l.depositFailedNothing,
      DepositFailure.slipRequired => l.depositFailedSlip,
      DepositFailure.changed => l.depositFailedChanged,
      DepositFailure.other => l.depositFailedOther(code ?? '—'),
    };

/// Cash meter: on hand vs limit, warning colour ≥ 80 %.
class CashMeter extends ConsumerWidget {
  const CashMeter({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    final cash = ref.watch(cashOnHandProvider).value;
    if (cash == null) return const SizedBox.shrink();
    final state = cashState(cash.onHand, cash.limit);
    final color = switch (state) {
      CashState.exceeded => sem.danger.fg,
      CashState.warning => sem.warning.fg,
      CashState.ok => cs.primary,
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Text(l.cashOnHand, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
        const Spacer(),
        if (cash.limit > 0) Text(l.cashLimit(f.money(cash.limit)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
      ]),
      MoneyText(cash.onHand, style: compact ? t.titleMedium : t.headlineMedium),
      const SizedBox(height: Space.s8),
      ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(Radii.full)),
        child: LinearProgressIndicator(value: cash.ratio.clamp(0, 1).toDouble(), color: color, minHeight: 8),
      ),
    ]);
  }
}

class CashCard extends ConsumerWidget {
  const CashCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final totals = ref.watch(todayTotalsProvider).value ?? const DayTotals();
    final deposits = ref.watch(depositsProvider).value ?? const <DepositRow>[];
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.account_balance_wallet_rounded, color: cs.primary),
          const SizedBox(width: Space.s8),
          Text(l.meCash, style: t.titleMedium),
        ]),
        const SizedBox(height: Space.s12),
        const CashMeter(),
        const SizedBox(height: Space.s12),
        Row(children: [
          Expanded(child: _Small(label: l.cashTodayCash, value: f.money(totals.cash))),
          Expanded(child: _Small(label: l.cashTodayMobile, value: f.money(totals.mobile))),
        ]),
        const SizedBox(height: Space.s12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(onPressed: () => showDepositSheet(context), icon: const Icon(Icons.savings_rounded), label: Text(l.cashDeposit)),
        ),
        // FR-M-049: which customers and invoices the cash on hand came from
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(onPressed: () => context.push('/cash/in-hand'), icon: const Icon(Icons.receipt_long_rounded), label: Text(l.cashInHandOpen)),
        ),
        if (deposits.isNotEmpty) ...[
          const SizedBox(height: Space.s12),
          Text(l.cashDeposits, style: t.titleSmall),
          for (final d in deposits.take(3)) _DepositTile(d),
        ],
      ]),
    );
  }
}

class _Small extends StatelessWidget {
  const _Small({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: t.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      Text(value, style: t.titleSmall),
    ]);
  }
}

class _DepositTile extends ConsumerWidget {
  const _DepositTile(this.d);
  final DepositRow d;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final (status, label) = switch (depositStateOf(status: d.status, syncState: d.syncState)) {
      DepositState.onPhone => (AppStatus.pending, l.statusQueued),
      DepositState.failed => (AppStatus.overdue, l.statusDepositFailed),
      DepositState.deposited => (AppStatus.paid, l.statusDeposited),
      DepositState.verified => (AppStatus.paid, l.statusPosted),
      DepositState.rejected => (AppStatus.overdue, l.statusRejected),
      DepositState.deleted => (AppStatus.overdue, l.statusDeleted),
    };
    final count = d.collectionCount;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.savings_outlined),
      title: MoneyText(d.amountPoisha, style: t.bodyLarge!.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text([f.dateTime(d.depositedAt), if (count != null) l.cashDepositLine(f.num(count), f.money(d.nonCashPoisha ?? 0))].join('\n')),
      trailing: StatusBadge(status, dense: true, label: label),
    );
  }
}

/// FR-M-059: one deposit that hands in everything in hand (no amount to type, no part deposit).
Future<void> showDepositSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _DepositSheet(),
    );

/// The confirm before a deposit is saved: what goes, that it goes to the ERP as payments (now when
/// online, else as soon as the phone is online) and that it cannot be changed or deleted after.
class DepositConfirmDialog extends ConsumerWidget {
  const DepositConfirmDialog({super.key, required this.plan, required this.online});
  final DepositPlan plan;
  final bool online;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final cash = f.money(plan.cashPoisha), nonCash = f.money(plan.nonCashPoisha), count = f.num(plan.collectionCount);
    return AlertDialog(
      icon: const Icon(Icons.savings_rounded),
      title: Text(l.cashDepositConfirmTitle),
      content: Text(online ? l.cashDepositConfirmOnline(cash, nonCash, count) : l.cashDepositConfirmOffline(cash, nonCash, count)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.actionCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.cashDepositSubmit)),
      ],
    );
  }
}

class _DepositSheet extends ConsumerStatefulWidget {
  const _DepositSheet();
  @override
  ConsumerState<_DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends ConsumerState<_DepositSheet> {
  final _ref = TextEditingController();
  String _dest = 'branch_cashier';
  bool _busy = false;

  @override
  void dispose() {
    _ref.dispose();
    super.dispose();
  }

  Future<void> _submit(DepositPlan plan) async {
    final l = AppLocalizations.of(context);
    final online = (ref.read(syncStatusProvider).value ?? ref.read(syncEngineProvider).current).online;
    final ok = await showDialog<bool>(context: context, builder: (_) => DepositConfirmDialog(plan: plan, online: online));
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final reference = _ref.text.trim().isEmpty ? null : _ref.text.trim();
    final r = await ref.read(recordDepositProvider).call(shown: plan, destination: _dest, reference: reference);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case DepositSaveResult.saved:
        Navigator.of(context).pop();
        showAppSnack(context, l.cashDepositSaved, icon: Icons.check_circle_rounded);
      case DepositSaveResult.changed:
        showAppSnack(context, l.cashDepositChanged, icon: Icons.error_outline_rounded);
      case DepositSaveResult.nothing:
        showAppSnack(context, l.cashDepositNothing, icon: Icons.error_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final plan = ref.watch(depositPlanProvider).value;
    return Padding(
      padding: EdgeInsets.fromLTRB(Space.s24, 0, Space.s24, MediaQuery.of(context).viewInsets.bottom + Space.s24),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.cashDepositTitle, style: t.titleLarge),
          const SizedBox(height: Space.s16),
          if (plan == null)
            const Center(child: CircularProgressIndicator())
          else if (plan.isEmpty)
            Text(l.cashDepositNothing, style: t.bodyLarge)
          else ...[
            // The amount is fixed: all the cash in hand (the server refuses anything else).
            Text(l.cashDepositCash, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
            MoneyText(plan.cashPoisha, style: t.headlineSmall),
            if (plan.cashPoisha > 0) Text(f.words(plan.cashPoisha), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: Space.s12),
            Text(l.cashDepositNonCash, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
            Row(children: [
              MoneyText(plan.nonCashPoisha, style: t.titleMedium),
              const SizedBox(width: Space.s8),
              Text(l.cashDepositNonCashCount(f.num(plan.nonCashCount)), style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
            ]),
            const SizedBox(height: Space.s8),
            Text(l.cashDepositTotalCount(f.num(plan.collectionCount)), style: t.titleSmall),
            const SizedBox(height: Space.s8),
            Text(l.cashDepositAllHint, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          ],
          const SizedBox(height: Space.s16),
          Text(l.cashDepositTo, style: t.titleSmall),
          const SizedBox(height: Space.s8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'branch_cashier', label: Text(l.cashDestCashier)),
              ButtonSegment(value: 'bank', label: Text(l.cashDestBank)),
              ButtonSegment(value: 'manager', label: Text(l.cashDestManager)),
            ],
            selected: {_dest},
            onSelectionChanged: (s) => setState(() => _dest = s.first),
          ),
          const SizedBox(height: Space.s16),
          TextField(controller: _ref, decoration: InputDecoration(labelText: l.cashReference)),
          const SizedBox(height: Space.s24),
          FilledButton.icon(
            onPressed: plan == null || plan.isEmpty || _busy ? null : () => _submit(plan),
            icon: const Icon(Icons.savings_rounded),
            label: Text(l.cashDepositSubmit),
          ),
        ]),
      ),
    );
  }
}
