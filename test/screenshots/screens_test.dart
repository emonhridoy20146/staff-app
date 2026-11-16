@Tags(['screenshots'])
library;

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

/// Renders key screens with the real fonts to PNG (test/screenshots/goldens).
/// Regenerate: `flutter test --tags screenshots --update-goldens`.
Future<void> _loadFonts() async {
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

const _size = Size(412, 892);

Future<void> _settle(WidgetTester t, {int rounds = 12}) async {
  for (var i = 0; i < rounds; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<Harness> _ready(WidgetTester t, {bool signIn = true, bool dark = false, String lang = 'bn'}) async {
  final h = Harness();
  await t.runAsync(() async {
    if (signIn) {
      await h.signIn();
      await h.read(attendanceServiceProvider).record(AttendanceEventType.workIn, fix: await h.read(locationEngineProvider).currentFix(), selfie: testJpeg());
      // Some realistic activity for today.
      final rc = h.read(recordCollectionProvider);
      await h.read(receiptAllocatorProvider).topUp(h.read(fieldApiProvider), deviceId: h.read(deviceIdentityProvider).deviceId, businessDate: h.clock.businessDate());
      final repo = h.read(customerRepositoryProvider);
      Future<void> collect(String id, int poisha, PaymentMethod m, [String? txn]) async {
        final c = (await repo.getOne(id))!;
        await rc(CollectionInput(customerId: id, customerName: c.row.nameBn, customerCode: c.code, amountPoisha: poisha, method: m, txnRef: txn, outstandingPoisha: c.outstanding));
      }

      await collect('c-1001', 250000, PaymentMethod.cash);
      await collect('c-1003', 180000, PaymentMethod.bkash, '9AB3KD72X1');
      await collect('c-1008', 120000, PaymentMethod.cash);
      h.api.addPendingHandover();
      await h.read(syncEngineProvider).kick();
    } else {
      await h.read(sessionProvider.notifier).restore();
    }
    await h.read(uiPrefsProvider.notifier).update(UiPrefs(language: lang, themeMode: dark ? ThemeMode.dark : ThemeMode.light));
  });
  t.view.physicalSize = _size * 2;
  t.view.devicePixelRatio = 2;
  await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
  await _settle(t);
  return h;
}

Future<void> _shot(WidgetTester t, Harness h, String name, {String? go, Future<void> Function()? then}) async {
  if (go != null) {
    h.read(routerProvider).go(go);
    await _settle(t);
  }
  if (then != null) {
    await then();
    await _settle(t);
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

void main() {
  setUpAll(_loadFonts);

  testWidgets('01 login', (t) async => _shot(t, await _ready(t, signIn: false), '01-login'));
  testWidgets('02 today', (t) async => _shot(t, await _ready(t), '02-today', go: '/today'));
  testWidgets('03 customers', (t) async => _shot(t, await _ready(t), '03-customers', go: '/customers'));
  testWidgets('04 customer detail', (t) async => _shot(t, await _ready(t), '04-customer-detail', go: '/customers/c-1002'));
  testWidgets('05 collect amount', (t) async => _shot(t, await _ready(t), '05-collect-amount', go: '/collect/c-1002'));
  testWidgets('06 receipt', (t) async {
    final h = await _ready(t);
    final db = h.read(databaseProvider);
    final id = await t.runAsync(() async => (await db.select(db.collections).get()).first.clientId);
    await _shot(t, h, '06-receipt', go: '/collect/success/$id');
  });
  testWidgets('07 map', (t) async => _shot(t, await _ready(t), '07-map', go: '/map'));
  testWidgets('08 sync centre', (t) async => _shot(t, await _ready(t), '08-sync-centre', go: '/sync'));
  testWidgets('09 me', (t) async => _shot(t, await _ready(t), '09-me', go: '/me'));
  testWidgets('10 promise sheet', (t) async {
    final h = await _ready(t);
    await _shot(t, h, '10-promise', go: '/customers/c-1002?action=promise');
  });
  testWidgets('11 today dark', (t) async => _shot(t, await _ready(t, dark: true), '11-today-dark', go: '/today'));
  testWidgets('12 today english', (t) async => _shot(t, await _ready(t, lang: 'en'), '12-today-en', go: '/today'));
  testWidgets('13 customer without pin', (t) async => _shot(t, await _ready(t), '13-customer-no-pin', go: '/customers/c-1010'));
  testWidgets('15 work-in with photo', (t) async => _shot(t, await _ready(t, signIn: true), '15-work-in', go: '/attendance/work-in'));
  testWidgets('14 set location', (t) async => _shot(t, await _ready(t), '14-set-location', go: '/customers/c-1010/pin'));
}
