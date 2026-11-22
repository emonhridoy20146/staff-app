import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/location/location_engine.dart';
import 'package:staff_app/features/customers/src/domain/map_pin.dart';

GeoFix fix({double lat = 22.70, double lng = 90.35, double acc = 12, bool mock = false}) =>
    GeoFix(lat: lat, lng: lng, accuracyM: acc, fixAt: DateTime.utc(2026, 11, 15, 4), mock: mock);

MapPinCheck check({double lat = 22.7, double lng = 90.35, GeoFix? phone, bool hasPin = false, StaffPinApproval policy = StaffPinApproval.whenMissing, bool approver = false}) =>
    checkMapPin(lat: lat, lng: lng, phone: phone, customerHasUsablePin: hasPin, policy: policy, canApprove: approver);

void main() {
  group('map pin rules mirror field-api 1.11.0 (FR-CUS-011)', () {
    test('a pin for a customer without a usable pin applies at once under when_missing', () {
      expect(check(phone: fix()).appliesAtOnce, isTrue);
      expect(check().appliesAtOnce, isTrue, reason: 'no phone fix does not block it');
      expect(check(phone: fix(acc: 400)).appliesAtOnce, isTrue, reason: 'a map pin is not held to GPS accuracy');
    });

    test('moving a usable pin, a mocked phone or the always policy waits for a manager', () {
      expect(check(hasPin: true, phone: fix()).appliesAtOnce, isFalse);
      final mock = check(phone: fix(mock: true));
      expect(mock.appliesAtOnce, isFalse);
      expect(mock.phoneMock, isTrue);
      expect(check(policy: StaffPinApproval.always, phone: fix()).appliesAtOnce, isFalse);
    });

    test('a user who can approve pins (customer.location.approve, 1.39.0) sets the pin at once whatever the policy', () {
      expect(check(approver: true, hasPin: true, phone: fix()).appliesAtOnce, isTrue, reason: 'moving an existing pin');
      expect(check(approver: true, policy: StaffPinApproval.always, hasPin: true).appliesAtOnce, isTrue, reason: 'policy always');
      expect(check(approver: true).appliesAtOnce, isTrue);
      expect(check(approver: true, phone: fix(mock: true)).appliesAtOnce, isFalse, reason: 'a mocked phone still waits');
    });

    test('field staff (no approve key) still send a proposal when the rules say so', () {
      expect(check(hasPin: true, phone: fix()).appliesAtOnce, isFalse);
      expect(check(policy: StaffPinApproval.always).appliesAtOnce, isFalse);
      expect(check().appliesAtOnce, isTrue, reason: 'no usable pin under when_missing is unchanged');
    });

    test('outside Bangladesh cannot be sent', () {
      expect(check(lat: 0, lng: 0).canSend, isFalse);
      expect(check(lat: 22.57, lng: 88.36).canSend, isTrue, reason: 'west border area is inside the box');
    });

    test('distance from the phone, far above 300 m', () {
      expect(check(phone: fix()).phoneDistanceM, 0);
      expect(check().phoneDistanceM, isNull);
      expect(check().farFromPhone, isFalse);
      final near = check(lat: 22.7020, phone: fix()); // ≈ 222 m north
      expect(near.phoneDistanceM, inInclusiveRange(215, 230));
      expect(near.farFromPhone, isFalse);
      expect(check(lat: 22.7040, phone: fix()).farFromPhone, isTrue);
    });

    test('policy setting: anything but "always" is when_missing', () {
      expect(StaffPinApproval.parse('always'), StaffPinApproval.always);
      expect(StaffPinApproval.parse('when_missing'), StaffPinApproval.whenMissing);
      expect(StaffPinApproval.parse(null), StaffPinApproval.whenMissing);
    });
  });

  group('coordinates typed or shared', () {
    test('plain pairs, degrees, links and Bangla digits', () {
      expect(parseCoords('22.70123, 90.37011'), (lat: 22.70123, lng: 90.37011));
      expect(parseCoords('22.70123 90.37011'), (lat: 22.70123, lng: 90.37011));
      expect(parseCoords('22.70123° N, 90.37011° E'), (lat: 22.70123, lng: 90.37011));
      expect(parseCoords('https://www.google.com/maps/place/Shop/@22.7012,90.3701,17z'), (lat: 22.7012, lng: 90.3701));
      expect(parseCoords('https://maps.google.com/?q=22.7012,90.3701'), (lat: 22.7012, lng: 90.3701));
      expect(parseCoords('২২.৭০১২৩, ৯০.৩৭০১১'), (lat: 22.70123, lng: 90.37011));
    });

    test('longitude first is swapped back; nonsense is refused', () {
      expect(parseCoords('90.37011, 22.70123'), (lat: 22.70123, lng: 90.37011));
      expect(parseCoords(''), isNull);
      expect(parseCoords('house near the mosque'), isNull);
      expect(parseCoords('22.7'), isNull);
      expect(parseCoords('22.7, 90.3, 17'), isNull);
      expect(parseCoords('200, 300'), isNull);
    });

    test('five decimals', () => expect(formatCoords(22.7, 90.370114), '22.70000, 90.37011'));
  });
}
