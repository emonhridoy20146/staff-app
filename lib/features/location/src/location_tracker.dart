import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:material_ui/material_ui.dart' show Locale;

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/location/location_engine.dart';
import '../../../core/location/tracking/filters.dart';
import '../../../core/location/tracking/free_tracking_provider.dart';
import '../../../core/location/tracking/paid_tracking_provider.dart';
import '../../../core/location/tracking/sampling.dart';
import '../../../core/location/tracking/tracking_provider.dart';
import '../../../core/permissions/permission_service.dart';
import '../../../core/providers.dart';
import '../../../core/time/clock.dart';
import '../../../l10n/app_localizations.dart';
import '../../attendance/attendance.dart';
import '../../customers/customers.dart';

/// Max points kept on the phone (04-architecture §5.5).
const locationQueueCap = 20000;

/// Upload when this many points are waiting, or every [uploadEvery].
const uploadBatchTrigger = 100;
const uploadEvery = Duration(minutes: 2);
const heartbeatEvery = Duration(minutes: 5);

/// A standing phone may report nothing (distance filter) or only rough
/// fixes; with no point for this long a one-off fix is taken, so the live
/// map gets a position every few minutes on duty (ADR-M20).
const pointAtLeastEvery = Duration(minutes: 2);

/// Tracking keeps running at most this long after the shift end (then it
/// stops even if the staff forgot to end work).
const afterShiftGrace = Duration(hours: 3);

/// Visit suggestion: stay ≥ 5 min within 60 m of a customer pin.
const dwellForSuggestion = Duration(minutes: 5);
const dwellRadiusM = 60;

/// All providers compiled into this build. Tests override this.
final trackingProvidersProvider = Provider<List<TrackingProvider>>((ref) => [FreeTrackingProvider(), PaidTrackingProvider()]);

class TrackingStatus {
  const TrackingStatus({this.running = false, this.providerId, this.fellBack = false, this.lastPointAt, this.dropped = 0});
  final bool running;

  /// `free` | `paid` — the one actually running.
  final String? providerId;

  /// Admin chose `paid` but this build does not include it.
  final bool fellBack;
  final DateTime? lastPointAt;
  final int dropped;

  TrackingStatus copyWith({bool? running, String? providerId, bool? fellBack, DateTime? lastPointAt, int? dropped}) => TrackingStatus(
        running: running ?? this.running,
        providerId: providerId ?? this.providerId,
        fellBack: fellBack ?? this.fellBack,
        lastPointAt: lastPointAt ?? this.lastPointAt,
        dropped: dropped ?? this.dropped,
      );
}

final trackingStatusProvider = StateProvider<TrackingStatus>((ref) => const TrackingStatus());

class VisitSuggestion {
  const VisitSuggestion({required this.customerId, required this.customerName, required this.dwell});
  final String customerId;
  final String customerName;
  final Duration dwell;
}

final visitSuggestionProvider = StateProvider<VisitSuggestion?>((ref) => null);

/// Duty-aware tracking (FR-M-011, FR-LOC-*): runs only while the staff is
/// on duty (work-in → work-out, breaks included) and within the shift end
/// + 3 h; never off duty, for any feature (CLAUDE.md §2.6).
class LocationTracker {
  LocationTracker(this._ref);
  final Ref _ref;

  TrackingProvider? _provider;
  StreamSubscription<RawLocation>? _sub;
  Timer? _uploadTimer;
  Timer? _heartbeatTimer;
  RawLocation? _prev;
  SamplingProfile? _profile;
  bool _uploading = false;
  bool _wantRunning = false;

  // Dwell detection for visit suggestions.
  RawLocation? _anchor;
  final _dismissed = <String>{};

  AppDatabase get _db => _ref.read(databaseProvider);
  Clock get _clock => _ref.read(clockProvider);
  Map<String, dynamic> get _settings => _ref.read(serverSettingsProvider);

  SamplingConfig get _config => SamplingConfig.fromJson(_settings['location.sampling'] as Map<String, dynamic>?);

  bool get isRunning => _provider?.isRunning ?? false;

  /// Evaluates duty, flag and setting; starts / stops / switches provider.
  Future<void> reconcile({required bool onDuty}) async {
    final allowed = onDuty && _ref.read(accessProvider).flag('module.location') && _withinShift();
    _wantRunning = allowed;
    if (!allowed) return stop();
    final choice = selectTrackingProvider(_settings['location.trackingProvider'] as String?, _ref.read(trackingProvidersProvider));
    if (_provider != null && _provider!.id != choice.provider.id) await stop();
    if (_provider == null || !_provider!.isRunning) await _start(choice.provider, fellBack: choice.fellBack);
  }

  bool _withinShift() {
    final end = (_settings['dutyEnd'] as String?) ?? '18:00';
    final p = end.split(':').map(int.parse).toList();
    final endUtc = parseBusinessDate(_clock.businessDate()).subtract(dhakaOffset).add(Duration(hours: p[0], minutes: p[1]));
    return !_clock.nowUtc().isAfter(endUtc.add(afterShiftGrace));
  }

  Future<void> _start(TrackingProvider provider, {required bool fellBack}) async {
    final l = lookupAppLocalizations(Locale(_ref.read(languageCodeProvider)));
    _provider = provider;
    _profile = profileFor(Activity.unknown, _config);
    _sub = provider.points.listen((p) => unawaited(handle(p)));
    try {
      await provider.start(_profile!, notificationTitle: l.trackingNotificationTitle, notificationText: l.trackingNotificationText);
    } catch (_) {
      await _sub?.cancel();
      _sub = null;
      _provider = null;
      return;
    }
    _uploadTimer = Timer.periodic(uploadEvery, (_) => unawaited(_everyFewMinutes()));
    _heartbeatTimer = Timer.periodic(heartbeatEvery, (_) => unawaited(_tick()));
    _ref.read(trackingStatusProvider.notifier).state = TrackingStatus(running: true, providerId: provider.id, fellBack: fellBack);
    unawaited(sendHeartbeat());
    // First position right away, so the office sees the staff member within seconds of the work-in.
    unawaited(_everyFewMinutes());
  }

  /// Takes a one-off fix when the stream has been quiet, then uploads.
  Future<void> ensureRecentPoint() async {
    if (!_wantRunning || !isRunning) return;
    final last = _ref.read(trackingStatusProvider).lastPointAt;
    if (last != null && _clock.nowUtc().difference(last) < pointAtLeastEvery) return;
    final fix = await _ref.read(locationEngineProvider).currentFix();
    if (fix == null) return;
    await handle(RawLocation(t: fix.fixAt.toUtc(), lat: fix.lat, lng: fix.lng, acc: fix.accuracyM, mock: fix.mock));
  }

  Future<void> _everyFewMinutes() async {
    try {
      await ensureRecentPoint();
    } catch (_) {}
    await uploadPending();
  }

  Future<void> stop() async {
    _uploadTimer?.cancel();
    _heartbeatTimer?.cancel();
    _uploadTimer = null;
    _heartbeatTimer = null;
    await _sub?.cancel();
    _sub = null;
    final p = _provider;
    _provider = null;
    _prev = null;
    _anchor = null;
    if (p != null && p.isRunning) await p.stop();
    final s = _ref.read(trackingStatusProvider);
    if (s.running) {
      _ref.read(trackingStatusProvider.notifier).state = TrackingStatus(providerId: s.providerId, fellBack: s.fellBack, lastPointAt: s.lastPointAt);
      // Flush what is left (best effort).
      unawaited(uploadPending());
    }
  }

  Future<void> _tick() async {
    if (_wantRunning && !_withinShift()) {
      _wantRunning = false;
      await stop();
      return;
    }
    await sendHeartbeat();
  }

  /// One point from the provider → guard, filter, queue, adapt sampling.
  Future<void> handle(RawLocation p) async {
    if (!_wantRunning || !isRunning) return; // never store off-duty points
    final drop = checkPoint(p, _prev, now: _clock.nowUtc());
    if (drop != null) {
      final s = _ref.read(trackingStatusProvider);
      _ref.read(trackingStatusProvider.notifier).state = s.copyWith(dropped: s.dropped + 1);
      return;
    }
    final rough = p.acc > _config.maxAccuracyM;
    final speed = p.spd ?? (_prev == null || rough ? null : _speedBetween(_prev!, p));
    final act = activityFromSpeed(speed);
    // A rough fix is sent (live map) but never becomes the reference for speed or dwell.
    final firstPoint = _ref.read(trackingStatusProvider).lastPointAt == null;
    if (!rough) _prev = p;
    await _db.into(_db.locationQueue).insert(LocationQueueCompanion.insert(
          t: p.t,
          lat: p.lat,
          lng: p.lng,
          acc: p.acc,
          spd: Value(speed),
          hdg: Value(p.hdg),
          alt: Value(p.alt),
          act: Value(act.wire),
          mock: Value(p.mock),
        ));
    await _enforceCap();
    _ref.read(trackingStatusProvider.notifier).state = _ref.read(trackingStatusProvider).copyWith(lastPointAt: p.t);

    final next = profileFor(act, _config);
    if (next != _profile) {
      _profile = next;
      await _provider?.updateProfile(next);
    }
    if (!rough) await _checkDwell(p);
    if (firstPoint || await pendingCount() >= uploadBatchTrigger) unawaited(uploadPending());
  }

  double _speedBetween(RawLocation a, RawLocation b) {
    final dt = b.t.difference(a.t).inMilliseconds / 1000;
    return dt <= 0 ? 0 : distanceMeters(a.lat, a.lng, b.lat, b.lng) / dt;
  }

  /// Keeps at most [locationQueueCap] points: drops the oldest *stationary*
  /// points first, then the oldest of any kind.
  Future<void> _enforceCap() async {
    final over = await pendingCount() - locationQueueCap;
    if (over <= 0) return;
    await _db.customStatement(
      "DELETE FROM location_queue WHERE id IN (SELECT id FROM location_queue WHERE act = 'still' ORDER BY id LIMIT ?)",
      [over],
    );
    final still = await pendingCount() - locationQueueCap;
    if (still > 0) {
      await _db.customStatement('DELETE FROM location_queue WHERE id IN (SELECT id FROM location_queue ORDER BY id LIMIT ?)', [still]);
    }
  }

  Future<int> pendingCount() async {
    final c = _db.locationQueue.id.count();
    return (await (_db.selectOnly(_db.locationQueue)..addColumns([c])).map((r) => r.read(c) ?? 0).getSingle());
  }

  /// Sends queued points in batches of 500 (oldest first). Rows are deleted
  /// only after the server confirmed them.
  ///
  /// The server keeps only points taken on duty, and it learns that duty
  /// started from the work-in (FR-LOC-001). Points sent before the work-in
  /// reaches it are refused as `OFF_DUTY` and would be lost, so they wait on
  /// the phone while an attendance event is still unsent (e.g. its photo is
  /// still uploading). [locationBackgroundProvider] sends them once it is in.
  Future<void> uploadPending() async {
    if (_uploading) return;
    if (await _ref.read(outboxReaderProvider).hasUnsentOf('attendance_event')) return;
    _uploading = true;
    try {
      final api = _ref.read(fieldApiProvider);
      final deviceId = _ref.read(deviceIdentityProvider).deviceId;
      while (true) {
        final rows = await (_db.select(_db.locationQueue)..orderBy([(t) => OrderingTerm.asc(t.id)])..limit(500)).get();
        if (rows.isEmpty) break;
        final r = await api.ingestPoints(deviceId: deviceId, points: [for (final x in rows) pointJson(x)]);
        await (_db.delete(_db.locationQueue)..where((t) => t.id.isSmallerOrEqualValue(rows.last.id))).go();
        if (r.nextSampling != null) {
          _ref.read(serverSettingsProvider.notifier).state = {..._settings, 'location.sampling': r.nextSampling};
        }
        if (rows.length < 500) break;
      }
    } catch (_) {
      // Offline or server error: points stay queued for the next try.
    } finally {
      _uploading = false;
    }
  }

  Future<void> sendHeartbeat() async {
    try {
      final h = await (_provider ?? _ref.read(trackingProvidersProvider).first).health();
      final s = _ref.read(trackingStatusProvider);
      await _ref.read(fieldApiProvider).heartbeat({
        'gpsEnabled': h.gpsEnabled,
        'permission': h.permission,
        'appVersion': _ref.read(deviceIdentityProvider).appVersion,
        'pendingPoints': await pendingCount(),
        'pendingMutations': await _ref.read(outboxReaderProvider).unsyncedCount(),
        // Declared in contract 1.5.0.
        'trackingProvider': s.providerId,
        'trackingProviderFallback': s.fellBack,
      });
    } catch (_) {}
  }

  Future<void> _checkDwell(RawLocation p) async {
    final a = _anchor;
    if (a == null || distanceMeters(a.lat, a.lng, p.lat, p.lng) > dwellRadiusM) {
      _anchor = p;
      return;
    }
    final dwell = p.t.difference(a.t);
    if (dwell < dwellForSuggestion || _ref.read(visitSuggestionProvider) != null) return;
    final customers = await _ref.read(customerRepositoryProvider).watchAll().first;
    Customer? best;
    var bestD = dwellRadiusM + 1;
    for (final c in customers) {
      if (!c.hasPin || _dismissed.contains(c.id)) continue;
      final d = distanceMeters(c.row.lat!, c.row.lng!, p.lat, p.lng);
      if (d < bestD) {
        best = c;
        bestD = d;
      }
    }
    if (best == null) return;
    final since = parseBusinessDate(_clock.businessDate()).subtract(dhakaOffset);
    final visited = await (_db.select(_db.visits)..where((t) => t.customerId.equals(best!.id) & t.checkInAt.isBiggerOrEqualValue(since))).get();
    if (visited.isNotEmpty) return;
    _ref.read(visitSuggestionProvider.notifier).state = VisitSuggestion(customerId: best.id, customerName: best.row.nameBn, dwell: dwell);
  }

  void dismissSuggestion() {
    final s = _ref.read(visitSuggestionProvider);
    if (s != null) _dismissed.add(s.customerId);
    _ref.read(visitSuggestionProvider.notifier).state = null;
  }

  /// Container teardown: release the provider and timers without touching
  /// [Ref] (it is already disposed). Queued points stay on the phone.
  Future<void> dispose() async {
    _wantRunning = false;
    _uploadTimer?.cancel();
    _heartbeatTimer?.cancel();
    await _sub?.cancel();
    _sub = null;
    final p = _provider;
    _provider = null;
    if (p != null && p.isRunning) await p.stop();
  }
}

/// `LocationPoint` wire shape.
Json pointJson(LocationPointRow r) => {
      't': r.t.toUtc().toIso8601String(),
      'lat': r.lat,
      'lng': r.lng,
      'acc': r.acc,
      'spd': ?r.spd,
      'hdg': ?r.hdg,
      'alt': ?r.alt,
      'act': ?r.act,
      'mock': r.mock,
    };

final locationTrackerProvider = Provider<LocationTracker>((ref) {
  final t = LocationTracker(ref);
  ref.onDispose(() => unawaited(t.dispose()));
  return t;
});

/// Background wiring: re-evaluate whenever duty status, flags or settings
/// change. Watched by the app root.
final locationBackgroundProvider = Provider<void>((ref) {
  final tracker = ref.watch(locationTrackerProvider);
  bool onDuty() {
    final s = ref.read(todayAttendanceProvider).value?.status;
    return s == DayStatus.onDuty || s == DayStatus.onBreak;
  }

  void go() => unawaited(tracker.reconcile(onDuty: onDuty()));
  ref.listen(todayAttendanceProvider, (_, _) => go());
  // Points held back while attendance was unsent go out as soon as it is in.
  ref.listen(_unsentAttendanceProvider, (prev, next) {
    if ((prev?.value ?? 0) > 0 && next.value == 0) unawaited(tracker.uploadPending());
  });
  ref.listen(serverSettingsProvider, (_, _) => go());
  ref.listen(accessProvider, (_, _) => go());
  go();
});

final _unsentAttendanceProvider = StreamProvider<int>((ref) => ref.watch(outboxReaderProvider).watchUnsentOf('attendance_event'));

/// Live count of points waiting for upload (Me tab card).
final pendingPointsProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final c = db.locationQueue.id.count();
  return (db.selectOnly(db.locationQueue)..addColumns([c])).map((r) => r.read(c) ?? 0).watchSingle();
});
