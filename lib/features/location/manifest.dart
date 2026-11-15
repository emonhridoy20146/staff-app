import '../../core/feature/feature_manifest.dart';
import 'src/location_widgets.dart';

/// Duty location tracking (FR-M-011, FR-LOC-001…006). Runs only while on
/// duty; the provider (free / paid) follows the server setting
/// `location.trackingProvider` (ADR-M11).
final locationManifest = FeatureManifest(
  name: 'location',
  flag: 'module.location',
  todayCards: [TodayCardDef(id: 'visit-suggestion', order: 2, builder: (_) => const VisitSuggestionCard())],
  meEntries: [MeEntryDef(id: 'tracking', order: 5, builder: (_) => const TrackingStatusCard())],
);
