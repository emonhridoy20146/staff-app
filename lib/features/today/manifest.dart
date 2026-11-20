import 'package:go_router/go_router.dart';

import '../../core/feature/feature_manifest.dart';
import 'src/today_work_screen.dart';

/// Today tab (FR-M-004/005). Renders other features' `todayCards`.
final todayManifest = FeatureManifest(
  name: 'today',
  routes: [
    GoRoute(path: '/today-work', builder: (_, _) => const TodayWorkScreen()),
  ],
);
