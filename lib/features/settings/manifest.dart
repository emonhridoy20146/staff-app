import 'package:go_router/go_router.dart';

import '../../core/feature/feature_manifest.dart';
import 'src/me_settings.dart';

/// Me tab + settings (language, digits, theme, high contrast, privacy).
final settingsManifest = FeatureManifest(
  name: 'settings',
  routes: [GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen())],
);
