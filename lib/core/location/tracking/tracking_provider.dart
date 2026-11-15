import 'dart:async';

import 'sampling.dart';

/// One raw point from a tracking provider (before filters).
class RawLocation {
  const RawLocation({
    required this.t,
    required this.lat,
    required this.lng,
    required this.acc,
    this.spd,
    this.hdg,
    this.alt,
    this.mock = false,
  });
  final DateTime t;
  final double lat;
  final double lng;
  final double acc;

  /// m/s, null when unknown.
  final double? spd;
  final double? hdg;
  final double? alt;
  final bool mock;
}

/// Device state the heartbeat reports (`/location/heartbeat`).
class TrackingHealth {
  const TrackingHealth({required this.gpsEnabled, required this.permission});
  final bool gpsEnabled;

  /// always | while_in_use | denied
  final String permission;
}

/// Background location source (ADR-009 amended, OD-M06).
///
/// Two implementations can live in one build:
/// * `free` — geolocator + Android foreground service (always compiled in);
/// * `paid` — licensed background-geolocation SDK, compiled in only when the
///   build has the plugin and its licence key (build-time, CI secret).
///
/// Which one runs is chosen at runtime from the server setting
/// `location.trackingProvider` (admin settings). If `paid` is chosen but the
/// build does not contain it, the app falls back to `free` and reports that
/// in the heartbeat, so the admin can see it.
abstract class TrackingProvider {
  /// `free` | `paid` — matches the setting values.
  String get id;

  /// False when this build does not contain the provider.
  bool get isAvailable;

  /// Starts emitting on [points]; shows the persistent notification.
  Future<void> start(SamplingProfile profile, {required String notificationTitle, required String notificationText});

  /// Changes interval / distance without a restart where possible.
  Future<void> updateProfile(SamplingProfile profile);

  Future<void> stop();

  bool get isRunning;

  Stream<RawLocation> get points;

  Future<TrackingHealth> health();
}

/// Picks the provider from the server setting. Returns the chosen one and
/// whether a fallback happened (paid requested but not in this build).
({TrackingProvider provider, bool fellBack}) selectTrackingProvider(String? setting, List<TrackingProvider> available) {
  final free = available.firstWhere((p) => p.id == 'free');
  if (setting == 'paid') {
    final paid = available.where((p) => p.id == 'paid' && p.isAvailable).firstOrNull;
    return paid == null ? (provider: free, fellBack: true) : (provider: paid, fellBack: false);
  }
  return (provider: free, fellBack: false);
}

/// Test / demo provider: points are pushed by hand.
class FakeTrackingProvider implements TrackingProvider {
  FakeTrackingProvider({this.id = 'free', this.isAvailable = true});
  @override
  final String id;
  @override
  bool isAvailable;
  final _c = StreamController<RawLocation>.broadcast();
  bool _running = false;
  SamplingProfile? profile;
  int starts = 0;

  void emit(RawLocation p) {
    if (_running) _c.add(p);
  }

  @override
  bool get isRunning => _running;
  @override
  Stream<RawLocation> get points => _c.stream;
  @override
  Future<TrackingHealth> health() async => const TrackingHealth(gpsEnabled: true, permission: 'while_in_use');
  @override
  Future<void> start(SamplingProfile profile, {required String notificationTitle, required String notificationText}) async {
    this.profile = profile;
    _running = true;
    starts++;
  }

  @override
  Future<void> updateProfile(SamplingProfile profile) async => this.profile = profile;
  @override
  Future<void> stop() async => _running = false;
}
