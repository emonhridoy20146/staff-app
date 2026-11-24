import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm, Value;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/api/field_api.dart' show ApiException;
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/feature/feature_manifest.dart';
import 'package:staff_app/core/media/media.dart';
import 'package:staff_app/core/permissions/permission_service.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/core/settings/ui_prefs.dart';
import 'package:staff_app/features/requests/requests.dart';
import 'package:staff_app/features/requests/src/requests_data.dart' show RequestPullHandler;

import 'helpers.dart';

/// Staff requests (FR-M-075, contract 1.48.0): offline create and comments sent once, photos held until
/// uploaded, the office's steps on the timeline and behind the bell, given-to-me items, refusals in words.
void main() {
  const report = (type: RequestType.report, priority: RequestPriority.normal, title: 'দোকান বন্ধ', details: 'গ্রাহকের দোকান তিন দিন বন্ধ', customerId: 'c-1001', customerName: null, photoCount: 0);
  const urgent = (type: RequestType.complaint, priority: RequestPriority.important, title: 'টাকা নিয়ে ঝামেলা', details: 'গ্রাহক বলছেন টাকা দিয়েছেন', customerId: null, customerName: null, photoCount: 0);

  group('data', () {
    late Harness h;
    setUp(() => h = Harness());
    tearDown(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      // Stream-backed providers were read: stop them before the database closes.
      final db = h.read(databaseProvider);
      h.container.dispose();
      await db.close();
    });

    AppDatabase db() => h.read(databaseProvider);
    Future<StaffRequestRow> row(String key) => (db().select(db().staffRequests)..where((t) => t.clientId.equals(key))).getSingle();
    Future<void> sync() => h.read(syncEngineProvider).syncNow();
    Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 30));

    /// The live providers (stream-backed: the first read subscribes, the next one has the data).
    Future<List<StaffRequest>> reqs() async {
      final sub = h.container.listen(requestsProvider, (_, _) {});
      final sub2 = h.container.listen(alertsProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final v = sub.read();
      sub.close();
      sub2.close();
      return v;
    }

    Future<List<AppAlert>> alerts() async {
      final sub = h.container.listen(alertsProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final v = sub.read();
      sub.close();
      return v;
    }

    Future<List<StaffRequest>> news() async {
      final sub = h.container.listen(requestsWithNewsProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final v = sub.read();
      sub.close();
      return v;
    }

    test('offline: the request and a comment are saved at once, sent once in order when online; the server timeline replaces the copy', () async {
      await h.signIn();
      h.api.offline = true;
      final svc = h.read(requestServiceProvider);
      final key = await svc.create(report);
      final cm = await svc.comment(key, 'আজও বন্ধ');
      var r = await row(key);
      expect([r.syncState, r.priority, r.customerId, r.createdById], ['queued', 'normal', 'c-1001', 'u-fs-014']);
      final ob = await (db().select(db().outbox)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
      final mine = ob.where((o) => o.entity.startsWith('request')).toList();
      expect([for (final o in mine) (o.entity, o.mutationId, o.state)], [('request', key, 'pending'), ('request_comment', cm, 'pending')]);
      expect(jsonDecode(mine[0].payloadJson), {'clientId': key, 'type': 'report', 'priority': 'normal', 'title': 'দোকান বন্ধ', 'body': 'গ্রাহকের দোকান তিন দিন বন্ধ', 'customerId': 'c-1001'});
      expect(jsonDecode(mine[1].payloadJson), {'clientId': cm, 'requestClientId': key, 'text': 'আজও বন্ধ'});
      expect(jsonDecode(mine[1].dependsOnJson), [key], reason: 'the comment waits for its request');

      await h.read(syncEngineProvider).kick(reason: 'test'); // offline: nothing goes, nothing is lost
      h.api.offline = false;
      await settle();
      await sync();
      r = await row(key);
      expect([r.syncState, r.serverId, r.status], ['synced', 'rq-$key', 'open']);
      expect(h.api.requests.length, 1, reason: 'sent once whatever the retries');
      final events = h.api.requests['rq-$key']!['timeline'] as List;
      expect(events.map((e) => (e as Map)['kind']), ['created', 'comment']);
      expect((events.last as Map)['clientId'], cm);
      final req = (await reqs()).single;
      expect(req.timeline.map((e) => e.type), ['created', 'comment'], reason: 'my comment shown once');
      expect(await db().select(db().requestComments).get(), isEmpty, reason: 'the sent copy is dropped once the server has it');
      expect(await news(), isEmpty, reason: 'my own steps are no news');
    });

    test('photos: the request waits held until every photo is on the server, then goes with their ids', () async {
      await h.signIn();
      final key = await h.read(requestServiceProvider).create(urgent, photos: [testJpeg(), testJpeg()]);
      await settle();
      await h.read(mediaServiceProvider).uploadPending();
      await settle();
      await sync();
      final ob = await (db().select(db().outbox)..where((t) => t.mutationId.equals(key))).getSingle();
      expect(ob.state, 'done');
      final sent = jsonDecode(ob.payloadJson) as Map<String, dynamic>;
      expect((sent['photoMediaIds'] as List).length, 2);
      expect(h.api.requests['rq-$key']!['priority'], 'important');
      expect((h.api.requests['rq-$key']!['photoMediaIds'] as List).length, 2);
      final media = await (db().select(db().mediaQueue)..where((t) => t.ownerEntity.equals(requestMediaOwner))).get();
      expect(media.map((m) => (m.kind, m.state)).toSet(), {('visit_photo', 'confirmed')});
    });

    test('a photo not uploaded keeps the request held (never sent without it, never deleted)', () async {
      await h.signIn();
      h.api.offline = true;
      final key = await h.read(requestServiceProvider).create(urgent, photos: [testJpeg()]);
      await settle();
      await h.read(mediaServiceProvider).uploadPending();
      await sync().catchError((Object _) {});
      final ob = await (db().select(db().outbox)..where((t) => t.mutationId.equals(key))).getSingle();
      expect(ob.state, 'held');
      expect((await row(key)).syncState, 'queued');
      expect((await reqs()).single.localPhotos, 1);
    });

    test('the office forwards, comments and resolves; I reopen online: the timeline and the bell show it; opening it clears the alert', () async {
      await h.signIn();
      final key = await h.read(requestServiceProvider).create(report);
      await sync();
      h.clock.advance(const Duration(minutes: 5));
      h.api.forwardRequest('rq-$key', note: 'সুপার অ্যাডমিন দেখবেন');
      h.clock.advance(const Duration(minutes: 5));
      h.api.commentOnRequest('rq-$key', 'কাল যাচ্ছি', by: const {'id': 'u-sa-001', 'name': 'সুপার অ্যাডমিন'});
      await sync();
      var r = (await reqs()).single;
      expect(r.timeline.map((e) => e.type), ['created', 'forwarded', 'comment']);
      expect([r.row.status, r.row.assigneeName, r.row.currentQueue, r.row.level], ['forwarded', null, 'super_admin', 'super_admin']);
      expect([r.timeline[1].toQueue, r.timeline[1].note, r.timeline[1].byName], ['super_admin', 'সুপার অ্যাডমিন দেখবেন', 'মোস্তফা কামাল']);
      expect(r.unseenChange?.type, 'comment');
      final alert = (await alerts()).where((a) => a.id == 'request/$key').single;
      expect(alert.route, '/requests/$key');

      await h.read(requestServiceProvider).markSeen(key);
      expect(await news(), isEmpty);

      h.clock.advance(const Duration(minutes: 5));
      h.api.resolveRequest('rq-$key', note: 'দোকান খুলেছে');
      await sync();
      r = (await reqs()).single;
      expect([r.isClosed, r.canReopen, r.unseenChange?.type, r.unseenChange?.note, r.resolutionNote], [true, true, 'resolved', 'দোকান খুলেছে', 'দোকান খুলেছে']);
      expect(filterRequests([r], RequestFilter.resolved), [r]);
      expect(r.canComment, isTrue, reason: '1.48.0: a resolved request still takes comments');

      h.clock.advance(const Duration(minutes: 5));
      h.api.closeRequest('rq-$key');
      await sync();
      r = (await reqs()).single;
      expect([r.isClosed, r.canComment, r.canReopen], [true, false, true]);
      await expectLater(h.read(requestServiceProvider).comment(key, 'ধন্যবাদ'), throwsA(isA<RequestInvalid>()));

      // Reopen is online only: offline it fails and nothing changes.
      await expectLater(h.read(requestServiceProvider).reopen(key, ' '), throwsA(isA<RequestInvalid>()));
      h.api.offline = true;
      await expectLater(h.read(requestServiceProvider).reopen(key, 'আবার বন্ধ'), throwsA(isA<ApiException>()));
      expect((await row(key)).status, 'closed');
      h.api.offline = false;
      h.clock.advance(const Duration(minutes: 5));
      await h.read(requestServiceProvider).reopen(key, 'আবার বন্ধ');
      r = (await reqs()).single;
      expect([r.row.status, r.isClosed, r.canComment, r.timeline.last.type, r.timeline.last.note], ['reopened', false, true, 'reopened', 'আবার বন্ধ']);
      expect(await news(), isEmpty, reason: 'my own reopen is no news');
    });

    test('given to me: a colleague\'s request the office assigned to me is listed apart and on the bell; I can comment', () async {
      h.api.addRequestForMe('rq-col-1', title: 'গ্রাহকের ঠিকানা বদল', body: 'নতুন ঠিকানা দেখে আসুন');
      await h.signIn();
      final all = await reqs();
      expect(assignedRequests(all).single.row.title, 'গ্রাহকের ঠিকানা বদল');
      expect(filterRequests(all, RequestFilter.open), isEmpty, reason: 'not mine');
      final a = (await alerts()).where((a) => a.id == 'request/cl-rq-col-1').single;
      expect(a.kind, AlertKind.task);
      await h.read(requestServiceProvider).comment('cl-rq-col-1', 'দেখে এসেছি');
      await sync();
      final last = (h.api.requests['rq-col-1']!['timeline'] as List).last as Map<String, dynamic>;
      expect((last['note'], (last['actor'] as Map)['id']), ('দেখে এসেছি', 'u-fs-014'));
      expect(assignedRequests(await reqs()).single.row.status, 'in_progress');
    });

    test('refused: kept with its reason, in Problems; a pull never deletes an unsent one', () async {
      await h.signIn();
      h.api.refuseRequests = 'FORBIDDEN';
      final key = await h.read(requestServiceProvider).create(report);
      await sync();
      final r = await row(key);
      expect([r.syncState, r.errorCode], ['failed', 'FORBIDDEN']);
      final ob = await (db().select(db().outbox)..where((t) => t.mutationId.equals(key))).getSingle();
      expect(ob.state, 'failed', reason: 'stays in Problems');

      h.api.offline = true;
      final queued = await h.read(requestServiceProvider).create(urgent);
      await RequestPullHandler().delete(db(), 'rq-$queued');
      await (db().update(db().staffRequests)..where((t) => t.clientId.equals(queued))).write(const StaffRequestsCompanion(serverId: Value('rq-x')));
      await RequestPullHandler().delete(db(), 'rq-x');
      expect((await row(queued)).syncState, 'queued', reason: 'never deleted while unsent');
    });
  });

  group('screens', () {
    Future<void> settle(WidgetTester t, {int rounds = 8}) async {
      for (var i = 0; i < rounds; i++) {
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await t.pump(const Duration(milliseconds: 100));
      }
    }

    Future<Harness> start(WidgetTester t, {String lang = 'bn', double textScale = 1, void Function(Harness h)? seed}) async {
      final h = Harness();
      seed?.call(h);
      await t.runAsync(h.signIn);
      await t.runAsync(() => h.read(uiPrefsProvider.notifier).update(UiPrefs(language: lang)));
      t.view.physicalSize = const Size(412, 892) * 2;
      t.view.devicePixelRatio = 2;
      t.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(t.view.reset);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
      await settle(t);
      return h;
    }

    Future<void> finish(WidgetTester t, Harness h) async {
      await t.pump(const Duration(seconds: 10));
      await t.pumpWidget(const SizedBox());
      await settle(t);
    }

    Future<void> tapVisible(WidgetTester t, Finder f, {bool up = false}) async {
      // Lists build lazily: scroll the page until the widget exists.
      if (f.evaluate().isEmpty) await t.scrollUntilVisible(f, up ? -200 : 200, scrollable: find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down && w.restorationId != 'editable').first);
      await t.ensureVisible(f);
      await settle(t, rounds: 2);
      await t.tap(f);
      await settle(t);
    }

    testWidgets('Me → আমার অনুরোধ → new: errors in words, super admin choice, camera photo, saved and listed; detail and comment', (t) async {
      final h = await start(t);
      h.read(routerProvider).go('/me');
      await settle(t);
      await tapVisible(t, find.byType(RequestsMeEntry));
      expect(find.text('আমার অনুরোধ'), findsWidgets);
      expect(find.text('কোনো অনুরোধ নেই'), findsOneWidget);
      await t.tap(find.byKey(const Key('request-add')));
      await settle(t);
      // The two recipients read as two clear choices.
      expect(find.text('এরিয়া ম্যানেজারকে'), findsOneWidget);
      expect(find.text('সুপার অ্যাডমিনকে — খুব জরুরি'), findsOneWidget);
      await tapVisible(t, find.byKey(const Key('request-save')));
      expect(find.text('বিষয় লিখুন'), findsOneWidget);

      await tapVisible(t, find.byKey(const Key('request-type-complaint')), up: true);
      await tapVisible(t, find.byKey(const Key('request-priority-important')));
      await t.enterText(find.byKey(const Key('request-title')), 'টাকা নিয়ে ঝামেলা');
      await t.enterText(find.byKey(const Key('request-details')), 'গ্রাহক বলছেন টাকা দিয়েছেন');
      await tapVisible(t, find.byKey(const Key('request-photo')));
      expect(find.byType(Image), findsOneWidget);
      expect(t.getSize(find.byKey(const Key('request-save'))).height, greaterThanOrEqualTo(48));
      expect(t.getSize(find.byKey(const Key('request-photo'))).height, greaterThanOrEqualTo(48));
      await tapVisible(t, find.byKey(const Key('request-save')));
      await settle(t, rounds: 20);

      expect(find.text('টাকা নিয়ে ঝামেলা'), findsOneWidget);
      expect(find.text('সুপার অ্যাডমিন · খুব জরুরি'), findsOneWidget);
      final saved = h.api.requests.values.single;
      expect([saved['type'], saved['priority'], (saved['photoMediaIds'] as List).length], ['complaint', 'important', 1]);

      // Resolved filter: nothing yet.
      await tapVisible(t, find.byKey(const Key('request-filter-resolved')));
      expect(find.text('কোনো অনুরোধ নেই'), findsOneWidget);
      await tapVisible(t, find.byKey(const Key('request-filter-open')));

      // Detail: timeline and a comment (offline-first).
      h.api.forwardRequest(saved['id'] as String, to: const {'id': 'u-am-001', 'name': 'আমিনুল ইসলাম'});
      h.read(syncEngineProvider).kick(reason: 'test').ignore();
      await settle(t, rounds: 12);
      await tapVisible(t, find.text('টাকা নিয়ে ঝামেলা'));
      expect(find.text('ইতিহাস'), findsOneWidget);
      expect(find.text('আমিনুল ইসলাম-এর কাছে পাঠানো হয়েছে'), findsOneWidget);
      h.api.offline = true;
      await tapVisible(t, find.byKey(const Key('request-comment')));
      await t.enterText(find.byKey(const Key('request-comment')), 'কাগজ নিয়ে আসছি');
      await tapVisible(t, find.byKey(const Key('request-comment-send')));
      expect(find.text('কাগজ নিয়ে আসছি'), findsOneWidget);
      expect(find.text('পাঠানোর অপেক্ষায়'), findsWidgets);
      await finish(t, h);
    });

    testWidgets('customer page action opens the form with the customer filled in; it can be removed', (t) async {
      final h = await start(t);
      final db = h.read(databaseProvider);
      final c = await t.runAsync(() => db.select(db.customers).get());
      final cust = c!.first;
      h.read(routerProvider).go('/customers/${cust.serverId}?action=request');
      await settle(t);
      expect(find.text('নতুন অনুরোধ / রিপোর্ট'), findsOneWidget);
      final chip = find.byKey(const Key('request-customer'));
      expect(find.descendant(of: chip, matching: find.text(cust.nameBn)), findsOneWidget);
      await t.enterText(find.byKey(const Key('request-title')), 'দোকান বন্ধ');
      await t.enterText(find.byKey(const Key('request-details')), 'তিন দিন');
      await tapVisible(t, find.byKey(const Key('request-save')));
      await settle(t, rounds: 12);
      expect(h.api.requests.values.single['customerId'], cust.serverId);
      await finish(t, h);
    });

    testWidgets('English at 130 % text: form, list and detail fit; given-to-me section', (t) async {
      final h = await start(t, lang: 'en', textScale: 1.3, seed: (h) => h.api.addRequestForMe('rq-col-1', title: 'Customer moved', body: 'Check the new address'));
      h.read(routerProvider).go('/requests');
      await settle(t);
      expect(find.text('Assigned to me'), findsOneWidget);
      expect(find.text('Customer moved'), findsOneWidget);
      expect(find.text('New update'), findsOneWidget);
      await tapVisible(t, find.text('Customer moved'));
      expect(find.text('History'), findsOneWidget);
      expect(find.textContaining('Assigned to'), findsWidgets);
      h.read(routerProvider).go('/requests/new');
      await settle(t);
      expect(find.text('To the super admin — very important'), findsOneWidget);
      await tapVisible(t, find.byKey(const Key('request-save')));
      expect(find.text('Write a subject'), findsOneWidget);
      expect(t.takeException(), isNull);
      await finish(t, h);
    });

    testWidgets('a resolved request of mine: the resolution is shown; reopen asks for a reason and goes online', (t) async {
      final h = await start(t);
      final key = (await t.runAsync(() => h.read(requestServiceProvider).create(report)))!;
      await settle(t, rounds: 12);
      h.api.resolveRequest('rq-$key', note: 'দোকান খুলেছে');
      h.read(syncEngineProvider).kick(reason: 'test').ignore();
      await settle(t, rounds: 12);
      h.read(routerProvider).go('/requests/$key');
      await settle(t);
      expect(find.text('সমাধানের কথা'), findsOneWidget);
      await tapVisible(t, find.byKey(const Key('request-reopen')));
      expect(find.text('অনুরোধ আবার খুলবেন?'), findsOneWidget);
      await t.tap(find.byKey(const Key('request-reopen-send')));
      await settle(t, rounds: 2);
      expect(find.text('কারণ লিখুন'), findsOneWidget);
      await t.enterText(find.byKey(const Key('request-reopen-note')), 'আবার বন্ধ পেয়েছি');
      await t.tap(find.byKey(const Key('request-reopen-send')));
      await settle(t, rounds: 12);
      expect(h.api.requests['rq-$key']!['status'], 'reopened');
      expect(find.text('আবার খোলা হয়েছে'), findsWidgets);
      expect(find.byKey(const Key('request-reopen')), findsNothing);
      await finish(t, h);
    });

    testWidgets('flag off or no permission: no Me entry', (t) async {
      final h = await start(t);
      h.read(accessProvider.notifier).set(flags: {...h.read(accessProvider).flags, 'module.requests': false});
      h.read(routerProvider).go('/me');
      await settle(t);
      expect(find.byType(RequestsMeEntry), findsNothing);
      h.read(accessProvider.notifier).set(flags: {...h.read(accessProvider).flags, 'module.requests': true}, permissions: h.read(accessProvider).permissions.difference({Perm.requestCreate}));
      await settle(t);
      expect(find.byType(RequestsMeEntry), findsNothing);
      await finish(t, h);
    });
  });
}
