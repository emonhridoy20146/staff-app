import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/core/format/digits.dart';
import 'package:staff_app/core/settings/ui_prefs.dart';
import 'package:staff_app/features/cash/src/cash.dart';
import 'package:staff_app/features/cash/src/deposit_rules.dart';
import 'package:staff_app/l10n/app_localizations.dart';

/// FR-M-059: the confirm before a deposit says what goes, that it goes to the ERP as payments and
/// that it cannot be changed or deleted afterwards; in Bangla (default) and English, online and offline.
void main() {
  const plan = DepositPlan(cashPoisha: 820000, cashCount: 2, nonCashPoisha: 120000, nonCashCount: 1);

  /// Opens the confirm; the returned record holds the answer once the dialog closes.
  Future<List<bool?>> open(WidgetTester t, {required String lang, required bool online, Uint8List? slip}) async {
    final fmt = Fmt(lang, lang == 'bn' ? DigitStyle.bangla : DigitStyle.latin);
    final answers = <bool?>[];
    await t.pumpWidget(ProviderScope(
      overrides: [fmtProvider.overrideWithValue(fmt)],
      child: MaterialApp(
        locale: Locale(lang),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (c) => Scaffold(
            body: TextButton(
              onPressed: () async => answers.add(await showDialog<bool>(context: c, builder: (_) => DepositConfirmDialog(plan: plan, online: online, slip: slip))),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    return answers;
  }

  testWidgets('Bangla, online: amounts, count, "ইআরপিতে পেমেন্ট", cannot be changed; জমা দিন confirms', (t) async {
    final answers = await open(t, lang: 'bn', online: true);
    const f = Fmt('bn', DigitStyle.bangla);
    expect(find.text('জমা নিশ্চিত করুন'), findsOneWidget);
    expect(
      find.text('এই ${f.money(820000)} নগদ ও ${f.money(120000)} মোবাইল/ব্যাংক (মোট ${f.num(3)}টি আদায়) জমা দিলে অনলাইনে থাকলে সাথে সাথে ইআরপিতে পেমেন্ট হিসেবে চলে যাবে। জমার পর আর বদলানো বা মুছে ফেলা যাবে না।'),
      findsOneWidget,
    );
    expect(f.num(3), '৩');
    await t.tap(find.text('জমা দিন'));
    await t.pumpAndSettle();
    expect(find.byType(DepositConfirmDialog), findsNothing);
    expect(answers, [true]);
  });

  testWidgets('Bangla, offline: it goes as soon as the phone is online', (t) async {
    final answers = await open(t, lang: 'bn', online: false);
    expect(find.textContaining('এখন ইন্টারনেট নেই'), findsOneWidget);
    expect(find.textContaining('ফোন অনলাইনে আসার সাথে সাথে ইআরপিতে পেমেন্ট হিসেবে চলে যাবে'), findsOneWidget);
    expect(find.textContaining('জমার পর আর বদলানো বা মুছে ফেলা যাবে না'), findsOneWidget);
    await t.tap(find.text('বাতিল'));
    await t.pumpAndSettle();
    expect(answers, [false]);
  });

  testWidgets('English, online and offline', (t) async {
    final answers = await open(t, lang: 'en', online: true);
    const f = Fmt('en', DigitStyle.latin);
    expect(find.text('Confirm the deposit'), findsOneWidget);
    expect(
      find.text('Depositing ${f.money(820000)} cash and ${f.money(120000)} mobile/bank (3 collections) sends them to the ERP as payments right away when online. After the deposit they cannot be changed or deleted.'),
      findsOneWidget,
    );
    expect(find.text('Deposit'), findsOneWidget);
    await t.tap(find.text('Deposit'));
    await t.pumpAndSettle();
    expect(answers, [true]);

    await open(t, lang: 'en', online: false);
    expect(find.textContaining('as soon as the phone is online'), findsOneWidget);
  });

  testWidgets('a bank deposit shows its slip photo (FR-M-065); others show none', (t) async {
    final slip = Uint8List.fromList(img.encodeJpg(img.Image(width: 64, height: 48)));
    await open(t, lang: 'en', online: true, slip: slip);
    expect(find.text('Bank deposit slip'), findsOneWidget);
    expect(find.byType(SlipThumb), findsOneWidget);
    expect(find.bySemanticsLabel('Bank deposit slip'), findsWidgets);
    expect(find.text('The deposit is sent once its slip photo is uploaded.'), findsOneWidget);
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();

    await open(t, lang: 'bn', online: false);
    expect(find.byType(SlipThumb), findsNothing);
    expect(find.text('ব্যাংক জমা স্লিপ'), findsNothing);
  });
}
