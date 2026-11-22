import 'dart:convert';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';

/// invited | accepted | rejected | left (contract 1.9.0).
enum CoworkMemberStatus { invited, accepted, rejected, left }

CoworkMemberStatus _status(String? s) => CoworkMemberStatus.values.firstWhere((v) => v.name == s, orElse: () => CoworkMemberStatus.left);

class CoworkMember {
  const CoworkMember({required this.userId, required this.name, required this.status, this.invitedBy, this.invitedAt, this.respondedAt, this.leftAt});

  factory CoworkMember.fromJson(Json j) => CoworkMember(
        userId: j['userId'] as String,
        name: I18nText.fromJson(j['name'] ?? '—').bn,
        status: _status(j['status'] as String?),
        invitedBy: j['invitedBy'] as String?,
        invitedAt: _date(j['invitedAt']),
        respondedAt: _date(j['respondedAt']),
        leftAt: _date(j['leftAt']),
      );

  final String userId;
  final String name;
  final CoworkMemberStatus status;
  final String? invitedBy;
  final DateTime? invitedAt;
  final DateTime? respondedAt;
  final DateTime? leftAt;

  bool get isAccepted => status == CoworkMemberStatus.accepted;
  bool get isInvited => status == CoworkMemberStatus.invited;

  /// Counts towards `cowork.maxMembers` (accepted + still invited).
  bool get occupies => isAccepted || isInvited;
}

DateTime? _date(Object? v) => v == null ? null : DateTime.parse(v as String).toUtc();

/// One co-work session as the app sees it (FR-CW-001/002).
class CoworkSession {
  const CoworkSession({required this.id, required this.businessDate, required this.open, required this.createdBy, required this.members, this.note});

  factory CoworkSession.fromRow(CoworkSessionRow r) => CoworkSession(
        id: r.id,
        businessDate: r.businessDate,
        open: r.status == 'open',
        createdBy: r.createdBy,
        note: r.note,
        members: [for (final m in (jsonDecode(r.membersJson) as List)) CoworkMember.fromJson((m as Map).cast<String, dynamic>())],
      );

  final String id;
  final String businessDate;
  final bool open;
  final String createdBy;
  final String? note;
  final List<CoworkMember> members;

  CoworkMember? memberOf(String userId) => members.where((m) => m.userId == userId).firstOrNull;

  /// Accepted members other than [me] — who would share a visit now.
  List<CoworkMember> partnersOf(String me) => [for (final m in members) if (m.isAccepted && m.userId != me) m];

  /// Invited, not yet answered, other than [me].
  List<CoworkMember> waitingOn(String me) => [for (final m in members) if (m.isInvited && m.userId != me) m];

  int get occupied => members.where((m) => m.occupies).length;

  /// Nobody has accepted yet and I am the only one in: leaving withdraws the
  /// request for everyone (the server ends a session with no accepted member).
  bool leavingCancels(String me) => (memberOf(me)?.isAccepted ?? false) && partnersOf(me).isEmpty;

  /// I have exactly one partner and nobody is still invited: the group ends when I leave.
  bool leavingEnds(String me) => (memberOf(me)?.isAccepted ?? false) && partnersOf(me).length == 1 && waitingOn(me).isEmpty;

  String? nameOf(String userId) => memberOf(userId)?.name;
}

/// What co-work means for me today, worked out from the local sessions.
class CoworkToday {
  const CoworkToday({this.active, this.invites = const []});

  /// The open session I accepted (at most one, FR-CW-001).
  final CoworkSession? active;

  /// Open sessions that invite me and wait for my answer, newest first.
  final List<CoworkSession> invites;

  static const none = CoworkToday();
}

CoworkToday coworkToday(List<CoworkSession> sessions, {required String? me, required String businessDate}) {
  if (me == null) return CoworkToday.none;
  final today = [for (final s in sessions) if (s.open && s.businessDate == businessDate) s];
  return CoworkToday(
    active: today.where((s) => s.memberOf(me)?.isAccepted ?? false).firstOrNull,
    invites: [for (final s in today) if (s.memberOf(me)?.isInvited ?? false) s],
  );
}

/// The session a new visit belongs to: my active session, if I have at
/// least one accepted partner and I am on duty. The server decides who
/// actually took part (accepted at check-in time).
CoworkSession? coworkForVisit(CoworkToday t, {required String? me, required bool onDuty}) {
  final s = t.active;
  if (s == null || me == null || !onDuty) return null;
  return s.partnersOf(me).isEmpty ? null : s;
}

/// How many more people I may invite (`cowork.maxMembers` counts everyone,
/// including me).
int coworkSeatsLeft(CoworkSession? active, int maxMembers) => (maxMembers - (active?.occupied ?? 1)).clamp(0, maxMembers);

/// One person I may invite (GET /cowork/colleagues).
class CoworkColleague {
  const CoworkColleague({required this.id, required this.name, required this.employeeCode, this.onDutyToday = false, this.inSession = false});

  factory CoworkColleague.fromJson(Json j) => CoworkColleague(
        id: j['id'] as String,
        name: I18nText.fromJson(j['name'] ?? '—').bn,
        employeeCode: (j['employeeCode'] as String?) ?? '',
        onDutyToday: (j['onDutyToday'] as bool?) ?? false,
        inSession: (j['inSession'] as bool?) ?? false,
      );

  final String id;
  final String name;
  final String employeeCode;
  final bool onDutyToday;
  final bool inSession;
}
