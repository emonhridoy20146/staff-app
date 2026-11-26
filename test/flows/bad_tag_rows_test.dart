import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/core/theme/tag_colors.dart';
import 'package:staff_app/core/ui/tag_mark.dart';
import 'package:staff_app/features/customers/customers.dart';
import 'package:staff_app/features/customers/src/customer_providers.dart' show customerSortProvider;
import 'package:staff_app/features/customers/src/domain/customer.dart' show CustomerSort;

import 'helpers.dart';

/// FR-M-081 (owner request 2026-11-26): a bad-tag customer's row sits in the frame of its tag kind, with the
/// kind's icon and word on the frame; the customer page header and the tag sheet use the same colours.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 8}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  final runawayAt = DateTime.utc(2026, 11, 14, 6);

  /// The first four customers by name: A tagged bad "refuses to pay", B plain, C a watch tag (reason absconded),
  /// D not tagged but the latest visit says runaway.
  Future<(Harness, List<CustomerRow>)> start(WidgetTester t) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 1800) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    final db = h.read(databaseProvider);
    // Seeded before the app starts: a write while the start-up sync holds the database would wait forever.
    final rows = await t.runAsync(() async {
      final four = (await (db.select(db.customers)..orderBy([(c) => OrderingTerm.asc(c.nameBn)])).get()).take(4).toList();
      Future<void> set(CustomerRow c, CustomersCompanion v) => (db.update(db.customers)..where((x) => x.serverId.equals(c.serverId))).write(v);
      await set(four[0], const CustomersCompanion(tagState: Value('tagged'), tagSeverity: Value('bad'), tagReasonCode: Value('refused_to_pay'), tagReason: Value('{"reason":"বারবার বলার পরও দেননি","setBy":"ম্যানেজার"}')));
      await set(four[2], const CustomersCompanion(tagState: Value('tagged'), tagSeverity: Value('watch'), tagReasonCode: Value('absconded')));
      await db.into(db.visits).insert(VisitsCompanion.insert(clientId: 'v-run', customerId: four[3].serverId, checkInAt: runawayAt, outcome: 'runaway', syncState: const Value('synced')));
      await set(four[3], CustomersCompanion(lastVisitAt: Value(runawayAt)));
      return four;
    });
    h.read(customerSortProvider.notifier).state = CustomerSort.name;
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t, rounds: 12);
    return (h, rows!);
  }

  testWidgets('customer rows: frame in the kind colour with icon and word; plain and watch rows have none; one content column', (t) async {
    final (h, c) = await start(t);
    // The data path: the pull stored the server's reason code, and the query found the latest visit.
    final all = await t.runAsync(() => h.read(customerRepositoryProvider).watchAll().first);
    Customer of(String id) => all!.firstWhere((x) => x.id == id);
    expect(of('c-1015').row.tagReasonCode, 'long_overdue'); // the demo server's tag, a code this app does not know
    expect(of('c-1015').badTag, const BadTag(TagKind.other, BadTagSource.tag));
    expect(of(c[0].serverId).badTag, const BadTag(TagKind.refusedToPay, BadTagSource.tag));
    expect(of(c[1].serverId).badTag, isNull);
    expect(of(c[2].serverId).badTag, isNull);
    expect(of(c[3].serverId).badTag, const BadTag(TagKind.absconded, BadTagSource.visit));

    await t.tap(find.text('গ্রাহক').last);
    await settle(t);
    Finder row(CustomerRow r) => find.widgetWithText(CustomerWorkRow, r.nameBn);
    Finder frame(CustomerRow r) => find.descendant(of: row(r), matching: find.byKey(const Key('tag-frame')));
    BorderSide side(CustomerRow r) => ((t.widget<DecoratedBox>(frame(r)).decoration as BoxDecoration).border! as Border).top;
    TagChip chip(CustomerRow r) => t.widget<TagChip>(find.descendant(of: row(r), matching: find.byType(TagChip)));
    double nameLeft(CustomerRow r) => t.getTopLeft(find.descendant(of: row(r), matching: find.byKey(const Key('work-row-name')))).dx;

    // A: a tag reason has its own colour, 1.5 dp, with icon and word (never colour alone).
    expect(frame(c[0]), findsOneWidget);
    expect(side(c[0]).color, TagColors.light.of(TagKind.refusedToPay).fg);
    expect(side(c[0]).width, 1.5);
    expect(find.descendant(of: row(c[0]), matching: find.text('দিতে অস্বীকার')), findsOneWidget);
    expect(find.descendant(of: row(c[0]), matching: find.byIcon(tagKindIcon(TagKind.refusedToPay))), findsOneWidget);
    expect(chip(c[0]).semanticsLabel, 'খারাপ ট্যাগ: দিতে অস্বীকার');
    // B plain, C watch: no frame.
    expect(frame(c[1]), findsNothing);
    expect(frame(c[2]), findsNothing);
    // D: the latest visit says runaway: the strongest look (2 dp, filled chip), and it says where it comes from.
    expect(side(c[3]).color, TagColors.light.of(TagKind.absconded).fg);
    expect(side(c[3]).width, 2.0);
    expect(find.descendant(of: row(c[3]), matching: find.text('পলাতক')), findsOneWidget);
    expect(chip(c[3]).semanticsLabel, 'শেষ ভিজিটে পলাতক');
    // The frame is inside the row; names stay in one column.
    expect(nameLeft(c[0]), moreOrLessEquals(nameLeft(c[1]), epsilon: 0.5));
    expect(nameLeft(c[3]), moreOrLessEquals(nameLeft(c[1]), epsilon: 0.5));
    expect(t.takeException(), isNull);
  });

  testWidgets('customer page header is framed; the tag sheet shows each reason in its colour, previews the row and saves the code', (t) async {
    final (h, c) = await start(t);
    final router = h.read(routerProvider);
    unawaited(router.push('/customers/${c[0].serverId}'));
    await settle(t);
    final header = find.byKey(const Key('detail-header-framed'));
    expect(header, findsOneWidget);
    expect(find.descendant(of: header, matching: find.text('দিতে অস্বীকার')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('detail-tag-card'), skipOffstage: false), matching: find.text('দিতে অস্বীকার · খারাপ', skipOffstage: false)), findsOneWidget);
    router.pop();
    await settle(t, rounds: 3);

    // D: no tag, but the last visit says runaway: framed, with the line that says why.
    unawaited(router.push('/customers/${c[3].serverId}'));
    await settle(t);
    expect(find.descendant(of: find.byKey(const Key('detail-header-framed')), matching: find.text('পলাতক')), findsOneWidget);
    expect(find.byKey(const Key('detail-runaway-visit'), skipOffstage: false), findsOneWidget);
    router.pop();
    await settle(t, rounds: 3);

    // B: plain header; open the tag sheet.
    unawaited(router.push('/customers/${c[1].serverId}?action=tag'));
    await settle(t);
    expect(find.byKey(const Key('detail-header-framed')), findsNothing);
    const reasons = ['plan_ended_unpaid', 'repeated_broken_promise', 'absconded', 'refused_to_pay', 'fraud_suspected', 'other'];
    for (final r in reasons) {
      final option = find.byKey(ValueKey('tag-reason-$r'));
      expect(option, findsOneWidget);
      expect(find.descendant(of: option, matching: find.byKey(ValueKey('tag-swatch-${tagKindForReason(r).name}'))), findsOneWidget);
      expect(t.getSize(option).height, greaterThanOrEqualTo(48));
    }
    expect(find.byKey(const Key('tag-preview-chip')), findsNothing);

    await t.tap(find.byKey(const ValueKey('tag-reason-fraud_suspected')));
    await settle(t, rounds: 2);
    final preview = find.byKey(const Key('tag-preview-chip'));
    expect(t.widget<TagChip>(preview).kind, TagKind.fraudSuspected);
    // Legal has its own colour on the row; a watch tag has no frame.
    await t.tap(find.text('আইনি ব্যবস্থা'));
    await settle(t, rounds: 2);
    expect(t.widget<TagChip>(preview).kind, TagKind.legal);
    await t.tap(find.text('নজরে রাখুন'));
    await settle(t, rounds: 2);
    expect(preview, findsNothing);
    expect(find.byKey(const Key('tag-preview-watch')), findsOneWidget);
    await t.tap(find.text('খারাপ'));
    await settle(t, rounds: 2);
    expect(t.widget<TagChip>(preview).kind, TagKind.fraudSuspected);

    await t.enterText(find.byType(TextField), 'ভুয়া কাগজ দিয়ে পণ্য নিয়েছেন');
    await settle(t, rounds: 2);
    await t.tap(find.widgetWithText(FilledButton, 'ট্যাগ'));
    await settle(t, rounds: 10);
    final db = h.read(databaseProvider);
    final saved = await t.runAsync(() => (db.select(db.customers)..where((x) => x.serverId.equals(c[1].serverId))).getSingle());
    expect([saved!.tagState, saved.tagSeverity, saved.tagReasonCode], ['tagged', 'bad', 'fraud_suspected']);
    // At once, offline-first: the header takes the frame of the new tag.
    expect(find.descendant(of: find.byKey(const Key('detail-header-framed')), matching: find.text('প্রতারণার সন্দেহ')), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
