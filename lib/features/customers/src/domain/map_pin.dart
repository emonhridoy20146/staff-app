import '../../../../core/location/location_engine.dart';

/// Map pins (FR-CUS-011, contract 1.11.0): the staff moves the map under a
/// fixed pin, as ride apps pick a pick-up spot. These rules are pure so they
/// are unit-tested; the server decides for real.

/// Rough Bangladesh bounding box (the server does the exact check).
bool insideBangladesh(double lat, double lng) => lat >= 20.5 && lat <= 26.7 && lng >= 88.0 && lng <= 92.75;

/// Beyond this distance between the phone and the pin, the screen asks the
/// staff to check (the manager sees the same distance; admin-web flags 300 m).
const pinFarFromPhoneM = 300;

/// `customers.staffPinApproval` (per branch, exposed to the app).
enum StaffPinApproval {
  /// A pin for a customer with no usable location applies at once;
  /// moving an existing pin needs a manager (owner decision 2026-11-17).
  whenMissing,

  /// Every staff pin waits for a manager.
  always;

  static StaffPinApproval parse(Object? v) => v == 'always' ? always : whenMissing;
}

/// What sending this pin will do, shown before the staff sends it.
class MapPinCheck {
  const MapPinCheck({required this.outside, required this.appliesAtOnce, required this.phoneDistanceM, required this.phoneMock});

  /// Outside Bangladesh: cannot be sent.
  final bool outside;

  /// The server will set the pin when it arrives (no manager step).
  final bool appliesAtOnce;

  /// Metres between the phone and the pin; null when the phone has no fix.
  final int? phoneDistanceM;

  /// The phone reports a fake location: never applied at once.
  final bool phoneMock;

  bool get farFromPhone => phoneDistanceM != null && phoneDistanceM! > pinFarFromPhoneM;
  bool get canSend => !outside;
}

/// Mirrors field-api `proposeLocation` (method `map`): outside Bangladesh is
/// refused; a mocked phone location never applies at once. Otherwise the pin
/// applies at once when the user can approve pins ([canApprove]: holds
/// `customer.location.approve`, contract 1.39.0, FR-CUS-020), or under
/// `when_missing` for a customer without a usable pin.
MapPinCheck checkMapPin({
  required double lat,
  required double lng,
  required GeoFix? phone,
  required bool customerHasUsablePin,
  required StaffPinApproval policy,
  bool canApprove = false,
}) {
  final mock = phone?.mock ?? false;
  return MapPinCheck(
    outside: !insideBangladesh(lat, lng),
    appliesAtOnce: !mock && (canApprove || (policy == StaffPinApproval.whenMissing && !customerHasUsablePin)),
    phoneDistanceM: phone == null ? null : distanceMeters(phone.lat, phone.lng, lat, lng),
    phoneMock: mock,
  );
}

/// Reads coordinates someone pasted or shared: `22.70123, 90.37011`,
/// `22.70123 90.37011`, `22.70123° N, 90.37011° E`, or a maps link with
/// `@lat,lng`, `q=lat,lng` or `ll=lat,lng`. Bangla digits are accepted.
/// A longitude-first pair is swapped when only the swapped pair is in
/// Bangladesh. Same rules as admin-web `parseCoords`.
({double lat, double lng})? parseCoords(String text) {
  final ascii = text.replaceAllMapped(RegExp('[০-৯]'), (m) => '${m[0]!.codeUnitAt(0) - 0x09E6}').trim();
  if (ascii.isEmpty) return null;
  final link = RegExp(r'[@=](-?\d{1,3}\.\d+),\s*(-?\d{1,3}\.\d+)').firstMatch(ascii);
  final nums = link != null ? [link[1]!, link[2]!] : RegExp(r'-?\d{1,3}(?:\.\d+)?').allMatches(ascii).map((m) => m[0]!).toList();
  if (nums.length != 2) return null;
  var lat = double.tryParse(nums[0]);
  var lng = double.tryParse(nums[1]);
  if (lat == null || lng == null) return null;
  if (RegExp(r'\d\s*°?\s*S\b', caseSensitive: false).hasMatch(ascii)) lat = -lat.abs();
  if (RegExp(r'\d\s*°?\s*W\b', caseSensitive: false).hasMatch(ascii)) lng = -lng.abs();
  if (lat.abs() > 90 && lng.abs() <= 90) (lat, lng) = (lng, lat);
  if (lat.abs() > 90 || lng.abs() > 180) return null;
  if (!insideBangladesh(lat, lng) && insideBangladesh(lng, lat)) (lat, lng) = (lng, lat);
  return (lat: lat, lng: lng);
}

/// `22.70123, 90.37011`: five decimals ≈ 1 m.
String formatCoords(double lat, double lng) => '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
