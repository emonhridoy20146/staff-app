import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import 'src/cash.dart';

/// Cash: on hand vs limit (offline-aware), deposits (FR-CASH-001…003, 006;
/// FR-M-008). Deposit slip photo is added with the media queue (phase 1b).
final cashManifest = FeatureManifest(
  name: 'cash',
  flag: 'module.cash',
  permissions: const [Perm.cashView, Perm.cashDepositRecord],
  pullHandlers: [DepositPullHandler()],
  pushHandlers: [DepositPushHandler()],
  meEntries: [MeEntryDef(id: 'cash', order: 10, permission: Perm.cashView, builder: (_) => const CashCard())],
);
