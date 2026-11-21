import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/providers.dart';
import '../../../../core/settings/ui_prefs.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/status_colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/brand.dart';
import '../../../../core/ui/common.dart';
import '../../../../l10n/app_localizations.dart';
import '../collection_providers.dart';
import '../domain/collection_rules.dart';
import 'method_visuals.dart';

/// Success screen with the receipt (design guide §5.4 / §10). Internal
/// flags are never shown here — the customer may be watching.
class CollectSuccessScreen extends ConsumerStatefulWidget {
  const CollectSuccessScreen({super.key, required this.clientId});
  final String clientId;
  @override
  ConsumerState<CollectSuccessScreen> createState() => _CollectSuccessScreenState();
}

class _CollectSuccessScreenState extends ConsumerState<CollectSuccessScreen> with SingleTickerProviderStateMixin {
  final _receiptKey = GlobalKey();
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MediaQuery.of(context).disableAnimations) {
        _anim.value = 1;
      } else {
        _anim.forward();
      }
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _share(CollectionRow c) => shareReceiptImage(_receiptKey, c.receiptNo);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final row = ref.watch(collectionProvider(widget.clientId)).value;
    if (row == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final sem = context.semanticColors;
    final synced = row.syncState == 'synced';

    return Scaffold(
      backgroundColor: cs.surfaceContainer,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Space.screen, Space.s32, Space.screen, Space.s16),
                children: [
                  Center(
                    child: ScaleTransition(
                      scale: CurvedAnimation(parent: _anim, curve: Curves.elasticOut),
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(color: sem.success.fg, shape: BoxShape.circle, boxShadow: [BoxShadow(color: sem.success.fg.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))]),
                        child: const Icon(Icons.check_rounded, size: 52, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: Space.s16),
                  Text(l.collectSuccessTitle, textAlign: TextAlign.center, style: t.titleLarge),
                  const SizedBox(height: Space.s4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(synced ? Icons.cloud_done_rounded : Icons.smartphone_rounded, size: 18, color: cs.onSurfaceVariant),
                      const SizedBox(width: Space.s4),
                      Text(synced ? l.reachedServer : l.savedOnPhone, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: Space.s24),
                  RepaintBoundary(key: _receiptKey, child: ReceiptCard(row: row)),
                  if (row.receiptNo.contains('-OFF')) ...[
                    const SizedBox(height: Space.s12),
                    InfoBanner(icon: Icons.info_outline_rounded, text: l.collectOfflineReceipt),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, Space.s16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(onPressed: () => _share(row), icon: const Icon(Icons.share_rounded), label: Text(l.actionShareReceipt)),
                  ),
                  const SizedBox(height: Space.s8),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.pushReplacement('/customers/${row.customerId}?action=promise'),
                        icon: const Icon(Icons.handshake_rounded),
                        label: Text(l.actionNewPromise),
                      ),
                    ),
                    const SizedBox(width: Space.s8),
                    Expanded(child: FilledButton(onPressed: () => context.pop(), child: Text(l.actionDone))),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shares the receipt drawn under [key] as a 1080-px-wide PNG named after the
/// receipt. The phone's share sheet sends it, saves it or prints it.
Future<void> shareReceiptImage(GlobalKey key, String receiptNo) async {
  final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return;
  final ratio = 1080 / boundary.size.width;
  final image = await boundary.toImage(pixelRatio: ratio);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) return;
  await SharePlus.instance.share(
    ShareParams(files: [XFile.fromData(bytes.buffer.asUint8List(), mimeType: 'image/png', name: '$receiptNo.png')]),
  );
}

/// The receipt of any collection on this phone, at any later time (FR-M-050):
/// opened from Today's Work and from the customer's timeline. The same card
/// the customer saw; share sends, saves or prints it. Works offline.
class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({super.key, required this.clientId});
  final String clientId;
  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  final _receiptKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final q = ref.watch(collectionProvider(widget.clientId));
    final row = q.value;
    return Scaffold(
      backgroundColor: cs.surfaceContainer,
      appBar: AppBar(title: Text(l.receiptTitle)),
      body: row == null
          ? (q.isLoading ? const Center(child: CircularProgressIndicator()) : EmptyState(icon: Icons.receipt_long_outlined, title: l.receiptNotOnPhone, body: ''))
          : SafeArea(
              child: Column(children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s16),
                    children: [
                      RepaintBoundary(key: _receiptKey, child: ReceiptCard(row: row)),
                      if (row.receiptNo.contains('-OFF')) ...[
                        const SizedBox(height: Space.s12),
                        InfoBanner(icon: Icons.info_outline_rounded, text: l.collectOfflineReceipt),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, Space.s16),
                  child: Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(onPressed: () => context.push('/customers/${row.customerId}'), icon: const Icon(Icons.person_rounded), label: Text(l.receiptOpenCustomer)),
                    ),
                    const SizedBox(width: Space.s8),
                    Expanded(
                      child: FilledButton.icon(onPressed: () => shareReceiptImage(_receiptKey, row.receiptNo), icon: const Icon(Icons.share_rounded), label: Text(l.actionShareReceipt)),
                    ),
                  ]),
                ),
              ]),
            ),
    );
  }
}

/// The field receipt (shared as a 1080-px-wide PNG).
class ReceiptCard extends ConsumerWidget {
  const ReceiptCard({super.key, required this.row});
  final CollectionRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(serverSettingsProvider);
    final method = PaymentMethodX.fromWire(row.method);
    final posted = row.status == 'posted' || row.status == 'resolved_posted';
    final user = ref.watch(_collectorProvider);
    return Container(
      decoration: BoxDecoration(color: Neutral.c0, borderRadius: Radii.brXl, border: Border.all(color: cs.outlineVariant)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(onSurface: Neutral.c900)),
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: Neutral.c900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(Space.s20, Space.s16, Space.s20, Space.s16),
                color: Brand.c600,
                child: Row(children: [
                  const BrandMark(size: 36, inverted: true),
                  const SizedBox(width: Space.s12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.appName, style: t.titleMedium!.copyWith(color: Neutral.c0)),
                      Text(l.receiptTitle, style: t.bodySmall!.copyWith(color: Brand.c100)),
                    ]),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(Space.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.receiptNo, style: AppTheme.mono(t.titleSmall!).copyWith(color: Brand.c700, letterSpacing: 0.5)),
                    Text(f.dateTime(row.recordedAt), style: t.bodySmall!.copyWith(color: Neutral.c600)),
                    const SizedBox(height: Space.s16),
                    Text(f.money(row.amountPoisha), style: AppTheme.tabular(t.headlineMedium!).copyWith(color: Neutral.c900)),
                    Text(f.words(row.amountPoisha), style: t.bodyMedium!.copyWith(color: Neutral.c700)),
                    const SizedBox(height: Space.s12),
                    const Divider(color: Neutral.c200, height: 1),
                    _line(context, l.collectReviewCustomer, '${row.customerName} · ${row.customerCode}'),
                    _line(context, l.collectReviewMethod, row.transactionRef == null ? methodLabel(l, method) : '${methodLabel(l, method)} · ${row.transactionRef}'),
                    if (user != null) _line(context, l.receiptCollector, user),
                    if (!posted)
                      Container(
                        margin: const EdgeInsets.only(top: Space.s12),
                        padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s8),
                        decoration: const BoxDecoration(color: Color(0xFFEEF1F5), borderRadius: Radii.brMd),
                        child: Row(children: [
                          const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF475569)),
                          const SizedBox(width: Space.s8),
                          Text(l.receiptPendingErp, style: t.bodySmall!.copyWith(color: const Color(0xFF475569), fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    if (settings['hotline'] != null) ...[
                      const SizedBox(height: Space.s12),
                      Text('${l.receiptHotline}: ${settings['hotline']}', style: t.bodySmall!.copyWith(color: Neutral.c600)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(BuildContext context, String k, String v) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: Space.s8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 96, child: Text(k, style: t.bodySmall!.copyWith(color: Neutral.c600))),
        Expanded(child: Text(v, style: t.bodyMedium!.copyWith(color: Neutral.c900, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

/// Collector "name · code" from the cached session user.
final _collectorProvider = FutureProvider<String?>((ref) async {
  final raw = await ref.watch(secureStoreProvider).read('session_user');
  if (raw == null) return null;
  final j = jsonDecode(raw) as Map<String, dynamic>;
  final name = (j['name'] as Map<String, dynamic>?)?['bn'] as String? ?? '';
  return '$name · ${j['employeeCode'] ?? ''}';
}).select((v) => v.value);
