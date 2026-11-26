@Tags(['screenshots'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'shot_helpers.dart';

/// Settings in the looks the owner reviews (v2, 2026-11-26): bn / en, light / dark, a 360 dp phone at 1.3 text.
/// Regenerate: `flutter test --tags screenshots --update-goldens`.
void main() {
  setUpAll(loadShotFonts);

  const tall = Size(412, 1900);
  const smallTall = Size(360, 2400);

  testWidgets('settings bn light', (t) async => takeShot(t, await readyShot(t, size: tall), 'settings/settings-bn-light', go: '/settings'));
  testWidgets('settings en dark', (t) async => takeShot(t, await readyShot(t, size: tall, lang: 'en', dark: true), 'settings/settings-en-dark', go: '/settings'));
  testWidgets('settings 360dp text 1.3', (t) async => takeShot(t, await readyShot(t, size: smallTall, textScale: 1.3), 'settings/settings-bn-360-scale130', go: '/settings'));
}
