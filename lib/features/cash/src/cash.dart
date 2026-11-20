import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/format/money.dart';
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

class DepositPushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'deposit'};
  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) =>
      (db.update(db.deposits)..where((t) => t.clientId.equals(m.mutationId))).write(
        DepositsCompanion(serverId: Value(r.entityId), syncState: Value(r.result == 'rejected' ? 'failed' : 'synced')),
      );
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
        ));
  }

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) async {}
}

final depositsProvider = StreamProvider<List<DepositRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.deposits)..orderBy([(t) => OrderingTerm.desc(t.depositedAt)])..limit(30)).watch();
});

/// Records a deposit offline-first (FR-CASH-002).
Future<void> recordDeposit(WidgetRef ref, {required int amountPoisha, required String destination, String? reference}) async {
  final db = ref.read(databaseProvider);
  final clock = ref.read(clockProvider);
  final id = const Uuid().v7();
  final at = clock.nowUtc();
  final fix = await ref.read(locationEngineProvider).currentFix(timeout: const Duration(seconds: 8));
  await db.transaction(() async {
    await db.into(db.deposits).insert(DepositsCompanion.insert(
          clientId: id,
          amountPoisha: amountPoisha,
          destination: destination,
          reference: Value(reference),
          depositedAt: at,
        ));
    await ref.read(outboxWriterProvider).enqueue(mutationId: id, entity: 'deposit', payload: {
      'clientId': id,
      'amountPoisha': amountPoisha,
      'destination': destination,
      'reference': ?reference,
      'depositedAt': at.toIso8601String(),
      'geo': ?fix?.toJson(),
    });
  });
  unawaited(ref.read(syncEngineProvider).kick(reason: 'money'));
}

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
          for (final d in deposits.take(3))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.savings_outlined),
              title: MoneyText(d.amountPoisha, style: t.bodyLarge!.copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text(f.dateTime(d.depositedAt)),
              trailing: StatusBadge(
                d.status == 'verified' ? AppStatus.paid : (d.status == 'rejected' ? AppStatus.overdue : AppStatus.pending),
                dense: true,
                label: d.status == 'verified' ? l.statusPosted : (d.status == 'rejected' ? l.statusRejected : (d.syncState == 'synced' ? l.statusPending : l.statusQueued)),
              ),
            ),
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

Future<void> showDepositSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _DepositSheet(),
    );

class _DepositSheet extends ConsumerStatefulWidget {
  const _DepositSheet();
  @override
  ConsumerState<_DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends ConsumerState<_DepositSheet> {
  final _amount = TextEditingController();
  final _ref = TextEditingController();
  String _dest = 'branch_cashier';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final c = ref.read(cashOnHandProvider).value;
    if (c != null && c.onHand > 0) _amount.text = '${c.onHand ~/ 100}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final f = ref.watch(fmtProvider);
    final poisha = parseMoneyInput(_amount.text) ?? 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(Space.s24, 0, Space.s24, MediaQuery.of(context).viewInsets.bottom + Space.s24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.cashDepositTitle, style: t.titleLarge),
        const SizedBox(height: Space.s16),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          style: t.headlineSmall,
          decoration: InputDecoration(prefixText: '৳ ', labelText: l.promiseAmount, helperText: poisha > 0 ? f.words(poisha) : null),
        ),
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
        FilledButton(
          onPressed: poisha <= 0 || _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  await recordDeposit(ref, amountPoisha: poisha, destination: _dest, reference: _ref.text.trim().isEmpty ? null : _ref.text.trim());
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  showAppSnack(context, l.cashDepositSaved);
                },
          child: Text(l.actionSave),
        ),
      ]),
    );
  }
}
