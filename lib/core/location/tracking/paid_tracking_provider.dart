import 'sampling.dart';
import 'tracking_provider.dart';

/// Slot for the licensed background-geolocation SDK (OD-M06).
///
/// This build does NOT contain the paid plugin, so [isAvailable] is false
/// and the app falls back to the free provider even if the admin setting
/// says `paid`. To enable it:
/// 1. buy the licence for app id `bd.howlader.staff_app`;
/// 2. add the plugin to pubspec and implement this class against it
///    (map its location events to [RawLocation], `start/stop/changePace`);
/// 3. put the licence key in the CI secret `LOCATION_LICENSE_KEY` (it is
///    read at build time into the Android manifest — never in the repo, never
///    in server settings);
/// 4. ship that APK. From then on the admin setting
///    `location.trackingProvider` switches between free and paid at runtime,
///    with no further app update.
class PaidTrackingProvider implements TrackingProvider {
  @override
  String get id => 'paid';
  @override
  bool get isAvailable => false;
  @override
  bool get isRunning => false;
  @override
  Stream<RawLocation> get points => const Stream.empty();
  @override
  Future<TrackingHealth> health() async => const TrackingHealth(gpsEnabled: false, permission: 'denied');
  @override
  Future<void> start(SamplingProfile profile, {required String notificationTitle, required String notificationText}) =>
      throw UnsupportedError('Paid tracking provider is not in this build');
  @override
  Future<void> updateProfile(SamplingProfile profile) async {}
  @override
  Future<void> stop() async {}
}
