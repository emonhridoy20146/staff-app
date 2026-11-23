import 'package:go_router/go_router.dart';

import '../../core/feature/feature_manifest.dart';
import 'src/prospects_data.dart';
import 'src/prospects_ui.dart';

/// Possible customers (prospects, contract 1.45.0, FR-M-073, ADR-M36): staff note someone who may become a
/// customer, offline; see their list with status and who added it; change their own while `new`.
/// Location only while on duty (CLAUDE.md §2.6). No permission keys yet: the 1.45.0 contract names none for
/// staff, so the module flag alone gates it (hidden ≠ secure: the server checks every mutation).
final prospectsManifest = FeatureManifest(
  name: 'prospects',
  flag: 'module.prospects',
  routes: [
    GoRoute(path: '/prospects', builder: (_, _) => const ProspectsScreen()),
    GoRoute(path: '/prospects/new', builder: (_, _) => const ProspectFormScreen()),
    GoRoute(path: '/prospects/:id/edit', builder: (_, s) => ProspectFormScreen(clientId: s.pathParameters['id'])),
  ],
  pullHandlers: [ProspectPullHandler()],
  pushHandlers: [ProspectPushHandler()],
  meEntries: [MeEntryDef(id: 'prospects', order: 14, builder: (_) => const ProspectsMeEntry())],
);
