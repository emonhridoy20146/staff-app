import '../location_engine.dart';
import 'tracking_provider.dart';

/// Why a point was dropped on the phone (mirrors server reject reasons).
enum DropReason { lowAccuracy, impossibleSpeed, futureTime, duplicate }

/// Point filters (04-architecture §5.5): accuracy ≤ max, speed ≤ 120 km/h
/// from the previous kept point, not in the future, de-duplicated.
DropReason? checkPoint(RawLocation p, RawLocation? prev, {required DateTime now, int maxAccuracyM = 50}) {
  if (p.acc > maxAccuracyM) return DropReason.lowAccuracy;
  if (p.t.isAfter(now.add(const Duration(minutes: 2)))) return DropReason.futureTime;
  if (prev != null) {
    final dt = p.t.difference(prev.t).inMilliseconds / 1000;
    if (dt <= 0) return DropReason.duplicate;
    final d = distanceMeters(prev.lat, prev.lng, p.lat, p.lng);
    if (dt < 5 && d < 2) return DropReason.duplicate;
    if (d / dt > 120 / 3.6) return DropReason.impossibleSpeed;
  }
  return null;
}
