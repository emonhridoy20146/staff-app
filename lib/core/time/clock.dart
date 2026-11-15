/// Server-offset-aware clock with Asia/Dhaka business dates.
///
/// Domain and application code must use [Clock] instead of `DateTime.now()`
/// (CLAUDE.md §2.12) so tests can freeze time and device clock skew is
/// corrected by the server offset received in every pull / login.
///
/// Asia/Dhaka is UTC+06:00 with no DST since 2009, so a fixed offset is exact
/// and avoids shipping the tz database (APK size, NFR-M-001).
library;

const dhakaOffset = Duration(hours: 6);

abstract class Clock {
  /// Device time in UTC (uncorrected). Stored as `deviceTime` on mutations.
  DateTime deviceNowUtc();

  /// Offset to add to device time to get server time.
  Duration get serverOffset;

  /// Best estimate of real time (device + server offset), UTC.
  DateTime nowUtc() => deviceNowUtc().add(serverOffset);

  /// Current wall-clock time in Dhaka (as a UTC DateTime shifted by +6h;
  /// only use its fields for display/business-date purposes).
  DateTime nowDhaka() => toDhaka(nowUtc());

  /// Today's business date `YYYY-MM-DD` in Dhaka.
  String businessDate() => businessDateOf(nowUtc());

  /// Update offset from a server timestamp (login, pull, push responses).
  void syncWithServer(DateTime serverTimeUtc);
}

DateTime toDhaka(DateTime utc) => utc.toUtc().add(dhakaOffset);

String businessDateOf(DateTime utc) {
  final d = toDhaka(utc);
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

/// Parses `YYYY-MM-DD` to a UTC midnight date (date-only arithmetic).
DateTime parseBusinessDate(String s) {
  final p = s.split('-').map(int.parse).toList();
  return DateTime.utc(p[0], p[1], p[2]);
}

/// Days from [from] to [to] (both `YYYY-MM-DD`).
int daysBetween(String from, String to) =>
    parseBusinessDate(to).difference(parseBusinessDate(from)).inDays;

class SystemClock extends Clock {
  Duration _offset = Duration.zero;

  @override
  DateTime deviceNowUtc() => DateTime.now().toUtc();

  @override
  Duration get serverOffset => _offset;

  @override
  void syncWithServer(DateTime serverTimeUtc) {
    _offset = serverTimeUtc.toUtc().difference(deviceNowUtc());
  }

  /// Restores a persisted offset at startup.
  set offset(Duration d) => _offset = d;
}

/// Test clock; time only moves when told to.
class FixedClock extends Clock {
  FixedClock(this._now, {Duration offset = Duration.zero}) : _offset = offset;
  DateTime _now;
  Duration _offset;

  void advance(Duration d) => _now = _now.add(d);
  set now(DateTime v) => _now = v;

  @override
  DateTime deviceNowUtc() => _now.toUtc();

  @override
  Duration get serverOffset => _offset;

  @override
  void syncWithServer(DateTime serverTimeUtc) {
    _offset = serverTimeUtc.toUtc().difference(deviceNowUtc());
  }
}
