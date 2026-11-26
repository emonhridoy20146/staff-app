import 'package:go_router/go_router.dart';

import '../../core/feature/feature_manifest.dart';
import 'src/location_widgets.dart';
import 'src/oem_battery_guide_screen.dart';
import 'src/tracking_setup_screen.dart';

/// Duty location tracking (FR-M-011, FR-LOC-001…006). Runs only while on
/// duty; the provider (free / paid) follows the server setting
/// `location.trackingProvider` (ADR-M11).
final locationManifest = FeatureManifest(
  name: 'location',
  flag: 'module.location',
  routes: [
    GoRoute(path: '/location/battery-guide', builder: (_, _) => const OemBatteryGuideScreen()),
    // FR-M-078: battery optimisation + brand autostart, with an explanation.
    GoRoute(path: '/location/background-setup', builder: (_, _) => const TrackingSetupScreen()),
  ],
  todayCards: [
    // FR-M-078: on duty but tracking is not healthy — first thing on Today.
    TodayCardDef(id: 'tracking-health', order: -1, builder: (_) => const TrackingHealthBanner()),
    TodayCardDef(id: 'visit-suggestion', order: 2, builder: (_) => const VisitSuggestionCard()),
  ],
  meEntries: [MeEntryDef(id: 'tracking', order: 5, builder: (_) => const TrackingStatusCard())],
);
