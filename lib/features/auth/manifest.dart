import '../../core/feature/feature_manifest.dart';

/// Auth: login, refresh, password change, PIN / app lock (FR-AUTH-001…010).
/// Routes are wired by the app router's redirect (stage-driven), not here.
const authManifest = FeatureManifest(name: 'auth');
