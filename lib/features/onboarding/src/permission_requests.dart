import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Requests runtime permissions after the primer explained them.
/// Camera and notification prompts are raised by their own plugins on
/// first use; battery optimisation opens the OEM guide (phase 2).
abstract class PermissionRequester {
  Future<bool> request(String id);
}

class PlatformPermissionRequester implements PermissionRequester {
  @override
  Future<bool> request(String id) async {
    try {
      switch (id) {
        case 'location':
          final p = await Geolocator.requestPermission();
          return p == LocationPermission.always || p == LocationPermission.whileInUse;
        default:
          return true;
      }
    } catch (_) {
      return false;
    }
  }
}

class AlwaysGrantRequester implements PermissionRequester {
  @override
  Future<bool> request(String id) async => true;
}

final permissionRequesterProvider = Provider<PermissionRequester>((ref) => PlatformPermissionRequester());
