/// Duty hours and related limits as the server sends them (FR-M-047).
///
/// The server's settings are namespaced: the duty hours of a branch are one
/// value, `attendance.defaultShift` `{ start, end, weeklyOff, lateGraceMin,
/// maxBreakMin, breakWindows }`; the collect geofence is
/// `collections.geofenceM`; the cash limit behaviour is `cash.limitMode`.
/// The app used to read flat keys the server never sent (`dutyStart`,
/// `maxBreakMin`, `geofenceRadiusM`, `cashBlockOverLimit`), so what the office
/// set had no effect on the phone. These readers take the server's keys
/// first and the old flat ones only as a fallback. Pure, no I/O.
library;

/// A weekly break window (field-api FR-ATT-010): on [weekday] (0 = Sunday …
/// 5 = Friday, 6 = Saturday) break time between [start] and [end] (Dhaka
/// `HH:mm`) is allowed on top of the daily break limit.
class BreakWindow {
  const BreakWindow({required this.weekday, required this.start, required this.end});
  final int weekday;
  final String start;
  final String end;
}

final _hhmm = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

Duration _clock(String hhmm) {
  final p = hhmm.split(':');
  return Duration(hours: int.parse(p[0]), minutes: int.parse(p[1]));
}

class DutySettings {
  const DutySettings({
    this.start = '09:00',
    this.end = '18:00',
    this.lateGraceMin = 15,
    this.maxBreakMin = 60,
    this.weeklyOff = const [5],
    this.breakWindows = const [],
  });

  factory DutySettings.of(Map<String, dynamic> settings) {
    final raw = settings['attendance.defaultShift'];
    final s = raw is Map ? raw.cast<String, dynamic>() : const <String, dynamic>{};
    String time(String key, String legacy, String fallback) {
      final v = s[key] ?? settings[legacy];
      return v is String && _hhmm.hasMatch(v) ? v : fallback;
    }

    int minutes(String key, int fallback) {
      final v = s[key] ?? settings[key];
      return v is num && v >= 0 ? v.toInt() : fallback;
    }

    final off = s['weeklyOff'];
    final windows = s['breakWindows'];
    return DutySettings(
      start: time('start', 'dutyStart', '09:00'),
      end: time('end', 'dutyEnd', '18:00'),
      lateGraceMin: minutes('lateGraceMin', 15),
      maxBreakMin: minutes('maxBreakMin', 60),
      weeklyOff: off is List ? [for (final d in off) if (d is num && d >= 0 && d <= 6) d.toInt()] : const [5],
      breakWindows: [
        if (windows is List)
          for (final w in windows)
            if (w is Map && w['weekday'] is num && w['start'] is String && w['end'] is String && _hhmm.hasMatch(w['start'] as String) && _hhmm.hasMatch(w['end'] as String) && (w['start'] as String).compareTo(w['end'] as String) < 0)
              BreakWindow(weekday: (w['weekday'] as num).toInt(), start: w['start'] as String, end: w['end'] as String),
      ],
    );
  }

  final String start;
  final String end;
  final int lateGraceMin;
  final int maxBreakMin;

  /// 0 = Sunday … 6 = Saturday; may be empty (a branch that works every day).
  final List<int> weeklyOff;
  final List<BreakWindow> breakWindows;

  /// The windows of [businessDate] (`YYYY-MM-DD`, Dhaka).
  List<BreakWindow> windowsOn(String businessDate) {
    final weekday = DateTime.parse(businessDate).weekday % 7; // Dart: Mon = 1 … Sun = 7
    return [for (final w in breakWindows) if (w.weekday == weekday) w];
  }

  bool isWeeklyOff(String businessDate) => weeklyOff.contains(DateTime.parse(businessDate).weekday % 7);

  /// Break minutes held against the limit: break time inside a window of the
  /// day is free (same rule as the server's `deriveDay`). [breaks] are UTC
  /// spans, an open one ends at [now]; [dhakaMidnightUtc] is 00:00 Dhaka of
  /// the business day in UTC.
  int countedBreakMin(Iterable<({DateTime start, DateTime? end})> breaks, {required String businessDate, required DateTime dhakaMidnightUtc, required DateTime now}) {
    final windows = [
      for (final w in windowsOn(businessDate)) (start: dhakaMidnightUtc.add(_clock(w.start)), end: dhakaMidnightUtc.add(_clock(w.end))),
    ];
    var total = 0;
    var free = 0;
    for (final b in breaks) {
      final end = b.end ?? now;
      if (!end.isAfter(b.start)) continue;
      total += end.difference(b.start).inMinutes;
      for (final w in windows) {
        final from = b.start.isAfter(w.start) ? b.start : w.start;
        final to = end.isBefore(w.end) ? end : w.end;
        if (to.isAfter(from)) free += to.difference(from).inMinutes;
      }
    }
    return free >= total ? 0 : total - free;
  }

  /// Minutes over the break limit, 0 when inside it.
  int overBreakMin(Iterable<({DateTime start, DateTime? end})> breaks, {required String businessDate, required DateTime dhakaMidnightUtc, required DateTime now}) {
    final counted = countedBreakMin(breaks, businessDate: businessDate, dhakaMidnightUtc: dhakaMidnightUtc, now: now);
    return counted > maxBreakMin ? counted - maxBreakMin : 0;
  }
}

/// How far from the customer's pin counts as "far" (`collections.geofenceM`;
/// the server flags a collection `far_from_pin` with the same number).
int geofenceRadiusOf(Map<String, dynamic> settings) {
  final v = settings['collections.geofenceM'] ?? settings['geofenceRadiusM'];
  return v is num && v > 0 ? v.toInt() : 150;
}

/// At 100 % of the cash limit the app refuses more cash (`cash.limitMode` =
/// `block`) or only warns (`warn`, the default).
bool cashBlocksOverLimit(Map<String, dynamic> settings) => settings['cash.limitMode'] == 'block' || settings['cashBlockOverLimit'] == true;

/// From how many late days of a month one absent day is counted
/// (`attendance.lateDaysPerAbsent`, 0 = the rule is off).
int lateDaysPerAbsentOf(Map<String, dynamic> settings) {
  final v = settings['attendance.lateDaysPerAbsent'];
  return v is num && v >= 0 ? v.toInt() : 2;
}

/// Absent days that [lateDays] of one month count as (field-api FR-ATT-012).
int lateAbsencesOf(int lateDays, int perAbsent) => perAbsent > 0 && lateDays > 0 ? lateDays ~/ perAbsent : 0;
