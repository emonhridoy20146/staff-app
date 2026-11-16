import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../core/api/fake/fake_field_api.dart';
import '../core/auth/secure_store.dart';
import '../core/config/env.dart';
import '../core/db/app_database.dart';
import '../core/db/db_connection.dart';
import '../core/device/device_identity.dart';
import '../core/feature/feature_manifest.dart';
import '../core/location/location_engine.dart';
import '../core/location/tracking/tracking_provider.dart';
import '../core/media/media.dart';
import '../core/providers.dart';
import '../core/sync/sync_handlers.dart';
import '../core/time/clock.dart';
import '../features/customers/customers.dart';
import '../features/location/location.dart';
import '../features/visits/visits.dart';
import 'features.dart';

/// Builds the root [ProviderContainer] for an [Env].
///
/// Demo mode is fully self-contained and ephemeral: in-memory database and
/// secure store, the fake field-api adapter and a fixed Barishal GPS fix.
/// Dev / staging / prod use the encrypted SQLite file and the Keystore.
Future<ProviderContainer> bootstrap(Env env, {List<Override> extra = const []}) async {
  final clock = SystemClock();
  final SecureStore store = env.isDemo ? MemorySecureStore() : const KeystoreSecureStore();
  final db = AppDatabase(env.isDemo ? openMemoryDatabase() : await openEncryptedDatabase(store));
  final device = env.isDemo ? DeviceIdentity.demo : await DeviceIdentity.load(store);

  late final SyncHandlerRegistry registry;
  final manifests = buildFeatureManifests(() => registry);
  registry = buildRegistry(manifests);

  late final ProviderContainer container;
  container = ProviderContainer(overrides: [
    envProvider.overrideWithValue(env),
    clockProvider.overrideWithValue(clock),
    secureStoreProvider.overrideWithValue(store),
    databaseProvider.overrideWithValue(db),
    deviceIdentityProvider.overrideWithValue(device),
    featureManifestsProvider.overrideWithValue(manifests),
    syncHandlerRegistryProvider.overrideWithValue(registry),
    mediaOwnerHooksProvider.overrideWithValue({
      'visit': (db, owner, ids) => linkVisitPhotos(container.read(outboxWriterProvider), db, owner, ids),
      'location_proposal': (db, owner, ids) => submitLocationProposal(container.read(outboxWriterProvider), db, owner, ids),
    }),
    if (env.isDemo) ...[
      fakeApiProvider.overrideWithValue(FakeFieldApi(clock: clock)),
      locationEngineProvider.overrideWithValue(FakeLocationEngine()),
      // Demo never tracks for real: no foreground service, no GPS stream.
      trackingProvidersProvider.overrideWithValue([FakeTrackingProvider(), FakeTrackingProvider(id: 'paid', isAvailable: false)]),
    ],
    ...extra,
  ]);
  return container;
}

/// Best effort: tile provider and minimum version from `/meta/app-config`
/// (works offline — the previous value / defaults stay).
Future<void> loadAppConfig(ProviderContainer c) async {
  try {
    final cfg = await c.read(fieldApiProvider).appConfig();
    if (cfg.tileProvider != null) c.read(tileConfigProvider.notifier).state = cfg.tileProvider!;
    if (cfg.serverTime != null) c.read(clockProvider).syncWithServer(cfg.serverTime!);
    if (_versionLess(c.read(deviceIdentityProvider).appVersion, cfg.minAppVersion)) {
      c.read(upgradeRequiredProvider.notifier).state = true;
    }
  } catch (_) {}
}

bool _versionLess(String a, String b) {
  List<int> p(String v) => v.split('+').first.split('.').map((x) => int.tryParse(x) ?? 0).toList();
  final x = p(a), y = p(b);
  for (var i = 0; i < 3; i++) {
    final xi = i < x.length ? x[i] : 0, yi = i < y.length ? y[i] : 0;
    if (xi != yi) return xi < yi;
  }
  return false;
}

/// Test helper: everything in memory with deterministic fakes.
ProviderContainer buildTestContainer({required Clock clock, FakeFieldApi? api, List<Override> extra = const []}) {
  late final SyncHandlerRegistry registry;
  final manifests = buildFeatureManifests(() => registry);
  registry = buildRegistry(manifests);
  late final ProviderContainer c;
  c = ProviderContainer(overrides: [
    envProvider.overrideWithValue(const Env(environment: AppEnvironment.demo, apiBaseUrl: 'https://demo.invalid/api/v1', apiMode: ApiMode.demo)),
    clockProvider.overrideWithValue(clock),
    secureStoreProvider.overrideWithValue(MemorySecureStore()),
    databaseProvider.overrideWithValue(AppDatabase(openMemoryDatabase())),
    deviceIdentityProvider.overrideWithValue(DeviceIdentity.demo),
    featureManifestsProvider.overrideWithValue(manifests),
    syncHandlerRegistryProvider.overrideWithValue(registry),
    mediaOwnerHooksProvider.overrideWithValue({
      'visit': (db, owner, ids) => linkVisitPhotos(c.read(outboxWriterProvider), db, owner, ids),
      'location_proposal': (db, owner, ids) => submitLocationProposal(c.read(outboxWriterProvider), db, owner, ids),
    }),
    fakeApiProvider.overrideWithValue(api ?? FakeFieldApi(clock: clock, latency: Duration.zero)),
    locationEngineProvider.overrideWithValue(FakeLocationEngine()),
    photoCapturerProvider.overrideWithValue(FakePhotoCapturer()),
    mapTilesEnabledProvider.overrideWithValue(false),
    trackingProvidersProvider.overrideWithValue([FakeTrackingProvider(), FakeTrackingProvider(id: 'paid', isAvailable: false)]),
    ...extra,
  ]);
  return c;
}
