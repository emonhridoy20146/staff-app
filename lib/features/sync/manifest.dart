import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/feature/feature_manifest.dart';
import '../../core/providers.dart';
import '../../core/theme/tag_colors.dart' show ActionTone;
import '../../l10n/app_localizations.dart';
import 'src/sync_centre.dart';

/// Sync centre (FR-M-011). Always on: it is how staff see unsent work.
final syncManifest = FeatureManifest(
  name: 'sync',
  routes: [GoRoute(path: '/sync', builder: (_, _) => const SyncCentreScreen())],
  todayCards: [TodayCardDef(id: 'sync-problems', order: 1, alert: true, builder: (c) => SyncProblemsBanner(onTap: () => c.push('/sync')))],
  quickActions: [
    QuickActionDef(
      id: 'sync',
      order: 140,
      icon: Icons.cloud_sync_rounded,
      tone: ActionTone.green,
      label: (l) => l.meSyncCentre,
      route: '/sync',
      badge: (ref) => (ref.watch(failedCountProvider).value ?? 0) + (ref.watch(openConflictCountProvider).value ?? 0),
    ),
  ],
  settingsRows: [
    SettingsRowDef(
      id: 'sync',
      section: SettingsSection.work,
      order: 10,
      icon: Icons.cloud_sync_rounded,
      tone: ActionTone.green,
      title: (l) => l.meSyncCentre,
      hint: (l) => l.settingsSyncHint,
      value: (ref, l, f) {
        final problems = (ref.watch(failedCountProvider).value ?? 0) + (ref.watch(openConflictCountProvider).value ?? 0);
        if (problems > 0) return l.syncProblems(f.num(problems));
        final waiting = ref.watch(pendingCountProvider).value ?? 0;
        return waiting > 0 ? l.syncQueued(f.num(waiting)) : l.syncSynced;
      },
      route: '/sync',
    ),
  ],
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
