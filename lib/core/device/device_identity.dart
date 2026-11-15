import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../auth/secure_store.dart';

/// Stable install id (`X-Device-Id`) + client label for `X-Client`.
class DeviceIdentity {
  const DeviceIdentity({required this.deviceId, required this.appVersion, required this.label, this.manufacturer = '', this.isPhysical = true});

  final String deviceId;
  final String appVersion;

  /// e.g. `android 10; Redmi 9A`
  final String label;
  final String manufacturer;
  final bool isPhysical;

  static Future<DeviceIdentity> load(SecureStore store) async {
    var id = await store.read('device_id');
    if (id == null) {
      id = const Uuid().v7();
      await store.write('device_id', id);
    }
    final pkg = await PackageInfo.fromPlatform();
    var label = 'android';
    var manufacturer = '';
    var physical = true;
    try {
      final a = await DeviceInfoPlugin().androidInfo;
      label = 'android ${a.version.release}; ${a.model}';
      manufacturer = a.manufacturer;
      physical = a.isPhysicalDevice;
    } catch (_) {}
    return DeviceIdentity(deviceId: id, appVersion: pkg.version, label: label, manufacturer: manufacturer, isPhysical: physical);
  }

  static const demo = DeviceIdentity(
    deviceId: '0193a5e2-0000-7000-8000-00000000a001',
    appVersion: '0.1.0',
    label: 'android 14; demo',
  );
}
