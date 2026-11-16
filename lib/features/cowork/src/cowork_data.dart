import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/api/field_api.dart';
import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/sync/sync_handlers.dart';
import '../../attendance/attendance.dart';
import '../../auth/auth.dart';
import 'cowork_domain.dart';

/// Pull entity `cowork_session` (contract 1.9.0): sent to every invited or
/// member user on each change.
class CoworkSessionPullHandler implements PullHandler {
  @override
  String get entity => 'cowork_session';
  @override
  Future<void> upsert(AppDatabase db, String id, Json d) => saveCoworkSession(db, d);
  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) => (db.delete(db.coworkSessions)..where((t) => t.id.equals(id))).go();
}

Future<void> saveCoworkSession(AppDatabase db, Json d) => db.into(db.coworkSessions).insertOnConflictUpdate(CoworkSessionsCompanion.insert(
      id: d['id'] as String,
      businessDate: d['businessDate'] as String,
      status: (d['status'] as String?) ?? 'open',
      createdBy: (d['createdBy'] as String?) ?? '',
      note: Value(d['note'] as String?),
      membersJson: jsonEncode(d['members'] ?? const []),
      createdAt: d['createdAt'] == null ? DateTime.utc(1970) : DateTime.parse(d['createdAt'] as String).toUtc(),
      endedAt: Value(d['endedAt'] == null ? null : DateTime.parse(d['endedAt'] as String).toUtc()),
    ));

final coworkSessionsProvider = StreamProvider<List<CoworkSession>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.coworkSessions)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch().map((rows) => [for (final r in rows) CoworkSession.fromRow(r)]);
});

final myUserIdProvider = Provider<String?>((ref) => ref.watch(sessionProvider.select((s) => s.user?.id)));

/// My co-work today: active session and invitations (works offline).
final coworkTodayProvider = Provider<CoworkToday>((ref) => coworkToday(
      ref.watch(coworkSessionsProvider).value ?? const [],
      me: ref.watch(myUserIdProvider),
      businessDate: ref.watch(clockProvider).businessDate(),
    ));

/// On duty or on a break (FR-CW: work-out leaves the session).
final onDutyProvider = Provider<bool>((ref) {
  final day = ref.watch(todayAttendanceProvider).value;
  return day != null && (day.status.name == 'onDuty' || day.status.name == 'onBreak');
});

/// The session a visit saved now would carry, or null for a single visit.
final coworkForVisitProvider = Provider<CoworkSession?>((ref) => coworkForVisit(
      ref.watch(coworkTodayProvider),
      me: ref.watch(myUserIdProvider),
      onDuty: ref.watch(onDutyProvider),
    ));

final coworkMaxMembersProvider = Provider<int>((ref) => ((ref.watch(serverSettingsProvider)['cowork.maxMembers'] as num?) ?? 5).toInt());

/// Outcome of an online co-work call.
enum CoworkError { offline, alreadyInSession, sessionEnded, notInvited, tooMany, invalidInvitee, failed }

class CoworkResult {
  const CoworkResult.ok() : error = null;
  const CoworkResult.fail(CoworkError this.error);
  final CoworkError? error;
  bool get ok => error == null;
}

CoworkError _map(ApiException e) {
  if (e.isNetwork) return CoworkError.offline;
  final d = e.problem?.details ?? const {};
  return switch (d['reason'] ?? d['rule']) {
    'ALREADY_IN_SESSION' => CoworkError.alreadyInSession,
    'SESSION_ENDED' => CoworkError.sessionEnded,
    'NOT_INVITED' => CoworkError.notInvited,
    'COWORK_TOO_MANY' => CoworkError.tooMany,
    'COWORK_INVALID_INVITEE' => CoworkError.invalidInvitee,
    _ => CoworkError.failed,
  };
}

/// Co-work requests and answers are online-only (ADR-M08 exception,
/// FR-CW-001): a partner must see the answer at once. The UI calls this
/// service, never the network. Every successful answer is stored locally,
/// so the rest of the day (visits) works offline.
class CoworkService {
  CoworkService(this._ref);
  final Ref _ref;

  FieldApi get _api => _ref.read(fieldApiProvider);
  AppDatabase get _db => _ref.read(databaseProvider);

  /// A new idempotency key for one invitation form. Keep it for retries of
  /// the same send; the server answers 200 with the same session.
  String newRequestId() => const Uuid().v7();

  Future<(List<CoworkColleague>?, CoworkError?)> colleagues() async {
    try {
      final list = await _api.coworkColleagues();
      return ([for (final j in list) CoworkColleague.fromJson(j)], null);
    } on ApiException catch (e) {
      return (null, _map(e));
    }
  }

  Future<CoworkResult> request({required String clientId, required List<String> toUserIds, String? note}) =>
      _guard(() => _api.requestCowork(clientId: clientId, toUserIds: toUserIds, note: note == null || note.trim().isEmpty ? null : note.trim()));

  Future<CoworkResult> respond(String sessionId, {required bool accept}) => _guard(() => _api.respondCowork(sessionId, accept: accept));

  Future<CoworkResult> leave(String sessionId) => _guard(() => _api.leaveCowork(sessionId));

  /// Today's sessions from the server (pull-to-refresh, after reinstall).
  Future<CoworkResult> refresh() async {
    try {
      for (final s in await _api.myCoworkSessions()) {
        await saveCoworkSession(_db, s);
      }
      return const CoworkResult.ok();
    } on ApiException catch (e) {
      return CoworkResult.fail(_map(e));
    }
  }

  Future<CoworkResult> _guard(Future<Json> Function() call) async {
    try {
      await saveCoworkSession(_db, await call());
      return const CoworkResult.ok();
    } on ApiException catch (e) {
      // A session that ended meanwhile: fetch the truth so the card updates.
      if (!e.isNetwork) await refresh();
      return CoworkResult.fail(_map(e));
    }
  }
}

final coworkServiceProvider = Provider<CoworkService>(CoworkService.new);
