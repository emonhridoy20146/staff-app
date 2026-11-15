import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/feature/feature_manifest.dart';
import '../../l10n/app_localizations.dart';
import 'src/sync_centre.dart';

/// Sync centre (FR-M-011). Always on: it is how staff see unsent work.
final syncManifest = FeatureManifest(
  name: 'sync',
  routes: [GoRoute(path: '/sync', builder: (_, _) => const SyncCentreScreen())],
  todayCards: [TodayCardDef(id: 'sync-problems', order: 1, builder: (c) => SyncProblemsBanner(onTap: () => c.push('/sync')))],
  meEntries: [
    MeEntryDef(
      id: 'sync',
      order: 40,
      builder: (c) => Card(
        child: ListTile(
          minTileHeight: 64,
          leading: const Icon(Icons.cloud_sync_rounded),
          title: Text(AppLocalizations.of(c).meSyncCentre),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => c.push('/sync'),
        ),
      ),
    ),
  ],
);
