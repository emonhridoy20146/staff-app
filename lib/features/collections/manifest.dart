import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/db/colleague_activity.dart';
import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/providers.dart' show databaseProvider;
import '../../core/settings/ui_prefs.dart';
import '../auth/auth.dart' show sessionProvider;
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
Widget collectionStatusChip(BuildContext context, String status, String syncState, {String? voidedKind}) {
  final l = AppLocalizations.of(context);
  return switch (status) {
    'posted' || 'resolved_posted' => StatusBadge(AppStatus.paid, label: l.statusPosted, dense: true),
    'conflict' => StatusBadge(AppStatus.overdue, label: l.statusConflict, dense: true),
    'rejected' || 'posting_failed' => StatusBadge(AppStatus.overdue, label: l.statusRejected, dense: true),
    'voided' || 'resolved_voided' || 'resolved_refund' => StatusBadge(AppStatus.pending, label: voidedKind == 'admin' ? l.statusVoidedByOffice : (voidedKind == 'withdrawn' ? l.statusDeletedByYou : l.statusVoided), dense: true),
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
    GoRoute(path: '/receipt/:clientId', builder: (_, s) => ReceiptScreen(clientId: s.pathParameters['clientId']!)),
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
        final lang = Localizations.localeOf(context).languageCode;
        return combineLatest2(ref.read(collectionRepositoryProvider).watchForCustomer(customerId), watchColleagueActivities(ref.read(databaseProvider), customerId, 'collection'), (rows, others) {
          final f = ref.read(fmtProvider);
          final myName = ref.read(sessionProvider).user?.name.of(lang);
          return [
            for (final r in rows)
              TimelineEntry(
                at: r.recordedAt,
                icon: Icons.payments_rounded,
                title: l.timelineCollection(f.money(r.amountPoisha)),
                subtitle: [f.dateTime(r.recordedAt), r.receiptNo, if (myName != null) l.timelineCollector(myName), if (r.previousAmountPoisha != null) l.collectionEditedWas(f.money(r.previousAmountPoisha!)), if (r.voidedKind == 'admin' && r.voidedByName != null) l.collectionVoidedBy(r.voidedByName!), if (r.voidedReason != null && r.voidedReason!.isNotEmpty) r.voidedReason!].join(' · '),
                statusChip: Builder(builder: (c) => collectionStatusChip(c, r.status, r.syncState, voidedKind: r.voidedKind)),
                // FR-M-050: the receipt of this collection, to show, send or print again
                trailing: Builder(
                  builder: (c) => TextButton.icon(onPressed: () => c.push('/receipt/${r.clientId}'), icon: const Icon(Icons.receipt_long_rounded), label: Text(l.receiptView)),
                ),
              ),
            for (final o in others)
              TimelineEntry(
                at: o.at,
                icon: Icons.payments_rounded,
                title: l.timelineCollection(f.money(o.amountPoisha ?? 0)),
                subtitle: [f.dateTime(o.at), l.timelineCollector(o.staffName), if (o.status == 'voided' || o.status == 'resolved_voided') (o.voidedKind == 'admin' ? l.statusVoidedByOffice : l.collectionDeletedTag)].join(' · '),
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
