/// Public barrel of the `location` feature.
library;

export 'manifest.dart';
export 'src/location_tracker.dart'
    show locationBackgroundProvider, locationTrackerProvider, trackingStatusProvider, trackingProvidersProvider, visitSuggestionProvider, TrackingStatus, VisitSuggestion, LocationTracker;
export 'src/tracking_health.dart' show trackingProbeProvider, TrackingProbe, DeviceTrackingProbe, TrackingIssue, trackingIssueFor, trackingIssueProvider;
export 'src/oem_battery_guide_screen.dart' show oemBrandFor, OemBrandId;
export 'src/tracking_setup_screen.dart' show TrackingSetupScreen, TrackingHealthBanner;
