/// Attendance rules (pure). Events: work_in, break_start, break_end, work_out.
library;

enum AttendanceEventType { workIn, breakStart, breakEnd, workOut }

extension AttendanceEventTypeX on AttendanceEventType {
  String get wire => switch (this) {
        AttendanceEventType.workIn => 'work_in',
        AttendanceEventType.breakStart => 'break_start',
        AttendanceEventType.breakEnd => 'break_end',
        AttendanceEventType.workOut => 'work_out',
      };
  static AttendanceEventType fromWire(String s) => AttendanceEventType.values.firstWhere((e) => e.wire == s);
}

enum DayStatus { notStarted, onDuty, onBreak, offDuty }

class BreakSpan {
  const BreakSpan(this.start, this.end);
  final DateTime start;
  final DateTime? end;
  Duration length(DateTime now) => (end ?? now).difference(start);
}

class AttendanceDay {
  const AttendanceDay({required this.status, this.firstIn, this.lastOut, this.breaks = const [], this.lateMin = 0});
  final DayStatus status;
  final DateTime? firstIn;
  final DateTime? lastOut;
  final List<BreakSpan> breaks;
  final int lateMin;

  Duration breakTotal(DateTime now) => breaks.fold(Duration.zero, (s, b) => s + b.length(now));
  BreakSpan? get openBreak => breaks.isNotEmpty && breaks.last.end == null ? breaks.last : null;
  Duration dutyTotal(DateTime now) =>
      firstIn == null ? Duration.zero : (lastOut ?? now).difference(firstIn!) - breakTotal(lastOut ?? now);
}

class AttendanceEventIn {
  const AttendanceEventIn(this.type, this.at);
  final AttendanceEventType type;
  final DateTime at;
}

/// Allowed next events for a status.
Set<AttendanceEventType> allowedNext(DayStatus s) => switch (s) {
      DayStatus.notStarted => {AttendanceEventType.workIn},
      DayStatus.onDuty => {AttendanceEventType.breakStart, AttendanceEventType.workOut},
      DayStatus.onBreak => {AttendanceEventType.breakEnd},
      DayStatus.offDuty => {AttendanceEventType.workIn},
    };

/// Folds the day's events (ordered by time). [dutyStart] like "09:00"
/// (Dhaka), [graceMin] from settings; [dhakaMidnightUtc] = 00:00 Dhaka of
/// the business day in UTC.
AttendanceDay computeDay(List<AttendanceEventIn> events, {required DateTime dhakaMidnightUtc, String dutyStart = '09:00', int graceMin = 15}) {
  var status = DayStatus.notStarted;
  DateTime? firstIn;
  DateTime? lastOut;
  final breaks = <BreakSpan>[];
  for (final e in events) {
    if (!allowedNext(status).contains(e.type)) continue; // ignore impossible sequences
    switch (e.type) {
      case AttendanceEventType.workIn:
        firstIn ??= e.at;
        lastOut = null;
        status = DayStatus.onDuty;
      case AttendanceEventType.breakStart:
        breaks.add(BreakSpan(e.at, null));
        status = DayStatus.onBreak;
      case AttendanceEventType.breakEnd:
        final b = breaks.removeLast();
        breaks.add(BreakSpan(b.start, e.at));
        status = DayStatus.onDuty;
      case AttendanceEventType.workOut:
        lastOut = e.at;
        status = DayStatus.offDuty;
    }
  }
  var late = 0;
  if (firstIn != null) {
    final p = dutyStart.split(':').map(int.parse).toList();
    final start = dhakaMidnightUtc.add(Duration(hours: p[0], minutes: p[1]));
    final diff = firstIn.difference(start).inMinutes;
    if (diff > graceMin) late = diff;
  }
  return AttendanceDay(status: status, firstIn: firstIn, lastOut: lastOut, breaks: breaks, lateMin: late);
}
