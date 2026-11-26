import 'dart:convert';

import 'package:flutter/services.dart';

/// Bridge to the Android `LocationTrackingService` (and the battery / OEM screens) over the app's method
/// channel. Every call swallows platform errors: tracking must never crash the app, and on a platform without
/// the channel (tests, iOS later) the "probe" calls answer `null` = unknown, which the UI treats as no problem.
class NativeTrackingService {
  static const _channel = MethodChannel('com.howlader.staff/permissions');

  /// Hands the native service what it needs to upload points while the app is closed (FR-M-077): the API base
  /// URL, the points-only tracking token (contract 1.49.0, never the 15-minute access token) with its expiry,
  /// the device id, and the notification line shown when the server refuses the token ([reauthText]).
  static Future<void> storeCredentials({
    required String apiBaseUrl,
    required String trackingToken,
    required DateTime expiresAt,
    required String deviceId,
    required String reauthText,
  }) async {
    try {
      await _channel.invokeMethod('storeTrackingCredentials', {
        'apiBaseUrl': apiBaseUrl,
        'trackingToken': trackingToken,
        'expiresAtMs': expiresAt.toUtc().millisecondsSinceEpoch,
        'deviceId': deviceId,
        'reauthText': reauthText,
      });
    } catch (_) {}
  }

  /// Forgets the tracking token on the native side (duty end, logout). Buffered points stay on the phone.
  static Future<void> clearCredentials() async {
    try {
      await _channel.invokeMethod('clearTrackingCredentials');
    } catch (_) {}
  }

  static Future<void> start({required String title, required String text}) async {
    try {
      await _channel.invokeMethod('startNativeTracking', {'title': title, 'text': text});
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stopNativeTracking');
    } catch (_) {}
  }

  static Future<bool> isRunning() async => await probeRunning() ?? false;

  /// Whether the native service runs; null when unknown (no channel).
  static Future<bool?> probeRunning() => _probe<bool>('isNativeTrackingRunning');

  /// True when the server refused the tracking token (401/403) or it ran out; null when unknown.
  static Future<bool?> probeAuthFailed() => _probe<bool>('isTrackingAuthFailed');

  /// True while Android may stop the app to save battery; null when unknown.
  static Future<bool?> probeBatteryOptimised() => _probe<bool>('isBatteryOptimised');

  /// `Build.MANUFACTURER` (e.g. "Xiaomi"); null when unknown.
  static Future<String?> manufacturer() => _probe<String>('manufacturer');

  /// Shows Android's "ignore battery optimisations" dialog; answers granted / denied, null when unknown.
  static Future<String?> requestIgnoreBatteryOptimisations() => _probe<String>('requestBatteryOptimisation');

  /// Opens the brand's autostart / background screen (Xiaomi, Oppo, Vivo, Realme, Samsung, …) or the closest
  /// stock screen; false when none could be opened.
  static Future<bool> openBackgroundSettings() async => await _probe<bool>('openBatterySettings') ?? false;

  static Future<T?> _probe<T>(String method) async {
    try {
      return await _channel.invokeMethod<T>(method);
    } catch (_) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> readBufferedPoints() async {
    try {
      final json = await _channel.invokeMethod<String>('readBufferedPoints');
      if (json == null || json == '[]') return [];
      final list = jsonDecode(json) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
