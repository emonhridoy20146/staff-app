import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/location/location_engine.dart';
import 'package:staff_app/features/customers/src/pin_correction.dart';

GeoFix fix({double lat = 22.70, double lng = 90.35, double acc = 12, bool mock = false}) =>
    GeoFix(lat: lat, lng: lng, accuracyM: acc, fixAt: DateTime.utc(2026, 11, 15, 4), mock: mock);

void main() {
  test('pin fix rules mirror the server (FR-CUS-008)', () {
    expect(checkPinFix(fix()), PinFixProblem.none);
    expect(checkPinFix(null), PinFixProblem.noFix);
    expect(checkPinFix(fix(mock: true)), PinFixProblem.mock);
    expect(checkPinFix(fix(acc: 30)), PinFixProblem.none);
    expect(checkPinFix(fix(acc: 31)), PinFixProblem.weak);
    expect(checkPinFix(fix(lat: 0, lng: 0)), PinFixProblem.outside);
    expect(checkPinFix(fix(lat: 22.57, lng: 88.36)), PinFixProblem.none, reason: 'west border area is inside the box');
  });
}
