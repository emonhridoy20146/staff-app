import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
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
    final id = await resolveDeviceId(store, () => const MethodChannel('com.howlader.staff/permissions').invokeMethod<String>('androidId'));
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

  /// The id this install uses (FR-M-060, ADR-M25). A stored id is kept, so an app update never changes it (it is
  /// the one the office approved). Without one (first install, or a reinstall: Android wipes secure storage on
  /// uninstall) it is derived from ANDROID_ID, so a reinstall on the same phone gives the same id and needs no new
  /// approval. A random id only when the phone does not give a usable ANDROID_ID.
  static Future<String> resolveDeviceId(SecureStore store, Future<String?> Function() readAndroidId) async {
    final stored = await store.read('device_id');
    if (stored != null) return stored;
    String? androidId;
    try {
      androidId = await readAndroidId();
    } catch (_) {}
    final id = stableDeviceId(androidId) ?? const Uuid().v7();
    await store.write('device_id', id);
    return id;
  }

  /// The same UUID for the same ANDROID_ID every time (name-based v5), or null without one.
  /// ANDROID_ID is per signing key, phone and user; it changes only on a factory reset.
  static String? stableDeviceId(String? androidId) {
    final a = androidId?.trim() ?? '';
    // 9774d56d682e549c: the id some old emulators and broken builds share; never trust it.
    if (a.isEmpty || a == '9774d56d682e549c') return null;
    return const Uuid().v5(Namespace.url.value, 'bd.howlader.staff_app/device/$a');
  }

  static const demo = DeviceIdentity(
    deviceId: '0193a5e2-0000-7000-8000-00000000a001',
    appVersion: '0.1.0',
    label: 'android 14; demo',
  );
}
