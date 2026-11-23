import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/feature/feature_manifest.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/common.dart';
import '../../l10n/app_localizations.dart';
import 'src/leaderboard_screen.dart';
import 'src/performance_screen.dart';
import 'src/reports_data.dart';

/// Reports in the app (FR-M-021, FR-REP-005, contract 1.10.0): my month
/// and, when the admin allows it, my branch's leaderboard. Self-service
/// (no permission key); online with the last month cached.
final reportsManifest = FeatureManifest(
  name: 'reports',
  flag: 'module.reports',
  routes: [
    GoRoute(path: '/performance', builder: (_, _) => const PerformanceScreen()),
    GoRoute(path: '/leaderboard', builder: (_, _) => const LeaderboardScreen()),
  ],
  meEntries: [
    MeEntryDef(id: 'performance', order: 12, builder: (_) => const _PerformanceMeEntry()),
    // FR-M-071: its own line in the Me list, only while the office shows the board to staff.
    MeEntryDef(id: 'leaderboard', order: 13, visible: (ref) => ref.watch(leaderboardVisibleProvider), builder: (_) => const LeaderboardMeEntry()),
  ],
);

/// The leaderboard as its own entry in the Me tab (FR-M-071).
class LeaderboardMeEntry extends StatelessWidget {
  const LeaderboardMeEntry({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        minTileHeight: 64,
        leading: const Icon(Icons.emoji_events_rounded),
        title: Text(l.leaderboardTitle),
        subtitle: Text(l.leaderboardMeSubtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push('/leaderboard'),
      ),
    );
  }
}

class _PerformanceMeEntry extends ConsumerWidget {
  const _PerformanceMeEntry();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final board = ref.watch(leaderboardVisibleProvider);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        ListTile(
          minTileHeight: 64,
          leading: const Icon(Icons.insights_rounded),
          title: Text(l.perfTitle),
          subtitle: Text(l.perfMeSubtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push('/performance'),
        ),
        if (board) ...[
          const Divider(height: 1, indent: Space.s16, endIndent: Space.s16),
          ListTile(
            minTileHeight: 56,
            leading: const Icon(Icons.emoji_events_rounded),
            title: Text(l.leaderboardTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/leaderboard'),
          ),
        ],
      ]),
    );
  }
}
