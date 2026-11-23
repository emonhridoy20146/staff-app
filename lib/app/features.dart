import '../core/feature/feature_manifest.dart';
import '../core/sync/sync_handlers.dart';
import '../features/attendance/attendance.dart';
import '../features/auth/auth.dart';
import '../features/cash/cash.dart';
import '../features/collections/collections.dart';
import '../features/cowork/cowork.dart';
import '../features/customers/customers.dart';
import '../features/handovers/handovers.dart';
import '../features/location/location.dart';
import '../features/map/map.dart';
import '../features/notes/notes.dart';
import '../features/notices/notices.dart';
import '../features/onboarding/onboarding.dart';
import '../features/places/places.dart';
import '../features/promises/promises.dart';
import '../features/prospects/prospects.dart';
import '../features/reports/reports.dart';
import '../features/settings/settings.dart';
import '../features/sync/sync.dart';
import '../features/tags/tags.dart';
import '../features/tasks/tasks.dart';
import '../features/today/today.dart';
import '../features/visits/visits.dart';

/// THE list of feature modules (04-architecture §3). Adding a feature =
/// one folder + one line here. Microfinance is reserved and NOT listed.
List<FeatureManifest> buildFeatureManifests(SyncHandlerRegistry Function() registry) => [
      authManifest,
      onboardingManifest,
      todayManifest,
      noticesManifest,
      tasksManifest,
      customersManifest(registry),
      collectionsManifest,
      cashManifest,
      visitsManifest,
      notesManifest,
      promisesManifest,
      tagsManifest,
      attendanceManifest,
      handoversManifest,
      coworkManifest,
      locationManifest,
      mapManifest,
      placesManifest,
      prospectsManifest,
      reportsManifest,
      syncManifest,
      settingsManifest,
    ];

/// Builds the sync handler registry from all manifests (duplicate
/// entity handlers fail fast at start-up).
SyncHandlerRegistry buildRegistry(List<FeatureManifest> manifests) => SyncHandlerRegistry(
      pull: [for (final m in manifests) ...m.pullHandlers],
      push: [for (final m in manifests) ...m.pushHandlers],
    );
