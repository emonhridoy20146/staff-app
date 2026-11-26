import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/theme/tag_colors.dart' show ActionTone;
import 'src/prospects_data.dart';
import 'src/prospects_ui.dart';

/// Possible customers (prospects, contract 1.45.0, FR-M-073, ADR-M36): staff note someone who may become a
/// customer, offline; see their list with status and who added it; change their own until it is sent.
/// Location only while on duty (CLAUDE.md §2.6). Permission prospect.create (the server checks every mutation).
final prospectsManifest = FeatureManifest(
  name: 'prospects',
  flag: 'module.prospects',
  permissions: const [Perm.prospectCreate, Perm.prospectView],
  routes: [
    GoRoute(path: '/prospects', builder: (_, _) => const ProspectsScreen()),
    GoRoute(path: '/prospects/new', builder: (_, _) => const ProspectFormScreen()),
    GoRoute(path: '/prospects/:id/edit', builder: (_, s) => ProspectFormScreen(clientId: s.pathParameters['id'])),
  ],
  pullHandlers: [ProspectPullHandler()],
  pushHandlers: [ProspectPushHandler()],
  meEntries: [MeEntryDef(id: 'prospects', order: 14, permission: Perm.prospectCreate, builder: (_) => const ProspectsMeEntry())],
  quickActions: [
    QuickActionDef(id: 'prospects', order: 70, icon: Icons.person_add_alt_1_rounded, tone: ActionTone.teal, label: (l) => l.prospectsTitle, route: '/prospects', permission: Perm.prospectCreate),
  ],
);
