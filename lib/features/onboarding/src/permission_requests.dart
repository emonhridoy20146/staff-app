import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Result of a permission request: granted, denied (can ask again), or
/// permanently denied (must open settings).
enum PermissionResult { granted, denied, permanentlyDenied }

/// Requests runtime permissions after the primer explained them.
abstract class PermissionRequester {
  Future<PermissionResult> request(String id);
  Future<bool> isGranted(String id);
}

class PlatformPermissionRequester implements PermissionRequester {
  static const _channel = MethodChannel('com.howlader.staff/permissions');

  @override
  Future<PermissionResult> request(String id) async {
    try {
      switch (id) {
        case 'location':
          final p = await Geolocator.requestPermission();
          if (p == LocationPermission.always || p == LocationPermission.whileInUse) return PermissionResult.granted;
          if (p == LocationPermission.deniedForever) return PermissionResult.permanentlyDenied;
          return PermissionResult.denied;
        case 'camera':
          final r = await _channel.invokeMethod<String>('requestCamera');
          return _parse(r);
        case 'notifications':
          final r = await _channel.invokeMethod<String>('requestNotifications');
          return _parse(r);
        case 'battery':
          final r = await _channel.invokeMethod<String>('requestBatteryOptimisation');
          return _parse(r);
        default:
          return PermissionResult.granted;
      }
    } catch (_) {
      return PermissionResult.denied;
    }
  }

  @override
  Future<bool> isGranted(String id) async {
    try {
      switch (id) {
        case 'location':
          final p = await Geolocator.checkPermission();
          return p == LocationPermission.always || p == LocationPermission.whileInUse;
        case 'camera':
          final r = await _channel.invokeMethod<bool>('isCameraGranted');
          return r ?? false;
        case 'notifications':
          final r = await _channel.invokeMethod<bool>('isNotificationsGranted');
          return r ?? false;
        case 'battery':
          final r = await _channel.invokeMethod<bool>('isBatteryOptimised');
          return !(r ?? true);
        default:
          return true;
      }
    } catch (_) {
      return false;
    }
  }

  static PermissionResult _parse(String? r) => switch (r) {
        'granted' => PermissionResult.granted,
        'permanently_denied' => PermissionResult.permanentlyDenied,
        _ => PermissionResult.denied,
      };
}

class AlwaysGrantRequester implements PermissionRequester {
  @override
  Future<PermissionResult> request(String id) async => PermissionResult.granted;
  @override
  Future<bool> isGranted(String id) async => true;
}

final permissionRequesterProvider = Provider<PermissionRequester>((ref) => PlatformPermissionRequester());
