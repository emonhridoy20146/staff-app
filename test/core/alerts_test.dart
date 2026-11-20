import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/core/feature/feature_manifest.dart';

/// FR-M-044: the bell counts what every feature says is waiting.
void main() {
  AppAlert alert(String id, AlertKind kind) => AppAlert(id: id, kind: kind, icon: Icons.circle, title: (_, _) => id);

  test('alerts of every feature are listed in feature order', () {
    final c = ProviderContainer(overrides: [
      featureManifestsProvider.overrideWithValue([
        FeatureManifest(name: 'a', flag: 'module.a', alertSources: [AlertSourceDef(id: 'x', read: (_) => [alert('p1', AlertKind.promise), alert('p2', AlertKind.promise)])]),
        const FeatureManifest(name: 'b', flag: 'module.b'),
        FeatureManifest(name: 'c', flag: 'module.c', alertSources: [AlertSourceDef(id: 'y', read: (_) => [alert('t1', AlertKind.task)])]),
      ]),
    ]);
    addTearDown(c.dispose);
    expect([for (final a in c.read(alertsProvider)) a.id], ['p1', 'p2', 't1']);
  });

  test('nothing waiting: empty', () {
    final c = ProviderContainer(overrides: [featureManifestsProvider.overrideWithValue(const [])]);
    addTearDown(c.dispose);
    expect(c.read(alertsProvider), isEmpty);
  });
}
