import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/attendance/attendance.dart';
import 'package:staff_app/features/cowork/src/cowork_data.dart';
import 'package:staff_app/features/cowork/src/cowork_domain.dart';
import 'package:staff_app/features/customers/customers.dart';
import 'package:staff_app/features/visits/src/visits.dart';

import 'helpers.dart';

void main() {
  late Harness h;
  setUp(() {
    h = Harness();
    h.api.selfieRequired = false; // attendance photos have their own tests
  });
  tearDown(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await h.dispose();
  });

  const me = 'u-fs-014';
  String today() => h.clock.businessDate();

  Future<List<CoworkSession>> sessions() async {
    final db = h.read(databaseProvider);
    return [for (final r in await db.select(db.coworkSessions).get()) CoworkSession.fromRow(r)];
  }

  Future<CoworkToday> mine() async => coworkToday(await sessions(), me: me, businessDate: today());

  Future<void> sync() => h.read(syncEngineProvider).syncNow();

  test('an invitation arrives on pull; answering needs the network; a joint visit is saved offline and sent with the session', () async {
    await h.signIn();
    await h.read(attendanceServiceProvider).record(AttendanceEventType.workIn);
    final sid = h.api.coworkInviteFrom('u-fs-020', note: 'নথুল্লাবাদ এলাকা');
    await sync();

    var t = await mine();
    expect(t.invites, hasLength(1));
    expect(t.active, isNull);
    final invite = t.invites.single;
    expect(invite.nameOf(invite.memberOf(me)!.invitedBy!), 'সজীব আহমেদ');

    // Offline: the answer is not queued (online-only), the invitation stays.
    final svc = h.read(coworkServiceProvider);
    h.api.offline = true;
    expect((await svc.respond(sid, accept: true)).error, CoworkError.offline);
    expect((await mine()).invites, hasLength(1));

    h.api.offline = false;
    expect((await svc.respond(sid, accept: true)).ok, isTrue);
    t = await mine();
    expect(t.invites, isEmpty);
    expect(t.active!.partnersOf(me).map((m) => m.userId), ['u-fs-020']);
    expect(coworkForVisit(t, me: me, onDuty: true)?.id, sid);
    expect(coworkForVisit(t, me: me, onDuty: false), isNull, reason: 'work-out ends co-work');

    // Joint visit with no network: saved and queued with the session id.
    final customer = (await h.read(customerRepositoryProvider).watchAll().first).first;
    h.api.offline = true;
    final vid = await h.read(visitServiceProvider).record(customer: customer, outcome: 'not_home', fix: null, cowork: t.active);
    final db = h.read(databaseProvider);
    final ob = await (db.select(db.outbox)..where((o) => o.mutationId.equals(vid))).getSingle();
    expect((jsonDecode(ob.payloadJson) as Map)['coWorkSessionId'], sid);
    var rows = await db.select(db.visits).get();
    expect(splitVisits(rows, me: me), (solo: 0, coWork: 1));

    await Future<void>.delayed(const Duration(milliseconds: 50));
    h.api.offline = false;
    await sync();
    await sync();
    expect(h.api.appliedPayloads[vid]!['coWorkSessionId'], sid);
    rows = await db.select(db.visits).get();
    final v = rows.singleWhere((r) => r.clientId == vid);
    expect(v.coWorkSessionId, sid);
    expect(jsonDecode(v.coWorkParticipantIdsJson!), ['u-fs-020'], reason: "server's participants replace our estimate");
  });

  test('asking colleagues: list, one session per send even on retry, member limit, partner accepts', () async {
    await h.signIn();
    final svc = h.read(coworkServiceProvider);
    final (list, err) = await svc.colleagues();
    expect(err, isNull);
    expect(list!.map((c) => c.id), ['u-fs-020', 'u-fs-021', 'u-fs-022', 'u-fs-023']);
    expect(list.last.onDutyToday, isFalse);

    final key = svc.newRequestId();
    expect((await svc.request(clientId: key, toUserIds: ['u-fs-020', 'u-fs-021'], note: ' ')).ok, isTrue);
    expect((await svc.request(clientId: key, toUserIds: ['u-fs-020', 'u-fs-021'])).ok, isTrue, reason: 'replay');
    final all = await sessions();
    expect(all, hasLength(1));
    final s = all.single;
    expect(s.note, isNull, reason: 'blank note is not sent');
    expect(s.waitingOn(me).map((m) => m.userId), ['u-fs-020', 'u-fs-021']);
    expect(coworkForVisit(await mine(), me: me, onDuty: true), isNull, reason: 'nobody has accepted yet');
    expect(coworkSeatsLeft(s, 5), 2);

    h.api.coworkMaxMembers = 3;
    expect((await svc.request(clientId: svc.newRequestId(), toUserIds: ['u-fs-022'])).error, CoworkError.tooMany);

    h.api.coworkMemberSets(s.id, 'u-fs-020', 'accepted');
    await sync();
    final t = await mine();
    expect(t.active!.partnersOf(me).map((m) => m.name), ['সজীব আহমেদ']);
    expect(t.active!.waitingOn(me).map((m) => m.userId), ['u-fs-021']);
  });

  test("a partner's joint visit counts for me; others' visits on my customers do not; leaving ends a group of two", () async {
    await h.signIn();
    final sid = h.api.coworkInviteFrom('u-fs-020');
    await sync();
    await h.read(coworkServiceProvider).respond(sid, accept: true);

    h.api.coworkPartnerVisit(sid, 'u-fs-020', 'c-1001');
    h.api.serverChange('visit', 'v-other', {
      'id': 'v-other',
      'clientId': 'client-v-other',
      'userId': 'u-fs-030',
      'customerId': 'c-1002',
      'checkInAt': h.clock.nowUtc().toIso8601String(),
      'outcome': 'refused',
      'coWork': null,
    });
    await sync();
    final db = h.read(databaseProvider);
    expect(splitVisits(await db.select(db.visits).get(), me: me), (solo: 0, coWork: 1));

    expect((await h.read(coworkServiceProvider).leave(sid)).ok, isTrue);
    final s = (await sessions()).single;
    expect(s.open, isFalse, reason: 'fewer than two accepted and nobody invited');
    expect((await mine()).active, isNull);
  });

  test('work-out leaves the group (server side), and the phone learns it on pull', () async {
    await h.signIn();
    final att = h.read(attendanceServiceProvider);
    await att.record(AttendanceEventType.workIn);
    final sid = h.api.coworkInviteFrom('u-fs-020');
    h.api.coworkInviteFrom('u-fs-020'); // same group, no duplicate
    await sync();
    await h.read(coworkServiceProvider).respond(sid, accept: true);
    h.clock.advance(const Duration(hours: 8));
    await att.record(AttendanceEventType.workOut);
    await sync();
    await sync();
    final s = (await sessions()).single;
    expect(s.memberOf(me)!.status, CoworkMemberStatus.left);
    expect((await mine()).active, isNull);
  });

  test('accepting a second group while in one is refused with a clear reason', () async {
    await h.signIn();
    final svc = h.read(coworkServiceProvider);
    final a = h.api.coworkInviteFrom('u-fs-020');
    final b = h.api.coworkInviteFrom('u-fs-021');
    expect(a, isNot(b));
    await sync();
    expect((await svc.respond(a, accept: true)).ok, isTrue);
    expect((await svc.respond(b, accept: true)).error, CoworkError.alreadyInSession);
    final t = await mine();
    expect(t.active!.id, a);
    expect(t.invites.single.id, b);
  });

  test('seats left counts me and everyone still invited', () {
    expect(coworkSeatsLeft(null, 5), 4);
    expect(coworkSeatsLeft(null, 1), 0);
  });

  test('the person who asked can cancel before anyone accepts: the request is withdrawn for everyone', () async {
    await h.signIn();
    await h.read(attendanceServiceProvider).record(AttendanceEventType.workIn);
    final svc = h.read(coworkServiceProvider);
    expect((await svc.request(clientId: svc.newRequestId(), toUserIds: ['u-fs-020'])).ok, isTrue);
    final s = (await mine()).active!;
    expect(s.leavingCancels(me), isTrue, reason: 'nobody accepted yet');
    expect(s.leavingEnds(me), isFalse);

    expect((await svc.leave(s.id)).ok, isTrue);
    final after = (await sessions()).single;
    expect(after.open, isFalse, reason: 'no accepted member is left, the invitation does not stay open');
    expect((await mine()).active, isNull);
  });

  test('with one partner the group ends when I leave; with an invitation still open it would not', () async {
    await h.signIn();
    await h.read(attendanceServiceProvider).record(AttendanceEventType.workIn);
    final sid = h.api.coworkInviteFrom('u-fs-020');
    await sync();
    final svc = h.read(coworkServiceProvider);
    expect((await svc.respond(sid, accept: true)).ok, isTrue);
    final s = (await mine()).active!;
    expect(s.leavingCancels(me), isFalse, reason: 'someone is working with me');
    expect(s.leavingEnds(me), isTrue);
    expect((await svc.leave(sid)).ok, isTrue);
    expect((await sessions()).single.open, isFalse);
  });
}
