import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/tracking/native_tracking_service.dart';
import '../../../core/permissions/permission_service.dart';
import '../../attendance/attendance.dart';
import 'location_tracker.dart';

/// What the phone reports about background tracking. `null` = unknown (no native channel, e.g. in tests or on a
/// platform without the service): unknown is never shown as a problem.
class DeviceTrackingProbe {
  const DeviceTrackingProbe({this.nativeRunning, this.authFailed, this.batteryOptimised, this.manufacturer});
  final bool? nativeRunning;
  final bool? authFailed;
  final bool? batteryOptimised;
  final String? manufacturer;
}

/// Reads the native side; overridable in tests.
abstract class TrackingProbe {
  Future<DeviceTrackingProbe> read();
}

class NativeTrackingProbe implements TrackingProbe {
  const NativeTrackingProbe();
  @override
  Future<DeviceTrackingProbe> read() async => DeviceTrackingProbe(
        nativeRunning: await NativeTrackingService.probeRunning(),
        authFailed: await NativeTrackingService.probeAuthFailed(),
        batteryOptimised: await NativeTrackingService.probeBatteryOptimised(),
        manufacturer: await NativeTrackingService.manufacturer(),
      );
}

final trackingProbeProvider = Provider<TrackingProbe>((ref) => const NativeTrackingProbe());

/// The worst background-tracking problem while on duty (FR-M-078), most serious first.
enum TrackingIssue {
  /// On duty but nothing is tracking (the Dart tracker or the native service is not running).
  notRunning,

  /// The server refused the tracking token; the app is renewing it.
  authRefused,

  /// Android may stop the app to save battery.
  batteryOptimised,
}

/// Pure rule (unit-tested). Off duty there is never an issue: tracking is off on purpose (CLAUDE.md §2.6).
TrackingIssue? trackingIssueFor({required bool onDuty, required bool locationOn, required bool trackerRunning, required DeviceTrackingProbe probe}) {
  if (!onDuty || !locationOn) return null;
  if (!trackerRunning || probe.nativeRunning == false) return TrackingIssue.notRunning;
  if (probe.authFailed == true) return TrackingIssue.authRefused;
  if (probe.batteryOptimised == true) return TrackingIssue.batteryOptimised;
  return null;
}

/// The device probe, read again every minute and when the tracker's state changes.
final trackingProbeStateProvider = FutureProvider<DeviceTrackingProbe>((ref) async {
  ref.watch(minuteTickerProvider);
  ref.watch(trackingStatusProvider.select((s) => s.running));
  return ref.watch(trackingProbeProvider).read();
});

bool _onDuty(Ref ref) {
  final s = ref.watch(todayAttendanceProvider).value?.status;
  return s == DayStatus.onDuty || s == DayStatus.onBreak;
}

final trackingOnDutyProvider = Provider<bool>(_onDuty);

final trackingIssueProvider = Provider<TrackingIssue?>((ref) {
  final probe = ref.watch(trackingProbeStateProvider).value;
  if (probe == null) return null;
  final issue = trackingIssueFor(
    onDuty: ref.watch(trackingOnDutyProvider),
    locationOn: ref.watch(accessProvider).flag('module.location'),
    trackerRunning: ref.watch(trackingStatusProvider).running,
    probe: probe,
  );
  // A refused token is renewed at once while the app is open (FR-M-077).
  if (issue == TrackingIssue.authRefused) unawaited(ref.read(locationTrackerProvider).ensureTrackingToken(force: true));
  return issue;
});
