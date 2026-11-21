import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
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
                      _Tile(item: d.items[i], lang: lang),
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
  const _Tile({required this.item, required this.lang});
  final CashInHandItem item;
  final String lang;
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
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
        Text(f.money(item.inHandPoisha), style: AppTheme.tabular(t.titleMedium!)),
        if (item.partly) Text(l.cashInHandPartOf(f.money(item.amountPoisha)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
      ]),
    );
  }
}
