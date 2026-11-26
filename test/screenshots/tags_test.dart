@Tags(['screenshots'])
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/customers/customers.dart';
import 'package:staff_app/features/map/src/map_screen.dart' show mapListModeProvider;
import 'package:staff_app/features/today/today.dart';
import 'package:staff_app/l10n/app_localizations.dart';

import '../flows/helpers.dart';
import 'shot_helpers.dart';

/// Bad-tag customers (FR-M-081) in every place a customer row appears, and the tag sheet.
/// Regenerate: `flutter test --tags screenshots --update-goldens`.
///
/// The tags are written into the test's own database (one customer per kind); the app's sample data is not
/// changed. The sample server itself tags one customer with a code the app does not know: the generic kind.
Future<void> seedTags(Harness h) async {
  final db = h.read(databaseProvider);
  Future<void> tag(String id, String severity, String code, String reason) => (db.update(db.customers)..where((c) => c.serverId.equals(id)))
      .write(CustomersCompanion(tagState: const Value('tagged'), tagSeverity: Value(severity), tagReasonCode: Value(code), tagReason: Value('{"reason":"$reason","setBy":"ম্যানেজার"}')));
  await tag('c-1013', 'bad', 'absconded', 'বাড়ি ছেড়ে চলে গেছেন, ফোন বন্ধ');
  await tag('c-1017', 'bad', 'refused_to_pay', 'বারবার বলার পরও দিতে চান না');
  await tag('c-1018', 'legal', 'refused_to_pay', 'উকিল নোটিশ পাঠানো হয়েছে');
  await tag('c-1020', 'bad', 'fraud_suspected', 'ভুয়া ঠিকানা দিয়েছিলেন');
  await tag('c-1022', 'bad', 'repeated_broken_promise', 'চারবার কথা দিয়ে রাখেননি');
  await tag('c-1024', 'bad', 'plan_ended_unpaid', 'মেয়াদ শেষ, টাকা বাকি');
}

void main() {
  setUpAll(loadShotFonts);

  const phone = Size(412, 1500);

  /// Home with the Bad tag filter picked, scrolled so the chips sit at the top.
  Future<void> homeBadTags(WidgetTester t, String name, {bool dark = false, String lang = 'bn', Size size = phone, double textScale = 1.0}) async {
    final h = await readyShot(t, size: size, dark: dark, lang: lang, textScale: textScale, setup: seedTags);
    h.read(homeFilterProvider.notifier).pick(HomeFilter.badTag);
    await takeShot(t, h, name, go: '/today', then: () async {
      // The title can be below the first screen (small phone, large text): look off stage too.
      await Scrollable.ensureVisible(t.element(find.text(lookupAppLocalizations(Locale(lang)).homeWorkListTitle, skipOffstage: false)));
    });
  }

  testWidgets('home bad-tag filter bn light', (t) => homeBadTags(t, 'tags/home-bad-tags-bn-light'));
  testWidgets('home bad-tag filter bn dark', (t) => homeBadTags(t, 'tags/home-bad-tags-bn-dark', dark: true));
  testWidgets('home bad-tag filter en 360dp text 1.3', (t) => homeBadTags(t, 'tags/home-bad-tags-en-360-scale130', lang: 'en', size: const Size(360, 1500), textScale: 1.3));

  testWidgets('customers list, tagged', (t) async {
    final h = await readyShot(t, size: phone, setup: seedTags);
    h.read(customerFilterProvider.notifier).state = CustomerFilter.tagged;
    await takeShot(t, h, 'tags/customers-tagged-bn-light', go: '/customers');
  });
  testWidgets('map list', (t) async {
    final h = await readyShot(t, size: phone, setup: seedTags);
    h.read(mapListModeProvider.notifier).state = true;
    await takeShot(t, h, 'tags/map-list-bn-light', go: '/map');
  });
  testWidgets('customer header bn light', (t) async => takeShot(t, await readyShot(t, setup: seedTags), 'tags/customer-header-bn-light', go: '/customers/c-1013'));
  testWidgets('customer header en dark', (t) async => takeShot(t, await readyShot(t, lang: 'en', dark: true, setup: seedTags), 'tags/customer-header-en-dark', go: '/customers/c-1018'));
  testWidgets('tag sheet', (t) async {
    final h = await readyShot(t, size: const Size(412, 1100));
    await takeShot(t, h, 'tags/tag-sheet-bn-light', go: '/customers/c-1002?action=tag', then: () async {
      await t.tap(find.byKey(const ValueKey('tag-reason-absconded')));
    });
  });
}
