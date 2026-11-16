import 'dart:async';
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

/// One GPS fix (`GeoFix` in the contract).
class GeoFix {
  const GeoFix({required this.lat, required this.lng, required this.accuracyM, this.mock = false, required this.fixAt});
  final double lat;
  final double lng;
  final double accuracyM;
  final bool mock;
  final DateTime fixAt;

  bool get isGood => accuracyM <= 50;

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'accuracyM': accuracyM,
        'mock': mock,
        'fixAt': fixAt.toUtc().toIso8601String(),
      };
}

/// Location abstraction (ADR-009). Phase 1 only needs [currentFix] for
/// collections, visits and attendance. Phase 2 adds duty-aware tracking
/// behind this same interface — implementation choice (licensed
/// background-geolocation plugin vs. geolocator + foreground service) is
/// pending the client's licence decision.
abstract class LocationEngine {
  /// Best fix within [timeout]; null if permission denied or no fix.
  Future<GeoFix?> currentFix({Duration timeout = const Duration(seconds: 20)});

  /// Last known fix without waiting (for distance sorting).
  Future<GeoFix?> lastKnown();

  /// Why the last [currentFix] returned null (`GeoUnavailableReason` in the
  /// contract 1.2.0): permission_denied | location_off | timeout | no_fix.
  String? get lastFailureReason;
}

/// `geo` + `geoUnavailableReason` fields for a mutation payload (1.2.0):
/// geo is null when there is no fix, with the reason alongside.
Map<String, dynamic> geoFields(GeoFix? fix, String? reason) =>
    fix != null ? {'geo': fix.toJson()} : {'geo': null, 'geoUnavailableReason': reason ?? 'no_fix'};

class GeolocatorLocationEngine implements LocationEngine {
  @override
  String? lastFailureReason;

  @override
  Future<GeoFix?> currentFix({Duration timeout = const Duration(seconds: 20)}) async {
    lastFailureReason = null;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        lastFailureReason = 'location_off';
        return null;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        lastFailureReason = 'permission_denied';
        return null;
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high, timeLimit: timeout),
      );
      return _fromPosition(p);
    } on TimeoutException {
      final last = await lastKnown();
      if (last == null) lastFailureReason = 'timeout';
      return last;
    } catch (_) {
      lastFailureReason = 'no_fix';
      return null;
    }
  }

  @override
  Future<GeoFix?> lastKnown() async {
    try {
      final p = await Geolocator.getLastKnownPosition();
      return p == null ? null : _fromPosition(p);
    } catch (_) {
      return null;
    }
  }

  GeoFix _fromPosition(Position p) =>
      GeoFix(lat: p.latitude, lng: p.longitude, accuracyM: p.accuracy, mock: p.isMocked, fixAt: p.timestamp.toUtc());
}

/// Fixed position engine for demo and tests (Nathullabad, Barishal).
class FakeLocationEngine implements LocationEngine {
  FakeLocationEngine({this.fix, this.noFix = false});
  GeoFix? fix;

  /// Tests: simulate "no GPS" (returns null with reason `no_fix`).
  bool noFix;

  @override
  String? get lastFailureReason => noFix ? 'no_fix' : null;

  static GeoFix demoFix() => GeoFix(lat: 22.7105, lng: 90.3495, accuracyM: 12, fixAt: DateTime.now().toUtc());

  @override
  Future<GeoFix?> currentFix({Duration timeout = const Duration(seconds: 20)}) async => noFix ? null : (fix ?? demoFix());

  @override
  Future<GeoFix?> lastKnown() async => fix ?? demoFix();
}

/// Haversine distance in metres.
int distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371000.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.sin(dLng / 2) * math.sin(dLng / 2);
  return (2 * r * math.asin(math.sqrt(a))).round();
}
