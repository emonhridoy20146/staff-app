import '../settings/duty_settings.dart';
import 'location_engine.dart';

/// The radius around a customer's pin inside which work counts as "at the
/// customer" (server setting `collections.geofenceM`, the same number the
/// server uses for its `far_from_pin` flag; 150 m until the server says).
int geofenceRadiusM(Map<String, dynamic> settings) => geofenceRadiusOf(settings);

/// How far the phone is from the customer's pin when it is outside the
/// geofence; null when it is inside, when there is no fix, or when the
/// customer has no pin (FR-M-043). Used to warn, never to block: money
/// collected at the shop or on the road must still be recorded.
int? farFromPinM({required GeoFix? fix, required double? pinLat, required double? pinLng, required int radiusM}) {
  if (fix == null || pinLat == null || pinLng == null) return null;
  final d = distanceMeters(fix.lat, fix.lng, pinLat, pinLng);
  return d > radiusM ? d : null;
}
