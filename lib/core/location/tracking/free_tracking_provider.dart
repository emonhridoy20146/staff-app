import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'native_tracking_service.dart';
import 'sampling.dart';
import 'tracking_provider.dart';

/// Free provider: geolocator position stream inside an Android foreground
/// service (persistent notification, wake lock). No licence needed.
///
/// Limits compared with a paid SDK: no activity recognition (speed is used),
/// no automatic restart after a reboot (the app restarts tracking the next
/// time it opens while still on duty), more sensitive to OEM battery savers.
class FreeTrackingProvider implements TrackingProvider {
  @override
  String get id => 'free';
  @override
  bool get isAvailable => defaultTargetPlatform == TargetPlatform.android;

  final _out = StreamController<RawLocation>.broadcast();
  StreamSubscription<Position>? _sub;
  String _title = '';
  String _text = '';

  @override
  bool get isRunning => _sub != null;

  @override
  Stream<RawLocation> get points => _out.stream;

  @override
  Future<void> start(SamplingProfile profile, {required String notificationTitle, required String notificationText}) async {
    _title = notificationTitle;
    _text = notificationText;
    await _listen(profile);
  }

  Future<void> _listen(SamplingProfile profile) async {
    await _sub?.cancel();
    final settings = trackingSettings(profile, nativeRunning: await NativeTrackingService.isRunning(), title: _title, text: _text);
    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (p) => _out.add(RawLocation(
        t: p.timestamp.toUtc(),
        lat: p.latitude,
        lng: p.longitude,
        acc: p.accuracy,
        spd: p.speed < 0 ? null : p.speed,
        hdg: p.heading < 0 ? null : p.heading,
        alt: p.altitude,
        mock: p.isMocked,
      )),
      onError: (Object _) {},
    );
  }

  @override
  Future<void> updateProfile(SamplingProfile profile) async {
    if (isRunning) await _listen(profile);
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  @override
  Future<TrackingHealth> health() async {
    final on = await Geolocator.isLocationServiceEnabled();
    final perm = await Geolocator.checkPermission();
    return TrackingHealth(
      gpsEnabled: on,
      permission: switch (perm) {
        LocationPermission.always => 'always',
        LocationPermission.whileInUse => 'while_in_use',
        _ => 'denied',
      },
    );
  }
}

/// The position-stream settings (FR-M-056). While the native tracking service
/// runs it already holds the one persistent "on duty" notification and keeps
/// the app a foreground location app, so geolocator starts no service of its
/// own: before, both showed, and staff saw two notifications while the app was
/// open. Only when the native service is not running (it failed to start)
/// does geolocator keep its own, so tracking never runs without one.
AndroidSettings trackingSettings(SamplingProfile profile, {required bool nativeRunning, required String title, required String text}) => AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: profile.distanceFilterM,
      intervalDuration: profile.interval,
      foregroundNotificationConfig: nativeRunning
          ? null
          : ForegroundNotificationConfig(
              notificationTitle: title,
              notificationText: text,
              notificationChannelName: 'Duty tracking',
              enableWakeLock: true,
              setOngoing: true,
            ),
    );
