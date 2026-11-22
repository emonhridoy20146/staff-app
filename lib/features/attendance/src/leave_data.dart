import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_models.dart';
import '../../../core/api/field_api.dart';
import '../../../core/providers.dart';
import '../../../core/time/clock.dart';

/// Leave requests, holidays and my shift (master FR-ATT-008, FR-SET-002/003,
/// FR-M-028, contract 1.12.0).
///
/// Asking for leave is online (ADR-M08 exception): the server checks it
/// against my other requests and tells my manager at once, and a queued
/// request could be approved for days already passed. What the phone last
/// heard is cached so the screens still open without a network.

enum LeaveType { casual, sick, other }

enum LeaveStatus { pending, approved, rejected, cancelled }

LeaveStatus _status(Object? v) => LeaveStatus.values.firstWhere((s) => s.name == v, orElse: () => LeaveStatus.pending);

class LeaveRequest {
  const LeaveRequest({required this.id, required this.type, required this.from, required this.to, required this.status, required this.createdAt, this.reason = '', this.decisionReason, this.decidedAt});

  factory LeaveRequest.fromJson(Json j) => LeaveRequest(
        id: j['id'] as String,
        type: LeaveType.values.firstWhere((t) => t.name == j['type'], orElse: () => LeaveType.other),
        from: j['from'] as String,
        to: j['to'] as String,
        status: _status(j['status']),
        reason: (j['reason'] as String?) ?? '',
        decisionReason: j['decisionReason'] as String?,
        decidedAt: j['decidedAt'] == null ? null : DateTime.parse(j['decidedAt'] as String).toUtc(),
        createdAt: DateTime.parse(j['createdAt'] as String).toUtc(),
      );

  final String id;
  final LeaveType type;
  final String from;
  final String to;
  final LeaveStatus status;
  final String reason;
  final String? decisionReason;
  final DateTime? decidedAt;
  final DateTime createdAt;

  int get days => leaveDays(from, to);

  /// Only a request nobody has decided can be withdrawn by its owner.
  bool get cancellable => status == LeaveStatus.pending;

  /// Pending or approved requests block the same days (server rule LEAVE_OVERLAPS).
  bool get blocksDays => status == LeaveStatus.pending || status == LeaveStatus.approved;
}

class Holiday {
  const Holiday({required this.date, required this.name, required this.national});
  factory Holiday.fromJson(Json j) =>
      Holiday(date: j['date'] as String, name: I18nText.fromJson(j['name']), national: ((j['branchIds'] as List?) ?? const []).isEmpty);
  final String date;
  final I18nText name;
  final bool national;
}

class MyShift {
  const MyShift({required this.name, required this.start, required this.end, required this.weeklyOff, this.isDefault = false, this.lateGraceMin = 15, this.maxBreakMin = 60});
  factory MyShift.fromJson(Json j) => MyShift(
        name: (j['name'] as String?) ?? '',
        start: (j['start'] as String?) ?? '09:00',
        end: (j['end'] as String?) ?? '21:00',
        weeklyOff: [for (final d in (j['weeklyOff'] as List?) ?? const [5]) (d as num).toInt()],
        isDefault: j['id'] == 'default',
        lateGraceMin: ((j['lateGraceMin'] as num?) ?? 15).toInt(),
        maxBreakMin: ((j['maxBreakMin'] as num?) ?? 60).toInt(),
      );
  final String name;
  final String start;
  final String end;

  /// 0 = Sunday … 6 = Saturday (server convention).
  final List<int> weeklyOff;
  final bool isDefault;
  final int lateGraceMin;
  final int maxBreakMin;
}

/// Calendar days from..to, both included (0 if to is before from).
int leaveDays(String from, String to) {
  final a = parseBusinessDate(from), b = parseBusinessDate(to);
  return b.isBefore(a) ? 0 : b.difference(a).inDays + 1;
}

/// Server rule: at most 31 days in one request.
const maxLeaveDays = 31;

enum LeaveFormError { toBeforeFrom, tooLong, overlaps }

/// Checks the form before sending, with the requests the phone knows about.
LeaveFormError? checkLeaveForm({required String from, required String to, required List<LeaveRequest> mine}) {
  final n = leaveDays(from, to);
  if (n == 0) return LeaveFormError.toBeforeFrom;
  if (n > maxLeaveDays) return LeaveFormError.tooLong;
  if (mine.any((r) => r.blocksDays && r.from.compareTo(to) <= 0 && r.to.compareTo(from) >= 0)) return LeaveFormError.overlaps;
  return null;
}

/// `YYYY-MM-DD` of a date-only value.
String ymdOf(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// A business date [n] days later (or earlier when negative).
String addDaysYmd(String ymd, int n) => ymdOf(parseBusinessDate(ymd).add(Duration(days: n)));

/// Server weekday (0 = Sunday) of a business date.
int weekdayOf(String ymd) => parseBusinessDate(ymd).weekday % 7;

enum LeaveError { offline, overlaps, tooLong, alreadyDecided, failed }

LeaveError leaveErrorOf(ApiException e) {
  if (e.isNetwork) return LeaveError.offline;
  final reason = e.problem?.details?['reason'] ?? e.problem?.details?['rule'];
  return switch (reason) {
    'LEAVE_OVERLAPS' => LeaveError.overlaps,
    'LEAVE_TOO_LONG' => LeaveError.tooLong,
    'ALREADY_DECIDED' => LeaveError.alreadyDecided,
    _ => LeaveError.failed,
  };
}

/// A cached answer with the time the phone got it.
class Cached<T> {
  const Cached(this.value, {this.fetchedAt, this.error});
  final T value;

  /// Set when [value] came from the phone's cache.
  final DateTime? fetchedAt;
  final LeaveError? error;
}

class LeaveService {
  LeaveService(this._ref);
  final Ref _ref;

  static const _mineKey = 'leave_mine';
  static String _holidaysKey(int year) => 'holidays_$year';
  static const _shiftKey = 'my_shift';

  FieldApi get _api => _ref.read(fieldApiProvider);

  Future<Cached<T>> _cachedRead<T>(String key, Future<Object> Function() fetch, T Function(Object json) parse, T empty) async {
    final db = _ref.read(databaseProvider);
    try {
      final j = await fetch();
      await db.kvSet(key, jsonEncode({'at': _ref.read(clockProvider).nowUtc().toIso8601String(), 'body': j}));
      return Cached(parse(j));
    } on ApiException catch (e) {
      final raw = await db.kvGet(key);
      if (raw == null) return Cached(empty, error: leaveErrorOf(e));
      final c = jsonDecode(raw) as Json;
      return Cached(parse(c['body'] as Object), fetchedAt: DateTime.parse(c['at'] as String), error: leaveErrorOf(e));
    }
  }

  Future<Cached<List<LeaveRequest>>> mine() => _cachedRead(
        _mineKey,
        () => _api.myLeaveRequests(),
        (j) => [for (final r in j as List) LeaveRequest.fromJson(r as Json)],
        const <LeaveRequest>[],
      );

  Future<Cached<List<Holiday>>> holidays(int year, {String? branchId}) => _cachedRead(
        _holidaysKey(year),
        () => _api.holidays(year: year, branchId: branchId),
        (j) => [for (final h in j as List) Holiday.fromJson(h as Json)],
        const <Holiday>[],
      );

  Future<Cached<MyShift?>> myShift() => _cachedRead<MyShift?>(_shiftKey, () => _api.myShift(), (j) => MyShift.fromJson(j as Json), null);

  /// Sends a request; on success the cached list is refreshed.
  Future<(LeaveRequest?, LeaveError?)> request({required LeaveType type, required String from, required String to, String? reason}) async {
    try {
      final r = LeaveRequest.fromJson(await _api.requestLeave(type: type.name, from: from, to: to, reason: (reason?.trim().isEmpty ?? true) ? null : reason!.trim()));
      await mine();
      return (r, null);
    } on ApiException catch (e) {
      return (null, leaveErrorOf(e));
    }
  }

  Future<LeaveError?> cancel(String id) async {
    try {
      await _api.cancelLeave(id);
      await mine();
      return null;
    } on ApiException catch (e) {
      return leaveErrorOf(e);
    }
  }
}

final leaveServiceProvider = Provider<LeaveService>(LeaveService.new);
