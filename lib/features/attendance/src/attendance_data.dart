import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/location/location_engine.dart';
import '../../../core/media/media.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/settings/duty_settings.dart';
import '../../../core/sync/outbox.dart';
import '../../../core/permissions/permission_service.dart';
import '../../../core/providers.dart';
import '../../../core/sync/sync_handlers.dart';
import '../../../core/time/clock.dart';
import 'attendance_domain.dart';

/// Server's view of the day (`AttendanceDay`) replaces the local estimate.
class AttendanceDayPullHandler implements PullHandler {
  @override
  String get entity => 'attendance_day';

  @override
  Future<void> upsert(AppDatabase db, String id, Json d) async {
    DateTime? dt(Object? v) => v == null ? null : DateTime.parse(v as String).toUtc();
    await db.into(db.attendanceDays).insertOnConflictUpdate(AttendanceDaysCompanion.insert(
          businessDate: d['businessDate'] as String,
          status: (d['status'] as String?) ?? 'not_started',
          firstIn: Value(dt(d['firstIn'])),
          lastOut: Value(dt(d['lastOut'])),
          breakMin: Value((d['breakMin'] as num?)?.toInt() ?? 0),
          lateMin: Value((d['lateMin'] as num?)?.toInt() ?? 0),
          overtimeMin: Value((d['overtimeMin'] as num?)?.toInt() ?? 0),
          overBreakMin: Value((d['overBreakMin'] as num?)?.toInt() ?? 0),
        ));
  }

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) async {}
}

class AttendancePushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'attendance_event'};

  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) =>
      (db.update(db.attendanceEvents)..where((t) => t.clientId.equals(m.mutationId))).write(
        AttendanceEventsCompanion(syncState: Value(r.result == 'rejected' ? 'failed' : 'synced')),
      );
}

class InvalidAttendanceTransition implements Exception {}

class AttendanceService {
  AttendanceService(this._ref);
  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);
  Clock get _clock => _ref.read(clockProvider);

  String? _checkedServerFor;

  /// FR-M-061: a phone that lost its local data (app reinstalled, data cleared)
  /// takes today's events back from the server (contract 1.36.0), so staff are
  /// not asked to work in again. Only while the phone has no event of today;
  /// asks the server once per day per app run; inserted as already sent (no
  /// outbox entry) under the phone's own clientId. Never changes local events.
  Future<int> restoreTodayIfMissing() async {
    if (!_ref.read(attendanceRequiredProvider)) return 0; // FR-M-070: never ask a super admin's day
    final date = _clock.businessDate();
    if (_checkedServerFor == date) return 0;
    Future<bool> empty() async => (await (_db.select(_db.attendanceEvents)..where((t) => t.businessDate.equals(date))..limit(1)).get()).isEmpty;
    if (!await empty()) {
      _checkedServerFor = date;
      return 0;
    }
    final j = await _ref.read(fieldApiProvider).myAttendanceToday();
    _checkedServerFor = date;
    final rows = [
      for (final e in (j['events'] as List? ?? const []).whereType<Map<String, dynamic>>())
        if (e['type'] is String && e['at'] is String && AttendanceService._tryWire(e['type'] as String) != null) e,
    ];
    if (rows.isEmpty) return 0;
    return _db.transaction(() async {
      if (!await empty()) return 0; // staff recorded one meanwhile: the phone's own data wins
      var n = 0;
      for (final e in rows) {
        final at = DateTime.parse(e['at'] as String).toUtc();
        n += await _db.into(_db.attendanceEvents).insert(
              AttendanceEventsCompanion.insert(
                clientId: (e['clientId'] as String?) ?? 'server-${e['id']}',
                type: e['type'] as String,
                at: at,
                deviceTime: at,
                businessDate: date,
                syncState: const Value('synced'),
              ),
              mode: InsertMode.insertOrIgnore,
            ) > 0
            ? 1
            : 0;
      }
      return n;
    });
  }

  Stream<List<AttendanceEventIn>> watchToday() {
    final date = _clock.businessDate();
    return (_db.select(_db.attendanceEvents)
          ..where((t) => t.businessDate.equals(date))
          ..orderBy([(t) => OrderingTerm.asc(t.at)]))
        .watch()
        .map((rows) => [for (final r in rows) AttendanceEventIn(AttendanceEventTypeX.fromWire(r.type), r.at)]);
  }

  DateTime dhakaMidnightUtc() => parseBusinessDate(_clock.businessDate()).subtract(dhakaOffset);

  /// Events that need a front-camera photo (contract 1.8.0): master switch
  /// `attendance.selfieRequired` (default true) and the list
  /// `attendance.selfieEvents` (default work-in and work-out only: no photo at
  /// breaks, owner 2026-11-22, contract 1.36.0). Both come resolved for the user's branch.
  Set<AttendanceEventType> selfieEvents() {
    final settings = _ref.read(serverSettingsProvider);
    if (settings['attendance.selfieRequired'] == false) return const {};
    final v = settings['attendance.selfieEvents'];
    if (v is! List) return const {AttendanceEventType.workIn, AttendanceEventType.workOut};
    return {for (final w in v.whereType<String>()) ?_tryWire(w)};
  }

  static AttendanceEventType? _tryWire(String w) {
    try {
      return AttendanceEventTypeX.fromWire(w);
    } catch (_) {
      return null;
    }
  }

  bool needsSelfie(AttendanceEventType type) => selfieEvents().contains(type);

  /// Records an event offline-first (FR-ATT-001/002). The event is sent at
  /// once, never held for its [selfie] (ADR-M19, contract 1.21.0): duty and
  /// location must not wait for an upload. The photo uploads on its own and
  /// is linked afterwards (see [linkAttendanceSelfie]). Each event depends on
  /// the previous one of the day, so they always reach the server in order.
  Future<void> record(AttendanceEventType type, {GeoFix? fix, Uint8List? selfie}) async {
    if (selfie == null && needsSelfie(type)) throw SelfieRequired();
    final date = _clock.businessDate();
    final events = await (_db.select(_db.attendanceEvents)
          ..where((t) => t.businessDate.equals(date))
          ..orderBy([(t) => OrderingTerm.asc(t.at)]))
        .get();
    final day = computeDay([for (final e in events) AttendanceEventIn(AttendanceEventTypeX.fromWire(e.type), e.at)], dhakaMidnightUtc: dhakaMidnightUtc());
    if (!allowedNext(day.status).contains(type)) throw InvalidAttendanceTransition();
    final id = const Uuid().v7();
    final at = _clock.nowUtc();
    final device = _clock.deviceNowUtc();
    final previous = events.isEmpty ? null : events.last.clientId;
    await _db.transaction(() async {
      await _db.into(_db.attendanceEvents).insert(AttendanceEventsCompanion.insert(
            clientId: id,
            type: type.wire,
            at: at,
            deviceTime: device,
            businessDate: date,
            lat: Value(fix?.lat),
            lng: Value(fix?.lng),
            accuracyM: Value(fix?.accuracyM),
            mock: Value(fix?.mock ?? false),
          ));
      await _ref.read(outboxWriterProvider).enqueue(
        mutationId: id,
        entity: 'attendance_event',
        dependsOn: [?previous],
        payload: {
          'clientId': id,
          'type': type.wire,
          'at': at.toIso8601String(),
          'deviceTime': device.toIso8601String(),
          ...geoFields(fix, _ref.read(locationEngineProvider).lastFailureReason),
        },
      );
    });
    if (selfie != null) {
      final user = await _ref.read(secureStoreProvider).read('session_user');
      final code = user == null ? '' : ((jsonDecode(user) as Map)['employeeCode'] ?? '').toString();
      final f = _ref.read(fmtProvider);
      final wm = '${f.dateTime(at).replaceAll(RegExp('[^\\x00-\\x7F]'), '')} ${type.wire} $code${fix == null ? '' : ' ${fix.lat.toStringAsFixed(5)},${fix.lng.toStringAsFixed(5)}'}';
      final processed = await processPhoto(selfie, watermark: wm.trim());
      final media = _ref.read(mediaServiceProvider);
      final mediaId = await media.enqueue(photo: processed, kind: 'selfie', ownerEntity: 'attendance_event', ownerClientId: id, fix: fix);
      await (_db.update(_db.attendanceEvents)..where((t) => t.clientId.equals(id))).write(AttendanceEventsCompanion(selfieMediaClientId: Value(mediaId)));
      unawaited(media.uploadPending().catchError((Object _) {}));
    }
    unawaited(_ref.read(syncEngineProvider).kick(reason: 'attendance'));
  }
}

final attendanceServiceProvider = Provider<AttendanceService>(AttendanceService.new);

class SelfieRequired implements Exception {}

/// Media hook: the selfie is on the server → link it to its event.
///
/// An event saved by an app before 0.12.1 may still be held for its photo:
/// it is sent now with `selfieMediaId`. Otherwise the event went without the
/// photo and `attendance_selfie` links it (after the event, via `dependsOn`).
Future<void> linkAttendanceSelfie(OutboxWriter outbox, AppDatabase db, String eventClientId, List<String> mediaIds) async {
  if (mediaIds.isEmpty) return;
  if (await outbox.release(eventClientId, {'selfieMediaId': mediaIds.first})) return;
  final already = await (db.select(db.outbox)
        ..where((t) => t.entity.equals('attendance_selfie') & t.payloadJson.like('%"eventClientId":"$eventClientId"%')))
      .get();
  if (already.isNotEmpty) return;
  await outbox.enqueue(
    mutationId: const Uuid().v7(),
    entity: 'attendance_selfie',
    dependsOn: [eventClientId],
    payload: {'eventClientId': eventClientId, 'selfieMediaId': mediaIds.first},
  );
}

/// Sends attendance events that an app before 0.12.1 held for their photo,
/// so a phone already stuck on "waiting" recovers without losing anything.
/// Their photos are linked by [linkAttendanceSelfie] once they upload.
Future<int> releaseHeldAttendance(AppDatabase db) =>
    (db.update(db.outbox)..where((t) => t.entity.equals('attendance_event') & t.state.equals('held')))
        .write(const OutboxCompanion(state: Value('pending')));

/// Attendance is shown and asked for only when the module is on, the user may record it, and the server says
/// this user gives attendance (contract 1.45.0 `attendanceRequired`; false for a super admin, FR-M-070).
final attendanceShownProvider = Provider<bool>((ref) {
  final access = ref.watch(accessProvider);
  return access.flag('module.attendance') && access.can(Perm.attendanceRecord) && ref.watch(attendanceRequiredProvider);
});

final todayAttendanceProvider = StreamProvider<AttendanceDay>((ref) {
  final s = ref.watch(attendanceServiceProvider);
  // The branch's duty hours as the office set them (FR-M-047).
  final duty = DutySettings.of(ref.watch(serverSettingsProvider));
  return s.watchToday().map((ev) => computeDay(
        ev,
        dhakaMidnightUtc: s.dhakaMidnightUtc(),
        dutyStart: duty.start,
        graceMin: duty.lateGraceMin,
      ));
});

/// Recent attendance days from the server snapshot (most recent first, up to 60).
final recentAttendanceDaysProvider = StreamProvider<List<AttendanceDayRow>>((ref) {
  final db = ref.watch(databaseProvider);
  final today = ref.watch(clockProvider).businessDate();
  return (db.select(db.attendanceDays)
        ..where((t) => t.businessDate.isSmallerOrEqualValue(today))
        ..orderBy([(t) => OrderingTerm.desc(t.businessDate)])
        ..limit(60))
      .watch();
});

/// Ticks every 30 s so durations on screen stay fresh.
final minuteTickerProvider = StreamProvider<DateTime>((ref) async* {
  final clock = ref.watch(clockProvider);
  yield clock.nowUtc();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => clock.nowUtc());
});
