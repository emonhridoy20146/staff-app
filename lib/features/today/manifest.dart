import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import '../../core/feature/feature_manifest.dart';
import '../../core/theme/tag_colors.dart' show ActionTone;
import 'src/alerts_screen.dart';
import 'src/today_work_screen.dart';

/// Today tab (FR-M-004/005). Renders other features' `todayCards`.
final todayManifest = FeatureManifest(
  name: 'today',
  routes: [
    GoRoute(path: '/alerts', builder: (_, _) => const AlertsScreen()),
    GoRoute(path: '/today-work', builder: (_, s) => TodayWorkScreen(date: s.uri.queryParameters['date'])),
  ],
  quickActions: [
    QuickActionDef(id: 'today-work', order: 20, icon: Icons.list_alt_rounded, tone: ActionTone.teal, label: (l) => l.todayWorkBtn, route: '/today-work'),
  ],
);
