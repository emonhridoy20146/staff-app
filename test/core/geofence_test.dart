import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/location/geofence.dart';
import 'package:staff_app/core/location/location_engine.dart';

/// FR-M-043: work recorded far from the customer's pin is warned about, never blocked.
void main() {
  GeoFix at(double lat, double lng) => GeoFix(lat: lat, lng: lng, accuracyM: 8, fixAt: DateTime.utc(2026, 11, 21, 4));

  test('inside the geofence there is nothing to warn about', () {
    expect(farFromPinM(fix: at(22.7010, 90.3530), pinLat: 22.7010, pinLng: 90.3530, radiusM: 150), isNull);
    // about 110 m north
    expect(farFromPinM(fix: at(22.7020, 90.3530), pinLat: 22.7010, pinLng: 90.3530, radiusM: 150), isNull);
  });

  test('outside it the distance is given', () {
    // about 1.1 km north
    final d = farFromPinM(fix: at(22.7110, 90.3530), pinLat: 22.7010, pinLng: 90.3530, radiusM: 150);
    expect(d, isNotNull);
    expect(d!, inInclusiveRange(1050, 1170));
  });

  test('no fix or no pin: no warning (nothing to compare)', () {
    expect(farFromPinM(fix: null, pinLat: 22.7, pinLng: 90.35, radiusM: 150), isNull);
    expect(farFromPinM(fix: at(22.7, 90.35), pinLat: null, pinLng: null, radiusM: 150), isNull);
  });

  test('the radius comes from the server setting, 150 m until it says', () {
    expect(geofenceRadiusM(const {}), 150);
    expect(geofenceRadiusM(const {'geofenceRadiusM': 300}), 300);
  });
}
