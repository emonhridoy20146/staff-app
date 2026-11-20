import 'dart:convert';

import 'package:flutter/services.dart';

class NativeTrackingService {
  static const _channel = MethodChannel('com.howlader.staff/permissions');

  static Future<void> storeCredentials({
    required String apiBaseUrl,
    required String accessToken,
    required String deviceId,
  }) async {
    try {
      await _channel.invokeMethod('storeTrackingCredentials', {
        'apiBaseUrl': apiBaseUrl,
        'accessToken': accessToken,
        'deviceId': deviceId,
      });
    } catch (_) {}
  }

  static Future<void> updateToken(String accessToken) async {
    try {
      await _channel.invokeMethod('updateTrackingToken', {
        'accessToken': accessToken,
      });
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

  static Future<bool> isRunning() async {
    try {
      return await _channel.invokeMethod<bool>('isNativeTrackingRunning') ?? false;
    } catch (_) {
      return false;
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
