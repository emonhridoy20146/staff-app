import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'api/api_models.dart';
import 'api/fake/fake_field_api.dart';
import 'api/field_api.dart';
import 'auth/secure_store.dart';
import 'config/env.dart';
import 'db/app_database.dart';
import 'device/device_identity.dart';
import 'location/location_engine.dart';
import 'network/dio_client.dart';
import 'permissions/permission_service.dart';
import 'sync/outbox.dart';
import 'sync/sync_engine.dart';
import 'sync/sync_handlers.dart';
import 'time/clock.dart';

/// Core service providers. Overridden in `app/bootstrap.dart` (real
/// services) and in tests (fakes). Features read these; they never build
/// services themselves.

final envProvider = Provider<Env>((ref) => throw UnimplementedError('override envProvider'));
final clockProvider = Provider<Clock>((ref) => SystemClock());
final secureStoreProvider = Provider<SecureStore>((ref) => const KeystoreSecureStore());
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('override databaseProvider'));
final deviceIdentityProvider = Provider<DeviceIdentity>((ref) => throw UnimplementedError('override deviceIdentityProvider'));
final locationEngineProvider = Provider<LocationEngine>((ref) => GeolocatorLocationEngine());

/// Only non-null in demo mode / tests.
final fakeApiProvider = Provider<FakeFieldApi?>((ref) => null);

/// Feature-contributed sync handlers (from manifests).
final syncHandlerRegistryProvider = Provider<SyncHandlerRegistry>((ref) => SyncHandlerRegistry());

/// Current UI language code ('bn' | 'en') for Accept-Language.
final languageCodeProvider = StateProvider<String>((ref) => 'bn');

/// Tokens held in memory and mirrored to secure storage.
class TokenStore implements TokenProvider {
  TokenStore(this._store);
  final SecureStore _store;
  String? _access;
  String? _refresh;
  Future<String?> Function(String refreshToken)? refresher;
  void Function()? onSessionExpired;

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  Future<void> load() async {
    _access = await _store.read(_kAccess);
    _refresh = await _store.read(_kRefresh);
  }

  bool get hasSession => _refresh != null && _refresh!.isNotEmpty;

  Future<void> save(String access, String refresh) async {
    _access = access;
    _refresh = refresh;
    await _store.write(_kAccess, access);
    await _store.write(_kRefresh, refresh);
  }

  Future<void> clear() async {
    _access = null;
    _refresh = null;
    await _store.delete(_kAccess);
    await _store.delete(_kRefresh);
  }

  @override
  String? get accessToken => _access;

  @override
  Future<String?> refreshAccessToken() async {
    final r = _refresh;
    final f = refresher;
    if (r == null || f == null) return null;
    final t = await f(r);
    if (t == null) onSessionExpired?.call();
    return t;
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore(ref.watch(secureStoreProvider)));

/// Set when the server answers 426; the router shows the update screen.
final upgradeRequiredProvider = StateProvider<bool>((ref) => false);

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envProvider);
  final device = ref.watch(deviceIdentityProvider);
  return buildDio(
    baseUrl: env.isDemo ? 'https://demo.invalid/api/v1' : env.apiBaseUrl,
    client: ClientInfo(
      appVersion: device.appVersion,
      deviceId: device.deviceId,
      deviceLabel: device.label,
      language: () => ref.read(languageCodeProvider),
    ),
    tokens: ref.watch(tokenStoreProvider),
    onUpgradeRequired: (_) => ref.read(upgradeRequiredProvider.notifier).state = true,
    adapter: ref.watch(fakeApiProvider),
  );
});

final fieldApiProvider = Provider<FieldApi>((ref) {
  final api = FieldApi(ref.watch(dioProvider));
  final tokens = ref.watch(tokenStoreProvider);
  tokens.refresher = (rt) async {
    try {
      final r = await api.refresh(rt);
      await tokens.save(r.accessToken, r.refreshToken.isEmpty ? rt : r.refreshToken);
      return r.accessToken;
    } on ApiException catch (e) {
      // Offline: keep the session, just fail this request.
      if (e.isNetwork) return null;
      return null;
    }
  };
  return api;
});

final outboxWriterProvider = Provider<OutboxWriter>((ref) => OutboxWriter(ref.watch(databaseProvider), ref.watch(clockProvider)));
final outboxReaderProvider = Provider<OutboxReader>((ref) => OutboxReader(ref.watch(databaseProvider)));

/// Server-provided org settings (duty hours, thresholds, targets…).
final serverSettingsProvider = StateProvider<Json>((ref) => const {});

/// Latest cash position from the server (pull snapshot).
final serverCashProvider = StateProvider<CashPositionDto?>((ref) => null);

/// My daily target from the last pull (1.10.0), kept for offline use.
/// Only valid for its own business date (see `todayTargetProvider`).
final myTargetProvider = StateProvider<MyTarget?>((ref) => null);

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(databaseProvider);
  final engine = SyncEngine(
    db: db,
    api: ref.watch(fieldApiProvider),
    clock: ref.watch(clockProvider),
    handlers: ref.watch(syncHandlerRegistryProvider),
    deviceId: ref.watch(deviceIdentityProvider).deviceId,
    onSnapshot: (s) {
      if (s.permissions != null || s.flags != null) {
        ref.read(accessProvider.notifier).set(permissions: s.permissions, flags: s.flags);
        unawaited(db.kvSet('access', jsonEncode({
          'permissions': ref.read(accessProvider).permissions.toList(),
          'flags': ref.read(accessProvider).flags,
        })));
      }
      if (s.settings != null) {
        ref.read(serverSettingsProvider.notifier).state = s.settings!;
        unawaited(db.kvSet('server_settings', jsonEncode(s.settings)));
      }
      if (s.cash != null) {
        ref.read(serverCashProvider.notifier).state = s.cash;
        unawaited(db.kvSet('server_cash', jsonEncode({
          'onHandPoisha': s.cash!.onHandPoisha,
          'limitPoisha': s.cash!.limitPoisha,
          'pendingDepositsPoisha': s.cash!.pendingDepositsPoisha,
          'state': s.cash!.state,
        })));
      }
      if (s.target != null) {
        ref.read(myTargetProvider.notifier).state = s.target;
        unawaited(db.kvSet('my_target', jsonEncode(s.target!.toJson())));
      }
    },
  );
  ref.onDispose(engine.dispose);
  return engine;
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final e = ref.watch(syncEngineProvider);
  return e.status;
});

final pendingCountProvider = StreamProvider<int>((ref) => ref.watch(outboxReaderProvider).watchPendingCount());
final failedCountProvider = StreamProvider<int>((ref) => ref.watch(outboxReaderProvider).watchFailedCount());

/// Cash on hand, offline-aware (FR-M-008): server position at last sync +
/// local unsynced cash collections − local unsynced deposits. Lives in core
/// because it spans the collections and cash features' tables.
class CashOnHand {
  const CashOnHand({required this.onHand, required this.limit, required this.serverOnHand});
  final int onHand;
  final int limit;
  final int serverOnHand;
  double get ratio => limit <= 0 ? 0 : onHand / limit;
}

final cashOnHandProvider = StreamProvider<CashOnHand>((ref) {
  final db = ref.watch(databaseProvider);
  final server = ref.watch(serverCashProvider);
  final serverOnHand = server?.onHandPoisha ?? 0;
  final limit = server?.limitPoisha ?? 0;
  return db
      .customSelect(
        'SELECT '
        "(SELECT COALESCE(SUM(amount_poisha),0) FROM collections WHERE method = 'cash' AND sync_state IN ('queued','sending')) AS c, "
        "(SELECT COALESCE(SUM(amount_poisha),0) FROM deposits WHERE sync_state IN ('queued','sending')) AS d",
        readsFrom: {db.collections, db.deposits},
      )
      .watchSingle()
      .map((r) => CashOnHand(onHand: serverOnHand + r.read<int>('c') - r.read<int>('d'), limit: limit, serverOnHand: serverOnHand));
});

/// Collections the server marked as conflict and the office has not yet
/// resolved (counted as "problems" with failed outbox items).
final openConflictCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final c = db.collections.clientId.count();
  final q = db.selectOnly(db.collections)
    ..addColumns([c])
    ..where(db.collections.status.equals('conflict'));
  return q.map((r) => r.read(c) ?? 0).watchSingle();
});

/// Media waiting to upload (sync centre).
final pendingMediaCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final c = db.mediaQueue.clientId.count();
  final q = db.selectOnly(db.mediaQueue)
    ..addColumns([c])
    ..where(db.mediaQueue.state.isIn(['pending', 'failed']));
  return q.map((r) => r.read(c) ?? 0).watchSingle();
});

/// Map tile provider from `/meta/app-config` (ADR-014); dev default is OSM.
final tileConfigProvider = StateProvider<TileProviderConfig>((ref) => TileProviderConfig.osmDev);

/// Tiles are disabled in widget tests / screenshots (no network there).
final mapTilesEnabledProvider = Provider<bool>((ref) => true);
