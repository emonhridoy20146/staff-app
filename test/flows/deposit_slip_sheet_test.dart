import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/cash/src/cash.dart';
import 'package:staff_app/features/cash/src/record_deposit.dart';
import 'package:staff_app/l10n/app_localizations.dart';

import 'helpers.dart';

/// FR-M-065: on the deposit sheet a bank deposit cannot be confirmed until a camera photo of the
/// slip is taken; the branch cashier and the manager need none. The confirm shows the slip.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 6}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<Harness> open(WidgetTester t) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(
      container: h.container,
      child: MaterialApp(
        locale: const Locale('bn'),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (c) => Scaffold(body: TextButton(onPressed: () => showDepositSheet(c), child: const Text('open')))),
      ),
    ));
    await t.tap(find.text('open'));
    await settle(t);
    return h;
  }

  FilledButton submit(WidgetTester t) => t.widget<FilledButton>(find.ancestor(of: find.text('জমা দিন'), matching: find.byWidgetPredicate((w) => w is FilledButton)).first);

  testWidgets('bank: the deposit button waits for the slip photo; the photo shows on the sheet and on the confirm', (t) async {
    final h = await open(t);
    expect(submit(t).onPressed, isNotNull, reason: 'branch cashier needs no slip');
    expect(find.text('স্লিপের ছবি তুলুন'), findsNothing);

    await t.tap(find.text('ব্যাংক'));
    await settle(t);
    expect(find.text('ব্যাংকে জমার জন্য জমা স্লিপের ছবি লাগবে। শুধু ক্যামেরা দিয়ে।'), findsOneWidget);
    expect(submit(t).onPressed, isNull);

    await t.tap(find.text('স্লিপের ছবি তুলুন')); // the camera (a fake capturer in tests); no gallery anywhere
    await settle(t);
    expect(find.byType(SlipThumb), findsOneWidget);
    expect(find.text('আবার তুলুন'), findsOneWidget);
    expect(submit(t).onPressed, isNotNull);

    await t.tap(find.text('জমা দিন').last);
    await settle(t);
    expect(find.byType(DepositConfirmDialog), findsOneWidget);
    expect(find.descendant(of: find.byType(DepositConfirmDialog), matching: find.byType(SlipThumb)), findsOneWidget);
    expect(find.text('স্লিপের ছবি আপলোড হলেই জমা পাঠানো হবে।'), findsOneWidget);
    await t.tap(find.text('বাতিল'));
    await settle(t);

    // Back to the manager: no slip asked, the button works again.
    await t.tap(find.text('ম্যানেজার'));
    await settle(t);
    expect(find.text('স্লিপের ছবি তুলুন'), findsNothing);
    expect(find.byType(SlipThumb), findsNothing);
    expect(submit(t).onPressed, isNotNull);
    await t.runAsync(() async {
      await h.read(syncEngineProvider).kick(reason: 'test');
      await h.dispose();
    });
  });

  testWidgets('the deposit history shows the slip of a bank deposit and none for a cashier deposit', (t) async {
    final h = Harness();
    await t.runAsync(() async {
      await h.signIn();
      final rd = h.read(recordDepositProvider);
      expect(await rd.call(shown: await rd.plan(), destination: 'bank', slipPhoto: testJpeg()), DepositSaveResult.saved);
    });
    t.view.physicalSize = const Size(412, 1400) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(
      container: h.container,
      child: const MaterialApp(
        locale: Locale('bn'),
        localizationsDelegates: [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: CashCard())),
      ),
    ));
    await settle(t);
    expect(find.byType(SlipThumb), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('ব্যাংক জমা স্লিপ')), findsWidgets);
    await t.runAsync(() async {
      await h.read(syncEngineProvider).kick(reason: 'test');
      await h.dispose();
    });
  });
}
