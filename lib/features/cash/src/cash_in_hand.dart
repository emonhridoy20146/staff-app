import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/format/money.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import 'cash_actions.dart';
import 'cash_in_hand_data.dart';

/// "কোন আদায়ের টাকা হাতে আছে" (FR-M-049): the collections behind my cash on
/// hand, each with its customer, invoice and receipt. A tap opens the
/// customer.
class CashInHandScreen extends ConsumerStatefulWidget {
  const CashInHandScreen({super.key});
  @override
  ConsumerState<CashInHandScreen> createState() => _CashInHandScreenState();
}

class _CashInHandScreenState extends ConsumerState<CashInHandScreen> {
  CashInHand? _data;
  CashInHandError? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final (data, err) = await ref.read(cashInHandServiceProvider).load();
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
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final d = _data;
    // Cash this phone has taken or handed in that the server has not counted yet.
    final local = ref.watch(cashOnHandProvider).value;
    final unsent = local != null && local.onHand != local.serverOnHand;
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(title: Text(l.cashInHandTitle)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
          children: [
            if (d == null && _loading)
              const Padding(padding: EdgeInsets.all(Space.s48), child: Center(child: CircularProgressIndicator()))
            else if (d == null)
              EmptyState(
                icon: _error == CashInHandError.offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                title: _error == CashInHandError.offline ? l.cashInHandOffline : l.errorGeneric,
                body: '',
                action: OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh_rounded), label: Text(l.actionRetry)),
              )
            else ...[
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.cashOnHand, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                  Text(f.money(d.onHandPoisha), style: AppTheme.tabular(t.headlineMedium!)),
                  Text(l.boardCount(f.num(d.count)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                  if (d.pendingDepositsPoisha > 0) ...[
                    const SizedBox(height: Space.s8),
                    Text(l.cashInHandPendingDeposits(f.money(d.pendingDepositsPoisha)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ]),
              ),
              if (unsent) ...[
                const SizedBox(height: Space.cardGap),
                InfoBanner(icon: Icons.cloud_upload_outlined, tone: BannerTone.warning, text: l.cashInHandUnsent),
              ],
              const SizedBox(height: Space.cardGap),
              if (d.items.isEmpty)
                EmptyState(icon: Icons.account_balance_wallet_outlined, title: l.cashInHandEmpty, body: '')
              else
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(children: [
                    for (var i = 0; i < d.items.length; i++) ...[
                      if (i > 0) const Divider(height: 1, indent: Space.s16, endIndent: Space.s16),
                      _Tile(item: d.items[i], lang: lang, onChanged: _load),
                    ],
                  ]),
                ),
              if (d.notListed > 0) ...[
                const SizedBox(height: Space.s12),
                Text(l.cashInHandMore(f.num(d.notListed)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
              ],
              const SizedBox(height: Space.s12),
              Text(l.cashInHandHow, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tile extends ConsumerWidget {
  const _Tile({required this.item, required this.lang, required this.onChanged});
  final CashInHandItem item;
  final String lang;
  final Future<void> Function() onChanged;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final id = item.customerId;
    final lines = [
      if (item.erpPlanId.isNotEmpty) l.cashInHandInvoice(item.erpPlanId),
      if (item.recordedAt != null) f.dateTime(item.recordedAt!),
    ];
    return ListTile(
      onTap: id == null ? null : () => context.push('/customers/$id'),
      minTileHeight: Sizes.row2,
      title: Text(item.nameOf(lang), style: t.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(lines.join(' · '), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(item.receiptNo, style: AppTheme.tabular(t.bodySmall!).copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
          Text(f.money(item.inHandPoisha), style: AppTheme.tabular(t.titleMedium!)),
          if (item.partly) Text(l.cashInHandPartOf(f.money(item.amountPoisha)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        ]),
        // Until a deposit covers it, the cash can still be changed or deleted (FR-M-058).
        if (!item.partly && item.collectionId.isNotEmpty)
          PopupMenuButton<String>(
            tooltip: '',
            onSelected: (v) => v == 'edit' ? _edit(context, ref) : _delete(context, ref),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: ListTile(leading: const Icon(Icons.edit_rounded), title: Text(l.cashActionEdit), contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'delete', child: ListTile(leading: const Icon(Icons.delete_outline_rounded), title: Text(l.cashActionDelete), contentPadding: EdgeInsets.zero)),
            ],
          ),
      ]),
    );
  }

  void _say(BuildContext context, CashActionError? e) {
    final l = AppLocalizations.of(context);
    if (e == null) return showAppSnack(context, l.cashActionDone, icon: Icons.check_circle_rounded);
    final text = switch (e) {
      CashActionError.offline => l.cashActionOffline,
      CashActionError.covered => l.cashActionCovered,
      CashActionError.notEditable => l.cashActionNotEditable,
      CashActionError.posted => l.cashActionPosted,
      CashActionError.busy => l.cashActionBusy,
      CashActionError.notAllowed => l.cashActionNotAllowed,
      CashActionError.failed => l.cashActionFailed,
    };
    showAppSnack(context, text, icon: Icons.error_outline_rounded);
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final amount = TextEditingController(text: item.amountPoisha % 100 == 0 ? '${item.amountPoisha ~/ 100}' : (item.amountPoisha / 100).toStringAsFixed(2));
    final note = TextEditingController();
    final payer = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.cashEditTitle),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: l.cashEditAmount)),
            const SizedBox(height: Space.s12),
            TextField(controller: payer, decoration: InputDecoration(labelText: l.cashEditPayer)),
            const SizedBox(height: Space.s12),
            TextField(controller: note, decoration: InputDecoration(labelText: l.cashEditNote)),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.cashEditSave)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final poisha = parseMoneyInput(amount.text);
    final changed = poisha != null && poisha > 0 && poisha != item.amountPoisha ? poisha : null;
    final n = note.text.trim().isEmpty ? null : note.text.trim();
    final p = payer.text.trim().isEmpty ? null : payer.text.trim();
    if (changed == null && n == null && p == null) return;
    final err = await ref.read(cashActionsServiceProvider).edit(item.collectionId, customerId: item.customerId ?? '', oldAmountPoisha: item.amountPoisha, amountPoisha: changed, note: n, payerName: p);
    if (!context.mounted) return;
    _say(context, err);
    if (err == null) await onChanged();
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final f = ref.read(fmtProvider);
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.cashDeleteTitle),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.cashDeleteBody(f.money(item.amountPoisha), item.nameOf(lang))),
          const SizedBox(height: Space.s12),
          TextField(controller: reason, decoration: InputDecoration(labelText: l.cashDeleteReason)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.actionCancel)),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Theme.of(c).colorScheme.error, foregroundColor: Theme.of(c).colorScheme.onError), onPressed: () => Navigator.pop(c, true), child: Text(l.cashDeleteConfirm)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final err = await ref.read(cashActionsServiceProvider).withdraw(item.collectionId, customerId: item.customerId ?? '', amountPoisha: item.amountPoisha, reason: reason.text.trim().isEmpty ? null : reason.text.trim());
    if (!context.mounted) return;
    _say(context, err);
    if (err == null) await onChanged();
  }
}
