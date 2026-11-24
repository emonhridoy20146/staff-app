import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/auth/secure_store.dart';
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

  test('reinstall with the same ANDROID_ID: the same id (secure storage was wiped)', () async {
    Future<String?> android() async => 'a1b2c3d4e5f60718';
    final first = await DeviceIdentity.resolveDeviceId(MemorySecureStore(), android);
    final afterReinstall = await DeviceIdentity.resolveDeviceId(MemorySecureStore(), android);
    expect(afterReinstall, first);
    expect(first, DeviceIdentity.stableDeviceId('a1b2c3d4e5f60718'));
  });

  test('an app update keeps the stored id, even an old random one (ADR-M25)', () async {
    final store = MemorySecureStore();
    await store.write('device_id', '0193a5e2-1111-7000-8000-000000000001');
    var asked = false;
    final id = await DeviceIdentity.resolveDeviceId(store, () async {
      asked = true;
      return 'a1b2c3d4e5f60718';
    });
    expect(id, '0193a5e2-1111-7000-8000-000000000001');
    expect(asked, isFalse);
  });

  test('no ANDROID_ID (channel fails): a random id, stored and then kept', () async {
    final store = MemorySecureStore();
    final id = await DeviceIdentity.resolveDeviceId(store, () async => throw Exception('no channel'));
    expect(await store.read('device_id'), id);
    expect(await DeviceIdentity.resolveDeviceId(store, () async => 'a1b2c3d4e5f60718'), id);
  });
}
