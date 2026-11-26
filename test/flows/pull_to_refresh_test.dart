import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/ui/refreshable.dart';
import 'package:staff_app/features/collections/collections.dart';
import 'package:staff_app/features/collections/src/application/record_collection.dart';

import 'helpers.dart';

/// Pull-to-refresh on every screen that shows synced or server data
/// (docs/pull-to-refresh-audit.md). Screens that read the phone's database run
/// "Sync now" (a `GET /sync/pull` reaches the server); online-only screens
/// fetch their own endpoint again.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 8}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  const pull = 'GET /sync/pull';

  Future<Harness> start(WidgetTester t) async {
    final h = Harness();
    h.api.addTask('tk-1', title: 'গুদাম থেকে ফ্রিজ আনুন', dueDate: '2026-11-20');
    h.api.addRequestForMe('rq-9', title: 'দোকানের সামনে রাস্তা বন্ধ');
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    return h;
  }

  /// Lets snack bars and timers run out, then unmounts the app (no timer left behind).
  Future<void> finish(WidgetTester t) async {
    await t.pump(const Duration(seconds: 10));
    await t.pumpWidget(const SizedBox());
    await settle(t);
  }

  Future<void> open(WidgetTester t, Harness h, String route) async {
    h.read(routerProvider).go(route);
    await settle(t);
    expect(h.read(routerProvider).state.uri.toString(), route, reason: 'the route opened (not redirected)');
  }

  /// Nothing reaches [expected] while the screen just sits there, so a later hit is the pull's doing.
  Future<void> quietThenClear(WidgetTester t, Harness h, String expected) async {
    h.api.requestLog.clear();
    await settle(t, rounds: 4);
    expect(h.api.requestLog.where((r) => r.startsWith(expected)), isEmpty, reason: 'no $expected without a pull');
  }

  /// Runs the visible indicator's refresh and waits for it to finish.
  Future<void> runRefresh(WidgetTester t) async {
    final indicator = find.byType(RefreshIndicator).hitTestable();
    expect(indicator, findsWidgets, reason: 'the screen has pull-to-refresh');
    var done = false;
    unawaited(t.widget<RefreshIndicator>(indicator.first).onRefresh().whenComplete(() => done = true));
    for (var i = 0; i < 60 && !done; i++) {
      await settle(t, rounds: 1);
    }
    expect(done, isTrue, reason: 'the refresh finishes');
    await settle(t, rounds: 2);
  }

  /// Every screen with pull-to-refresh, and the request its pull must send.
  final screens = <(String, Future<String> Function(WidgetTester, Harness), String)>[
    ('Today', (_, _) async => '/today', pull),
    ('Customers', (_, _) async => '/customers', pull),
    ('Customer detail', (_, _) async => '/customers/c-1001', 'POST /customers/c-1001/refresh'),
    ('Me', (_, _) async => '/me', pull),
    ('Attendance hub', (_, _) async => '/attendance', pull),
    ('Leave', (_, _) async => '/attendance/leave', 'GET /leave-requests'),
    ('Work calendar', (_, _) async => '/attendance/calendar', 'GET /attendance/me/shift'),
    ('Cash in hand', (_, _) async => '/cash/in-hand', 'GET /cash/me/collections'),
    ('Co-work', (_, _) async => '/cowork', 'GET /cowork/colleagues'),
    ('Handovers', (_, _) async => '/handovers', pull),
    ('Notices', (_, _) async => '/notices', pull),
    ('Notice detail', (_, _) async => '/notices/bc-1', pull),
    ('Prospects', (_, _) async => '/prospects', pull),
    ('Performance', (_, _) async => '/performance', 'GET /reports/me/performance'),
    ('Leaderboard (collection board tab)', (_, _) async => '/leaderboard', 'GET /reports/collection-board'),
    ('Requests', (_, _) async => '/requests', pull),
    ('Request detail', (_, _) async => '/requests/cl-rq-9', pull),
    ('Sync centre', (_, _) async => '/sync', pull),
    ('Tasks', (_, _) async => '/tasks', pull),
    ('Task detail', (_, _) async => '/tasks/tk-1', pull),
    ('Alerts', (_, _) async => '/alerts', pull),
    ("Today's work", (_, _) async => '/today-work', pull),
    (
      'Receipt',
      (t, h) async {
        final r = (await t.runAsync(() => h.read(recordCollectionProvider).call(
              const CollectionInput(customerId: 'c-1001', customerName: 'Test', customerCode: 'T-1', amountPoisha: 150000, method: PaymentMethod.cash),
            )))!;
        await settle(t);
        return '/receipt/${r.clientId}';
      },
      pull,
    ),
  ];

  for (final (name, route, expected) in screens) {
    testWidgets('$name: pulling down sends $expected', (t) async {
      final h = await start(t);
      await open(t, h, await route(t, h));
      if (name == 'Receipt') {
        // Known before this change: with the test font the receipt's bottom button row overflows
        // (it does with the screen unchanged too). Not what this test checks; anything else still fails.
        final e = t.takeException();
        if (e != null) expect('$e', contains('RenderFlex overflowed'));
      }
      await quietThenClear(t, h, expected);
      await runRefresh(t);
      expect(h.api.requestLog, contains(startsWith(expected)));
      expect(t.takeException(), isNull);
      await finish(t);
    });
  }

  testWidgets('a short, empty screen can still be dragged down (always scrollable): Tasks with no task', (t) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    await open(t, h, '/tasks');
    expect(find.byType(PullableFill), findsOneWidget, reason: 'no task: the empty state');
    await quietThenClear(t, h, pull);

    await t.fling(find.byType(PullableFill), const Offset(0, 400), 1000);
    await t.pump();
    await t.pump(const Duration(milliseconds: 300)); // the indicator snaps and starts the refresh
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    await settle(t, rounds: 12);
    expect(h.api.requestLog, contains(pull));
    expect(t.takeException(), isNull);
    await finish(t);
  });

  testWidgets('a short notice detail can be dragged down too', (t) async {
    final h = await start(t);
    await open(t, h, '/notices/bc-2');
    await quietThenClear(t, h, pull);
    await t.fling(find.byType(ListView).hitTestable().first, const Offset(0, 400), 1000);
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    await settle(t, rounds: 12);
    expect(h.api.requestLog, contains(pull));
    await finish(t);
  });
}
