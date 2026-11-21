import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/location/tracking/free_tracking_provider.dart';
import 'package:staff_app/core/location/tracking/sampling.dart';

/// FR-M-056: one "on duty" notification, not two.
void main() {
  final profile = profileFor(Activity.unknown, const SamplingConfig());

  test('while the native service runs, the position stream opens no notification of its own', () {
    final s = trackingSettings(profile, nativeRunning: true, title: 'ডিউটিতে', text: 'অবস্থান');
    expect(s.foregroundNotificationConfig, isNull);
    expect(s.distanceFilter, profile.distanceFilterM);
    expect(s.intervalDuration, profile.interval);
  });

  test('without the native service, geolocator keeps one so tracking never runs without a notification', () {
    final s = trackingSettings(profile, nativeRunning: false, title: 'ডিউটিতে', text: 'অবস্থান');
    expect(s.foregroundNotificationConfig, isNotNull);
    expect(s.foregroundNotificationConfig!.notificationTitle, 'ডিউটিতে');
    expect(s.foregroundNotificationConfig!.setOngoing, isTrue);
  });
}
