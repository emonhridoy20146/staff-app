import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/theme/tag_colors.dart' show ActionTone;
import 'src/cash.dart';
import 'src/cash_in_hand.dart';

/// Cash: on hand vs limit (offline-aware), deposits (FR-CASH-001…003, 006;
/// FR-M-008, FR-M-059). A bank deposit carries a camera photo of its slip (FR-M-065).
final cashManifest = FeatureManifest(
  name: 'cash',
  flag: 'module.cash',
  permissions: const [Perm.cashView, Perm.cashDepositRecord],
  routes: [GoRoute(path: '/cash/in-hand', builder: (_, _) => const CashInHandScreen())],
  pullHandlers: [DepositPullHandler()],
  pushHandlers: [DepositPushHandler()],
  meEntries: [MeEntryDef(id: 'cash', order: 10, permission: Perm.cashView, builder: (_) => const CashCard())],
  quickActions: [
    QuickActionDef(id: 'cash', order: 30, icon: Icons.account_balance_wallet_rounded, tone: ActionTone.green, label: (l) => l.quickCash, route: '/cash/in-hand', permission: Perm.cashView),
  ],
);
