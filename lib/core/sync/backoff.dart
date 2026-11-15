import 'dart:math';

/// Exponential backoff with full jitter, capped at 15 min (FR-M-003).
class Backoff {
  Backoff({Random? random, this.base = const Duration(seconds: 5), this.cap = const Duration(minutes: 15)})
      : _random = random ?? Random();
  final Random _random;
  final Duration base;
  final Duration cap;

  /// Delay before attempt number [attempts] (1-based count of failures).
  Duration delayFor(int attempts) {
    final exp = base.inMilliseconds * pow(2, max(0, attempts - 1));
    final capped = min(exp.toDouble(), cap.inMilliseconds.toDouble());
    // Full jitter in [capped/2, capped] keeps a floor so retries are not instant.
    final ms = capped / 2 + _random.nextDouble() * capped / 2;
    return Duration(milliseconds: ms.round());
  }
}
