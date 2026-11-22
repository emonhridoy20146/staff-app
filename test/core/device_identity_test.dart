import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/device/device_identity.dart';

void main() {
  test('the same phone gives the same device id after a reinstall (FR-M-060)', () {
    final a = DeviceIdentity.stableDeviceId('a1b2c3d4e5f60718');
    expect(a, isNotNull);
    expect(DeviceIdentity.stableDeviceId('a1b2c3d4e5f60718'), a);
    expect(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$').hasMatch(a!), isTrue);
    expect(DeviceIdentity.stableDeviceId('ffffeeeeddddcccc'), isNot(a));
  });

  test('no usable ANDROID_ID: no derived id (a random one is used instead)', () {
    expect(DeviceIdentity.stableDeviceId(null), isNull);
    expect(DeviceIdentity.stableDeviceId('  '), isNull);
    expect(DeviceIdentity.stableDeviceId('9774d56d682e549c'), isNull);
  });
}
