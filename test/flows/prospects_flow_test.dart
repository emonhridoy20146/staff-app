import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/location/location_engine.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/attendance/attendance.dart';
import 'package:staff_app/features/prospects/prospects.dart';

import 'helpers.dart';

/// Possible customers (FR-M-073, provisional contract 1.45.0): offline create, own edit while `new`, status and
/// who added it from the server, location only on duty.
void main() {
  const draft = (name: 'জামাল হোসেন', phones: ['০১৭১১-২২৩৩৪৪', '', '+8801811223344'], address: 'বাজার রোড', note: 'ফ্রিজ কিনতে চান');
  final fix = GeoFix(lat: 22.7, lng: 90.35, accuracyM: 8, fixAt: DateTime.utc(2026, 11, 15, 4));

  test('rules: name and one valid number needed; numbers cleaned, repeated refused', () {
    expect(validateProspect((name: ' ', phones: ['01711223344'], address: '', note: '')).error, ProspectError.nameMissing);
    expect(validateProspect((name: 'ক', phones: ['', ''], address: '', note: '')).error, ProspectError.phoneMissing);
    expect(validateProspect((name: 'ক', phones: ['12345'], address: '', note: '')).error, ProspectError.phoneInvalid);
    expect(validateProspect((name: 'ক', phones: ['01711223344', '+8801711223344'], address: '', note: '')).error, ProspectError.phoneRepeated);
    expect(validateProspect((name: 'ক' * 121, phones: ['01711223344'], address: '', note: '')).error, ProspectError.nameTooLong);
    expect(validateProspect(draft).draft!.phones, ['01711223344', '01811223344']);
  });

  group('data', () {
    late Harness h;
    setUp(() => h = Harness());
    tearDown(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await h.dispose();
    });

    Future<ProspectRow> row(String id) {
      final db = h.read(databaseProvider);
      return (db.select(db.prospects)..where((t) => t.clientId.equals(id))).getSingle();
    }

    test('offline create: saved at once and queued once; online: the server status and who added it come back', () async {
      await h.signIn();
      h.api.offline = true;
      final svc = h.read(prospectServiceProvider);
      final id = await svc.create(draft, fix: fix); // off duty: the fix is dropped (CLAUDE.md §2.6)
      var r = await row(id);
      expect([r.name, r.syncState, r.status, r.lat], ['জামাল হোসেন', 'queued', 'new', null]);
      final db = h.read(databaseProvider);
      final ob = await (db.select(db.outbox)..where((t) => t.entity.equals('prospect'))).getSingle();
      expect([ob.mutationId, ob.op], [id, 'create']);
      final payload = jsonDecode(ob.payloadJson) as Map<String, dynamic>;
      expect(payload['clientId'], id);
      expect(payload['phones'], [{'number': '01711223344'}, {'number': '01811223344'}]);
      expect(payload.keys.toSet(), {'clientId', 'name', 'phones', 'address', 'note'}, reason: 'ProspectCreate fields only, no location off duty');

      await h.read(syncEngineProvider).kick(reason: 'test');
      h.api.offline = false;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await h.read(syncEngineProvider).syncNow();
      r = await row(id);
      expect([r.syncState, r.serverId, r.createdByName], ['synced', 'pr-$id', 'রহিম উদ্দিন']);
      expect(jsonDecode(r.phonesJson), ['01711223344', '01811223344'], reason: 'the server stores +8801…; shown as 01…');
      expect(h.api.prospects.length, 1, reason: 'sent once whatever the retries');
    });

    test('on duty: where I am is saved and sent', () async {
      h.api.selfieRequired = false;
      await h.signIn();
      await h.read(attendanceServiceProvider).record(AttendanceEventType.workIn);
      final sub = h.container.listen(todayAttendanceProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final id = await h.read(prospectServiceProvider).create(draft, fix: fix);
      sub.close();
      final r = await row(id);
      expect([r.lat, r.lng, r.accuracyM], [22.7, 90.35, 8]);
      await h.read(syncEngineProvider).kick(reason: 'test');
      expect(h.api.prospects['pr-$id']!['location'], {'lat': 22.7, 'lng': 90.35, 'accuracyM': 8.0});
    });

    test('change my own before it is sent: the queued create is rewritten (same id, one mutation); not after', () async {
      await h.signIn();
      h.api.offline = true;
      final svc = h.read(prospectServiceProvider);
      final id = await svc.create(draft);
      final db = h.read(databaseProvider);
      // The sync started by create() failed offline: that create was tried, so it may be on the server already.
      await h.read(syncEngineProvider).kick(reason: 'test');
      await expectLater(svc.update(id, draft), throwsA(isA<ProspectInvalid>()));

      // Never tried (as when no sync ran yet): it may be changed.
      await db.customStatement("UPDATE outbox SET attempts = 0, state = 'pending' WHERE mutation_id = '$id'");
      await svc.update(id, (name: 'জামাল হোসেন মিয়া', phones: ['01711223344'], address: '', note: ''));
      final obs = await (db.select(db.outbox)..where((t) => t.entity.equals('prospect'))).get();
      expect(obs, hasLength(1));
      final payload = jsonDecode(obs.single.payloadJson) as Map<String, dynamic>;
      expect([payload['clientId'], payload['name'], payload['phones']], [id, 'জামাল হোসেন মিয়া', [{'number': '01711223344'}]]);
      expect(payload.containsKey('address'), isFalse);

      h.api.offline = false;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await h.read(syncEngineProvider).syncNow();
      expect(h.api.prospects['pr-$id']!['name'], 'জামাল হোসেন মিয়া');
      expect((await row(id)).syncState, 'synced');
      // On the server now: only the office changes it (contract 1.45.0).
      await expectLater(svc.update(id, draft), throwsA(isA<ProspectInvalid>().having((e) => e.error, 'error', ProspectError.notEditable)));
      h.api.setProspectStatus(id, 'dropped');
      await h.read(syncEngineProvider).kick(reason: 'test');
      expect((await row(id)).status, 'dropped');
    });
  });

  testWidgets('Me → Possible customers → add one off duty (no location offered) → listed with status and by me', (t) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 2400) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    Future<void> settle() async {
      for (var i = 0; i < 8; i++) {
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await t.pump(const Duration(milliseconds: 100));
      }
    }

    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle();
    h.read(routerProvider).go('/me');
    await settle();
    await t.tap(find.byType(ProspectsMeEntry));
    await settle();
    expect(find.text('এখনো কোনো সম্ভাব্য গ্রাহক নেই'), findsOneWidget);
    await t.tap(find.text('যোগ করুন'));
    await settle();
    // Off duty: the location switch is off and cannot be turned on.
    final sw = t.widget<SwitchListTile>(find.byKey(const Key('prospect-location')));
    expect(sw.onChanged, isNull);
    expect(find.text('ডিউটিতে থাকলেই শুধু জায়গা নেওয়া হয়'), findsOneWidget);
    // A missing number is said in words.
    await t.enterText(find.byKey(const Key('prospect-name')), 'জামাল হোসেন');
    await t.tap(find.byKey(const Key('prospect-save')));
    await settle();
    expect(find.text('অন্তত একটি মোবাইল নম্বর লিখুন'), findsOneWidget);
    await t.enterText(find.byKey(const Key('prospect-phone-0')), '01711223344');
    expect(t.getSize(find.byKey(const Key('prospect-save'))).height, greaterThanOrEqualTo(48));
    await t.tap(find.byKey(const Key('prospect-save')));
    await settle();
    expect(find.text('জামাল হোসেন'), findsOneWidget);
    expect(find.text('নতুন'), findsOneWidget);
    expect(find.textContaining('যোগ করেছেন আপনি'), findsOneWidget);
    expect(find.text('পরিবর্তন'), findsNothing); // sent at once (online): only the office changes it now
    await t.pump(const Duration(seconds: 10));
    await t.pumpWidget(const SizedBox());
    await settle();
  });
}
