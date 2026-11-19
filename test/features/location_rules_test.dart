import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/location/location_engine.dart';
import 'package:staff_app/core/location/tracking/filters.dart';
import 'package:staff_app/core/location/tracking/sampling.dart';
import 'package:staff_app/core/location/tracking/tracking_provider.dart';

RawLocation at(int sec, {double lat = 22.7010, double lng = 90.3535, double acc = 10}) =>
    RawLocation(t: DateTime.utc(2026, 11, 15, 4).add(Duration(seconds: sec)), lat: lat, lng: lng, acc: acc);

void main() {
  final now = DateTime.utc(2026, 11, 15, 5);

  group('point filters', () {
    test('keeps a good point', () => expect(checkPoint(at(0), null, now: now), isNull));
    test('keeps a rough indoor fix for the live map (ADR-M20), drops only noise beyond 5 km', () {
      expect(checkPoint(at(0, acc: 300), null, now: now), isNull);
      expect(checkPoint(at(0, acc: 6000), null, now: now), DropReason.lowAccuracy);
    });
    test('drops points more than 2 min in the future', () {
      expect(checkPoint(at(3600 + 180), null, now: now), DropReason.futureTime);
      expect(checkPoint(at(3600 + 60), null, now: now), isNull);
    });
    test('drops same-time and near-identical points', () {
      expect(checkPoint(at(10), at(10), now: now), DropReason.duplicate);
      expect(checkPoint(at(12, lat: 22.701001), at(10), now: now), DropReason.duplicate);
    });
    test('drops a jump faster than 120 km/h', () {
      // ~1.1 km in 10 s ≈ 400 km/h.
      expect(checkPoint(at(10, lat: 22.711), at(0), now: now), DropReason.impossibleSpeed);
      // ~110 m in 10 s ≈ 40 km/h.
      expect(checkPoint(at(10, lat: 22.702), at(0), now: now), isNull);
      // GPS error is not movement: a 200 m fix 300 m away 10 s later is jitter.
      expect(checkPoint(at(10, lat: 22.7037, acc: 200), at(0), now: now), isNull);
    });
  });

  group('sampling', () {
    test('activity from speed', () {
      expect(activityFromSpeed(null), Activity.unknown);
      expect(activityFromSpeed(0.2), Activity.still);
      expect(activityFromSpeed(1.4), Activity.walking);
      expect(activityFromSpeed(4), Activity.onBicycle);
      expect(activityFromSpeed(12), Activity.inVehicle);
    });
    test('profile intervals come from the server config', () {
      final c = SamplingConfig.fromJson({'fastSec': 10, 'slowSec': 30, 'stillSec': 300});
      expect(profileFor(Activity.inVehicle, c).interval, const Duration(seconds: 10));
      expect(profileFor(Activity.walking, c).interval, const Duration(seconds: 30));
      expect(profileFor(Activity.still, c).interval, const Duration(minutes: 5));
      expect(const SamplingConfig().maxAccuracyM, 50);
    });
  });

  group('provider choice (admin setting location.trackingProvider)', () {
    final free = FakeTrackingProvider();
    final paidMissing = FakeTrackingProvider(id: 'paid', isAvailable: false);
    final paid = FakeTrackingProvider(id: 'paid');
    test('free by default', () {
      final r = selectTrackingProvider(null, [free, paid]);
      expect((r.provider.id, r.fellBack), ('free', false));
    });
    test('paid when compiled in', () {
      final r = selectTrackingProvider('paid', [free, paid]);
      expect((r.provider.id, r.fellBack), ('paid', false));
    });
    test('paid falls back to free when this build lacks it', () {
      final r = selectTrackingProvider('paid', [free, paidMissing]);
      expect((r.provider.id, r.fellBack), ('free', true));
    });
  });

  test('geo fields: fix or explicit reason (contract 1.2.0)', () {
    expect(geoFields(null, 'permission_denied'), {'geo': null, 'geoUnavailableReason': 'permission_denied'});
    expect(geoFields(null, null), {'geo': null, 'geoUnavailableReason': 'no_fix'});
  });
}
