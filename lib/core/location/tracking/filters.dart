import 'dart:math' as math;

import '../location_engine.dart';
import 'tracking_provider.dart';

/// Why a point was dropped on the phone (mirrors server reject reasons).
enum DropReason { lowAccuracy, impossibleSpeed, futureTime, duplicate }

/// Beyond this a fix is noise (a cell tower). Between `maxAccuracyM` and this
/// the point is sent and the server keeps it for the live map only
/// (field-api ADR-041, ADR-M20): indoors a phone often reports 100–500 m.
const hardMaxAccuracyM = 5000;

/// Point filters (04-architecture §5.5): accuracy ≤ [hardMaxAccuracyM],
/// speed ≤ 120 km/h from the previous kept point (allowing for both fixes'
/// accuracy), not in the future, de-duplicated.
DropReason? checkPoint(RawLocation p, RawLocation? prev, {required DateTime now}) {
  if (p.acc > hardMaxAccuracyM) return DropReason.lowAccuracy;
  if (p.t.isAfter(now.add(const Duration(minutes: 2)))) return DropReason.futureTime;
  if (prev != null) {
    final dt = p.t.difference(prev.t).inMilliseconds / 1000;
    if (dt <= 0) return DropReason.duplicate;
    final d = distanceMeters(prev.lat, prev.lng, p.lat, p.lng);
    if (dt < 5 && d < 2) return DropReason.duplicate;
    final slack = prev.acc + p.acc; // GPS error is not movement
    if (math.max(0, d - slack) / dt > 120 / 3.6) return DropReason.impossibleSpeed;
  }
  return null;
}
