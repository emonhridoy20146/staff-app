import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import '../../core/feature/feature_manifest.dart';
import '../../core/theme/tag_colors.dart' show ActionTone;
import 'src/location_tracker.dart' show trackingStatusProvider;
import 'src/location_widgets.dart';
import 'src/oem_battery_guide_screen.dart';
import 'src/tracking_health.dart' show trackingIssueProvider;
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
    TodayCardDef(id: 'tracking-health', order: -1, alert: true, builder: (_) => const TrackingHealthBanner()),
    TodayCardDef(id: 'visit-suggestion', order: 2, builder: (_) => const VisitSuggestionCard()),
  ],
  meEntries: [MeEntryDef(id: 'tracking', order: 5, builder: (_) => const TrackingStatusCard())],
  settingsRows: [
    // Whether tracking runs now, and the way to the background set-up (FR-M-078). Never on off duty (§2.6).
    SettingsRowDef(
      id: 'tracking',
      section: SettingsSection.locationBattery,
      order: 10,
      icon: Icons.my_location_rounded,
      tone: ActionTone.green,
      title: (l) => l.trackingTitle,
      hint: (l) => l.settingsTrackingHint,
      value: (ref, l, f) {
        if (ref.watch(trackingIssueProvider) != null) return l.settingsTrackingProblem;
        return ref.watch(trackingStatusProvider).running ? l.settingsTrackingOn : l.settingsTrackingOff;
      },
      route: '/location/background-setup',
    ),
    SettingsRowDef(
      id: 'battery-guide',
      section: SettingsSection.locationBattery,
      order: 20,
      icon: Icons.battery_saver_rounded,
      tone: ActionTone.amber,
      title: (l) => l.oemGuideTitle,
      hint: (l) => l.settingsBatteryGuideHint,
      route: '/location/battery-guide',
    ),
  ],
);
