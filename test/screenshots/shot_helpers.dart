import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/core/settings/ui_prefs.dart';
import 'package:staff_app/features/attendance/attendance.dart';
import 'package:staff_app/features/auth/auth.dart';
import 'package:staff_app/features/collections/collections.dart';
import 'package:staff_app/features/collections/src/application/record_collection.dart';
import 'package:staff_app/features/collections/src/collection_providers.dart' show receiptAllocatorProvider;
import 'package:staff_app/features/customers/customers.dart';

import '../flows/helpers.dart';

/// Shared set-up for the screenshot suites (real fonts, a signed-in demo day).
Future<void> loadShotFonts() async {
  Future<void> family(String name, List<String> files) async {
    final l = FontLoader(name);
    for (final f in files) {
      l.addFont(rootBundle.load(f));
    }
    await l.load();
  }

  await family('Inter', [for (final w in [400, 500, 600, 700]) 'assets/fonts/Inter-$w.ttf']);
  await family('NotoSansBengali', [for (final w in [400, 500, 600, 700]) 'assets/fonts/NotoSansBengali-$w.ttf']);
  await family('JetBrainsMono', ['assets/fonts/JetBrainsMono-500.ttf', 'assets/fonts/JetBrainsMono-600.ttf']);
  await family('MaterialIcons', ['fonts/MaterialIcons-Regular.otf']);
}

Future<void> settleShot(WidgetTester t, {int rounds = 12}) async {
  for (var i = 0; i < rounds; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await t.pump(const Duration(milliseconds: 100));
  }
}

/// A signed-in, on-duty day with three collections and a pending handover.
Future<Harness> readyShot(
  WidgetTester t, {
  bool signIn = true,
  bool dark = false,
  String lang = 'bn',
  Size size = const Size(412, 892),
  double textScale = 1.0,
  bool workIn = true,
  bool collect = true,
  Future<void> Function(Harness h)? setup,
}) async {
  final h = Harness();
  await t.runAsync(() async {
    if (signIn) {
      await h.signIn();
      if (workIn) {
        await h.read(attendanceServiceProvider).record(AttendanceEventType.workIn, fix: await h.read(locationEngineProvider).currentFix(), selfie: testJpeg());
      }
      if (collect) {
        final rc = h.read(recordCollectionProvider);
        await h.read(receiptAllocatorProvider).topUp(h.read(fieldApiProvider), deviceId: h.read(deviceIdentityProvider).deviceId, businessDate: h.clock.businessDate());
        final repo = h.read(customerRepositoryProvider);
        Future<void> one(String id, int poisha, PaymentMethod m, [String? txn]) async {
          final c = (await repo.getOne(id))!;
          await rc(CollectionInput(customerId: id, customerName: c.row.nameBn, customerCode: c.code, amountPoisha: poisha, method: m, txnRef: txn, outstandingPoisha: c.outstanding));
        }

        await one('c-1001', 250000, PaymentMethod.cash);
        await one('c-1003', 180000, PaymentMethod.bkash, '9AB3KD72X1');
        await one('c-1008', 120000, PaymentMethod.cash);
      }
      h.api.addPendingHandover();
      await h.read(syncEngineProvider).kick();
    } else {
      await h.read(sessionProvider.notifier).restore();
    }
    await h.read(uiPrefsProvider.notifier).update(UiPrefs(language: lang, themeMode: dark ? ThemeMode.dark : ThemeMode.light));
    if (setup != null) await setup(h);
  });
  t.view.physicalSize = size * 2;
  t.view.devicePixelRatio = 2;
  t.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
  await settleShot(t);
  return h;
}

Future<void> takeShot(WidgetTester t, Harness h, String name, {String? go, Future<void> Function()? then}) async {
  if (go != null) {
    h.read(routerProvider).go(go);
    await settleShot(t);
  }
  if (then != null) {
    await then();
    await settleShot(t);
  }
  // Real shadows for the picture (the test default draws solid outlines).
  debugDisableShadows = false;
  await t.pump();
  await expectLater(find.byType(FieldApp), matchesGoldenFile('goldens/$name.png'));
  debugDisableShadows = true;
  await t.pumpWidget(const SizedBox.shrink());
  // Closing drift inside the fake-async zone can hang; the in-memory DB is
  // dropped with the test isolate.
  h.container.dispose();
  await t.pump(const Duration(milliseconds: 50));
}
