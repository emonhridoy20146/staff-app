@Tags(['screenshots'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'shot_helpers.dart';

/// Home (Today) in every look the owner reviews (2026-11-26 redesign):
/// bn / en, light / dark, a 360 dp phone, 1.3 text scale, the whole page and
/// the empty day. Regenerate: `flutter test --tags screenshots --update-goldens`.
void main() {
  setUpAll(loadShotFonts);

  const tall = Size(412, 2000);
  const small = Size(360, 780);
  const smallTall = Size(360, 2000);

  testWidgets('home bn light', (t) async => takeShot(t, await readyShot(t), 'home/home-bn-light', go: '/today'));
  testWidgets('home bn dark', (t) async => takeShot(t, await readyShot(t, dark: true), 'home/home-bn-dark', go: '/today'));
  testWidgets('home en light', (t) async => takeShot(t, await readyShot(t, lang: 'en'), 'home/home-en-light', go: '/today'));
  testWidgets('home en dark', (t) async => takeShot(t, await readyShot(t, lang: 'en', dark: true), 'home/home-en-dark', go: '/today'));
  testWidgets('home bn full page', (t) async => takeShot(t, await readyShot(t, size: tall), 'home/home-bn-full', go: '/today'));
  testWidgets('home en dark full page', (t) async => takeShot(t, await readyShot(t, size: tall, lang: 'en', dark: true), 'home/home-en-dark-full', go: '/today'));
  testWidgets('home 360dp', (t) async => takeShot(t, await readyShot(t, size: small), 'home/home-bn-360', go: '/today'));
  testWidgets('home 360dp text 1.3 full', (t) async => takeShot(t, await readyShot(t, size: smallTall, textScale: 1.3), 'home/home-bn-360-scale130-full', go: '/today'));
  testWidgets('home en 360dp text 1.3', (t) async => takeShot(t, await readyShot(t, size: small, textScale: 1.3, lang: 'en'), 'home/home-en-360-scale130', go: '/today'));
  testWidgets('home before work-in, nothing collected', (t) async => takeShot(t, await readyShot(t, workIn: false, collect: false), 'home/home-bn-start-of-day', go: '/today'));
}
