/// Sampling (04-architecture §5.5): interval by activity, from the server
/// setting `location.sampling` / the `nextSampling` the server returns.
class SamplingConfig {
  const SamplingConfig({this.fastSec = 15, this.slowSec = 45, this.stillSec = 180, this.distanceFilterM = 25, this.maxAccuracyM = 50});

  factory SamplingConfig.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const SamplingConfig();
    int v(String k, int d) => (j[k] as num?)?.toInt() ?? d;
    return SamplingConfig(
      fastSec: v('fastSec', 15),
      slowSec: v('slowSec', 45),
      stillSec: v('stillSec', 180),
      distanceFilterM: v('distanceFilterM', 25),
      maxAccuracyM: v('maxAccuracyM', 50),
    );
  }

  final int fastSec;
  final int slowSec;
  final int stillSec;
  final int distanceFilterM;
  final int maxAccuracyM;
}

/// `LocationPoint.act` values.
enum Activity { still, walking, onBicycle, inVehicle, unknown }

extension ActivityWire on Activity {
  String get wire => switch (this) {
        Activity.still => 'still',
        Activity.walking => 'walking',
        Activity.onBicycle => 'on_bicycle',
        Activity.inVehicle => 'in_vehicle',
        Activity.unknown => 'unknown',
      };
}

/// Without an activity-recognition plugin (free stack) the activity is
/// inferred from speed: < 0.5 m/s still, < 2.5 walking, < 7 bicycle /
/// rickshaw, else vehicle.
Activity activityFromSpeed(double? mps) {
  if (mps == null || mps < 0) return Activity.unknown;
  if (mps < 0.5) return Activity.still;
  if (mps < 2.5) return Activity.walking;
  if (mps < 7) return Activity.onBicycle;
  return Activity.inVehicle;
}

class SamplingProfile {
  const SamplingProfile({required this.interval, required this.distanceFilterM, required this.name});
  final Duration interval;
  final int distanceFilterM;
  final String name;

  @override
  bool operator ==(Object other) => other is SamplingProfile && other.interval == interval && other.distanceFilterM == distanceFilterM;
  @override
  int get hashCode => Object.hash(interval, distanceFilterM);
}

SamplingProfile profileFor(Activity a, SamplingConfig c) => switch (a) {
      Activity.inVehicle || Activity.onBicycle => SamplingProfile(name: 'fast', interval: Duration(seconds: c.fastSec), distanceFilterM: c.distanceFilterM),
      Activity.walking => SamplingProfile(name: 'slow', interval: Duration(seconds: c.slowSec), distanceFilterM: 10),
      Activity.still => SamplingProfile(name: 'still', interval: Duration(seconds: c.stillSec), distanceFilterM: 0),
      Activity.unknown => SamplingProfile(name: 'slow', interval: Duration(seconds: c.slowSec), distanceFilterM: 10),
    };
