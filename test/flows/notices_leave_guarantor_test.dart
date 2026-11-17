import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/attendance/src/leave_data.dart';
import 'package:staff_app/features/customers/src/contact_attempts.dart';
import 'package:staff_app/features/customers/src/domain/customer.dart';
import 'package:staff_app/features/notices/src/notices_data.dart';

import 'helpers.dart';

/// Contract 1.12.0: notices with "read" (FR-M-027), leave + holidays + my
/// shift (FR-M-028), guarantor call (FR-M-029).
void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await h.dispose();
  });

  group('notices', () {
    test('arrive with the pull; "read" is saved offline, sent later, and confirmed by the server', () async {
      await h.signIn();
      final db = h.read(databaseProvider);
      var rows = await db.select(db.broadcasts).get();
      expect(rows.map((r) => r.serverId), containsAll(['bc-1', 'bc-2']));
      expect(rows.firstWhere((r) => r.serverId == 'bc-1').requireAck, isTrue);

      h.api.offline = true;
      h.clock.advance(const Duration(minutes: 5));
      final tappedAt = h.clock.nowUtc();
      await h.read(noticeServiceProvider).markRead('bc-1');
      await h.read(noticeServiceProvider).markRead('bc-1'); // twice: one mutation
      rows = await db.select(db.broadcasts).get();
      final bc1 = rows.firstWhere((r) => r.serverId == 'bc-1');
      expect(bc1.ackedAt!.toUtc(), tappedAt);
      expect(bc1.ackState, 'queued');
      final queued = (await db.select(db.outbox).get()).where((o) => o.entity == 'broadcast_ack').toList();
      expect(queued, hasLength(1));
      expect(Notice(bc1).readNotSent, isTrue);

      // A pull that still says "not read" (server has not seen the tap) keeps the local tap.
      h.api.offline = false;
      h.clock.advance(const Duration(minutes: 20));
      await h.read(syncEngineProvider).syncNow();
      final after = await (db.select(db.broadcasts)..where((t) => t.serverId.equals('bc-1'))).getSingle();
      expect(after.ackState, 'synced');
      expect(after.ackedAt!.toUtc(), tappedAt, reason: 'the tap time, not the sync time');
      expect(h.api.noticeAcks['bc-1'], tappedAt.toIso8601String());
      final payload = h.api.appliedPayloads.values.singleWhere((p) => p['broadcastId'] == 'bc-1');
      expect(payload['at'], tappedAt.toIso8601String());
    });

    test('must-read notices drive the Today banner until read', () async {
      await h.signIn();
      Future<List<String>> ids(Provider<List<Notice>> p) async {
        h.container.invalidate(noticesProvider);
        await h.container.read(noticesProvider.future);
        return [for (final n in h.read(p)) n.id];
      }

      expect(await ids(mustReadNoticesProvider), ['bc-1']);
      expect(await ids(unreadNoticesProvider), hasLength(2));
      await h.read(noticeServiceProvider).markRead('bc-1');
      expect(await ids(mustReadNoticesProvider), isEmpty);
      expect(await ids(unreadNoticesProvider), ['bc-2']);
    });

    test('a new notice from the office reaches the phone on the next sync', () async {
      await h.signIn();
      h.api.addNotice('bc-9', title: {'bn': 'জরুরি', 'en': 'Urgent'}, body: {'bn': 'আজ ৪টায় অফিসে আসুন', 'en': 'Come to the office at 4'}, requireAck: true);
      await h.read(syncEngineProvider).syncNow();
      final db = h.read(databaseProvider);
      final r = await (db.select(db.broadcasts)..where((t) => t.serverId.equals('bc-9'))).getSingle();
      expect(Notice(r).title('en'), 'Urgent');
      expect(Notice(r).mustRead, isTrue);
    });
  });

  group('leave, holidays, my shift', () {
    test('ask, see it pending, overlap is refused, withdraw, ask again', () async {
      await h.signIn();
      final svc = h.read(leaveServiceProvider);
      final mine = await svc.mine();
      expect(mine.error, isNull);
      expect(mine.value.single.status, LeaveStatus.approved);

      final (r, err) = await svc.request(type: LeaveType.sick, from: '2026-11-18', to: '2026-11-19', reason: ' জ্বর ');
      expect(err, isNull);
      expect(r!.status, LeaveStatus.pending);
      expect(r.days, 2);
      expect(r.reason, 'জ্বর');

      final (_, overlap) = await svc.request(type: LeaveType.casual, from: '2026-11-19', to: '2026-11-19');
      expect(overlap, LeaveError.overlaps);
      // The form catches it before sending as well.
      expect(checkLeaveForm(from: '2026-11-19', to: '2026-11-20', mine: (await svc.mine()).value), LeaveFormError.overlaps);

      expect(await svc.cancel(r.id), isNull);
      final list = (await svc.mine()).value;
      expect(list.firstWhere((x) => x.id == r.id).status, LeaveStatus.cancelled);
      final (again, err2) = await svc.request(type: LeaveType.sick, from: '2026-11-19', to: '2026-11-19');
      expect(err2, isNull);
      expect(again!.days, 1);

      // A decided request cannot be withdrawn.
      h.api.decideLeave(again.id, approve: false, reason: 'সাপ্তাহিক কালেকশন ড্রাইভ');
      expect(await svc.cancel(again.id), LeaveError.alreadyDecided);
      final rejected = (await svc.mine()).value.firstWhere((x) => x.id == again.id);
      expect(rejected.status, LeaveStatus.rejected);
      expect(rejected.decisionReason, 'সাপ্তাহিক কালেকশন ড্রাইভ');
    });

    test('asking needs the network; the last list is shown offline with its time', () async {
      await h.signIn();
      final svc = h.read(leaveServiceProvider);
      await svc.mine();
      h.api.offline = true;
      final (r, err) = await svc.request(type: LeaveType.casual, from: '2026-11-20', to: '2026-11-20');
      expect(r, isNull);
      expect(err, LeaveError.offline);
      final cached = await svc.mine();
      expect(cached.error, LeaveError.offline);
      expect(cached.fetchedAt, h.clock.nowUtc());
      expect(cached.value, hasLength(1));
    });

    test('form rules: end before start, more than 31 days', () {
      expect(leaveDays('2026-11-18', '2026-11-18'), 1);
      expect(leaveDays('2026-11-30', '2026-12-02'), 3);
      expect(checkLeaveForm(from: '2026-11-20', to: '2026-11-19', mine: const []), LeaveFormError.toBeforeFrom);
      expect(checkLeaveForm(from: '2026-11-01', to: '2026-12-01', mine: const []), isNull);
      expect(checkLeaveForm(from: '2026-11-01', to: '2026-12-02', mine: const []), LeaveFormError.tooLong);
      expect(weekdayOf('2026-11-20'), 5, reason: 'Friday is 5 on the server');
      expect(addDaysYmd('2026-12-31', 1), '2027-01-01');
    });

    test('holidays of my branch and my shift, cached for offline', () async {
      await h.signIn();
      final svc = h.read(leaveServiceProvider);
      final hol = await svc.holidays(2026, branchId: 'br-01');
      expect(hol.value.map((x) => x.date), ['2026-03-26', '2026-11-26', '2026-12-16', '2026-12-25']);
      expect(hol.value.firstWhere((x) => x.date == '2026-11-26').national, isFalse);
      final shift = await svc.myShift();
      expect(shift.value!.weeklyOff, [5]);
      expect(shift.value!.isDefault, isFalse);

      h.api.offline = true;
      final again = await svc.holidays(2026, branchId: 'br-01');
      expect(again.error, LeaveError.offline);
      expect(again.value, hasLength(4));
      expect((await svc.holidays(2027, branchId: 'br-01')).value, isEmpty, reason: 'never fetched');
    });
  });

  group('guarantor', () {
    test('comes from the ERP data on the phone', () {
      expect(Guarantor.parse(null), isNull);
      expect(Guarantor.parse(jsonEncode({'name': '', 'phone': ''})), isNull);
      final g = Guarantor.parse(jsonEncode({'name': 'আবুল কালাম', 'phone': '01812345678'}))!;
      expect(g.name, 'আবুল কালাম');
      expect(g.canCall, isTrue);
      expect(Guarantor.parse(jsonEncode({'name': 'নাম', 'phone': '—'}))!.canCall, isFalse);
    });

    test('a guarantor call is logged offline with target guarantor and no number', () async {
      await h.signIn();
      final db = h.read(databaseProvider);
      final c = await (db.select(db.customers)..limit(1)).getSingle();
      expect(Customer(c).guarantor, isNotNull, reason: 'the demo customers have guarantors');
      h.api.offline = true;
      await h.read(contactAttemptServiceProvider).record(customerId: c.serverId, at: h.clock.nowUtc(), outcome: 'connected', target: ContactTarget.guarantor);
      final row = (await db.select(db.contactAttempts).get()).single;
      expect(row.target, 'guarantor');
      expect(row.phoneIndex, isNull);
      h.api.offline = false;
      await h.read(syncEngineProvider).syncNow();
      final p = h.api.appliedPayloads.values.singleWhere((x) => x['target'] == 'guarantor');
      expect(p.containsKey('phoneIndex'), isFalse);
      expect(jsonEncode(p), isNot(contains(Customer(c).guarantor!.phone)));
    });
  });
}
