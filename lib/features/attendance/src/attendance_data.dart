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
import '../../../core/sync/outbox.dart';
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
  /// `attendance.selfieEvents` (default all four, as the owner asked on
  /// 2026-11-16; amends OD-12). Both come resolved for the user's branch.
  Set<AttendanceEventType> selfieEvents() {
    final settings = _ref.read(serverSettingsProvider);
    if (settings['attendance.selfieRequired'] == false) return const {};
    final v = settings['attendance.selfieEvents'];
    if (v is! List) return AttendanceEventType.values.toSet();
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

  /// Records an event offline-first (FR-ATT-001/002). With a [selfie] the
  /// mutation is held until the photo is uploaded, then sent with
  /// `selfieMediaId` (see [releaseWithSelfie]). Each event depends on the
  /// previous one of the day, so they always reach the server in order.
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
        held: selfie != null,
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

/// Media hook: the selfie is on the server → send the held event.
Future<void> releaseWithSelfie(OutboxWriter outbox, AppDatabase db, String eventClientId, List<String> mediaIds) =>
    outbox.release(eventClientId, {if (mediaIds.isNotEmpty) 'selfieMediaId': mediaIds.first});

final todayAttendanceProvider = StreamProvider<AttendanceDay>((ref) {
  final s = ref.watch(attendanceServiceProvider);
  final settings = ref.watch(serverSettingsProvider);
  return s.watchToday().map((ev) => computeDay(
        ev,
        dhakaMidnightUtc: s.dhakaMidnightUtc(),
        dutyStart: (settings['dutyStart'] as String?) ?? '09:00',
        graceMin: (settings['lateGraceMin'] as num?)?.toInt() ?? 15,
      ));
});

/// Ticks every 30 s so durations on screen stay fresh.
final minuteTickerProvider = StreamProvider<DateTime>((ref) async* {
  final clock = ref.watch(clockProvider);
  yield clock.nowUtc();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => clock.nowUtc());
});
