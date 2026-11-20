import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/settings/ui_prefs.dart';
import '../../core/theme/status_colors.dart';
import '../../core/ui/status_badge.dart';
import '../../core/ui/common.dart';
import '../../l10n/app_localizations.dart';
import 'src/collection_providers.dart';
import 'src/data/collection_repository.dart';
import 'src/domain/collection_rules.dart' show receiptLowWater;
import 'src/presentation/collect_flow_screen.dart';
import 'src/presentation/collect_success_screen.dart';
import 'src/presentation/customer_picker_screen.dart';
import 'src/work_log.dart';

/// Status chip for a local collection (04-architecture §5.6).
Widget collectionStatusChip(BuildContext context, String status, String syncState) {
  final l = AppLocalizations.of(context);
  return switch (status) {
    'posted' || 'resolved_posted' => StatusBadge(AppStatus.paid, label: l.statusPosted, dense: true),
    'conflict' => StatusBadge(AppStatus.overdue, label: l.statusConflict, dense: true),
    'rejected' || 'posting_failed' => StatusBadge(AppStatus.overdue, label: l.statusRejected, dense: true),
    'voided' || 'resolved_voided' || 'resolved_refund' => StatusBadge(AppStatus.pending, label: l.statusVoided, dense: true),
    _ => syncState == 'synced'
        ? StatusBadge(AppStatus.pending, label: l.statusSent, dense: true)
        : StatusBadge(AppStatus.pending, label: l.statusQueued, dense: true),
  };
}

/// Collections: offline collect flow, receipts, idempotent sync
/// (FR-COL-001…007, 011, 013; FR-M-006, 007).
final collectionsManifest = FeatureManifest(
  name: 'collections',
  todayCards: [TodayCardDef(id: 'receipts-low', order: 3, permission: Perm.collectionRecord, builder: (_) => const _ReceiptsLowBanner())],
  flag: 'module.collections',
  permissions: const [Perm.collectionRecord, Perm.collectionView],
  routes: [
    GoRoute(path: '/collect', builder: (_, _) => const CustomerPickerScreen()),
    GoRoute(path: '/collect/success/:clientId', builder: (_, s) => CollectSuccessScreen(clientId: s.pathParameters['clientId']!)),
    GoRoute(path: '/collect/:customerId', builder: (_, s) => CollectFlowScreen(customerId: s.pathParameters['customerId']!)),
  ],
  pullHandlers: [CollectionPullHandler()],
  pushHandlers: [CollectionPushHandler()],
  customerActions: [
    CustomerActionDef(
      id: 'collect',
      order: 0,
      primary: true,
      permission: Perm.collectionRecord,
      icon: Icons.payments_rounded,
      label: (c) => AppLocalizations.of(c).actionCollect,
      onTap: (c, ref, x) => c.push('/collect/${x.customerId}'),
    ),
  ],
  workLogSources: const [WorkLogSourceDef(id: 'collections', watch: watchCollectionWorkLog)],
  timelineSources: [
    TimelineSourceDef(
      id: 'collections',
      watch: (context, ref, customerId) {
        final l = AppLocalizations.of(context);
        return ref.read(collectionRepositoryProvider).watchForCustomer(customerId).map((rows) {
          final f = ref.read(fmtProvider);
          return [
            for (final r in rows)
              TimelineEntry(
                at: r.recordedAt,
                icon: Icons.payments_rounded,
                title: l.timelineCollection(f.money(r.amountPoisha)),
                subtitle: '${f.dateTime(r.recordedAt)} · ${r.receiptNo}',
                statusChip: Builder(builder: (c) => collectionStatusChip(c, r.status, r.syncState)),
              ),
          ];
        });
      },
    ),
  ],
);

/// Ensures receipt top-up listener is alive (read once from the shell).
final collectionsBackgroundProvider = Provider<void>((ref) => ref.watch(receiptTopUpProvider));

class _ReceiptsLowBanner extends ConsumerWidget {
  const _ReceiptsLowBanner();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(receiptsRemainingProvider).value;
    if (n == null || n >= receiptLowWater) return const SizedBox.shrink();
    return InfoBanner(icon: Icons.receipt_long_rounded, tone: BannerTone.warning, text: AppLocalizations.of(context).todayReceiptsLow(ref.watch(fmtProvider).num(n)));
  }
}
