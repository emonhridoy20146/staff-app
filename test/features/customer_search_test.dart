import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/api/api_models.dart' show Json;
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/sync/sync_handlers.dart';
import 'package:staff_app/core/text/search_text.dart';
import 'package:staff_app/features/customers/src/data/customer_repository.dart';
import 'package:staff_app/features/customers/src/domain/customer.dart';

/// FR-M-076 (owner request 2026-11-26): the customer page finds a customer by
/// invoice number and by mobile number, typed with or without spaces, in Bangla
/// or Latin digits. Local and offline. Fake names and numbers only.
void main() {
  const today = '2026-11-26';

  group('rules', () {
    test('normalising: Bangla digits, case and - . , / go; spaces fold', () {
      expect(normalizeSearch('S-24052'), 's24052');
      expect(normalizeSearch('  ০১৭১২   ৩৪৫৬৭৮ '), '01712 345678');
      expect(compactSearch('০১৭১২ ৩৪৫-৬৭৮'), '01712345678');
    });

    test('the stored text has the words and a space-free line, and a query cannot span the two', () {
      final t = customerSearchText(nameBn: 'রহিম মিয়া', code: 'C-1', phones: ['01712345678'], invoiceNos: ['S-24052']);
      expect(t, 'রহিম মিয়া c1 01712345678 s24052\nরহিমমিয়াc101712345678s24052');
      expect(SearchQuery('s24052 রহিম').matches(t), isFalse); // "…s24052" ends line 1, "রহিম" starts line 2
      expect(SearchQuery('').matches(t), isTrue);
    });

    test('a number added on this phone joins the words and the space-free line', () {
      final t = addToSearchText(customerSearchText(nameBn: 'করিম', phones: ['01712345678']), '01999 000111');
      expect(t, 'করিম 01712345678 01999 000111\nকরিম0171234567801999000111');
      expect(SearchQuery('01999000111').matches(t), isTrue);
    });
  });

  group('pull and search', () {
    late AppDatabase db;
    late CustomerRepository repo;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = CustomerRepository(db);
    });
    tearDown(() => db.close());

    Json plan(String id, String? invoiceNo, {String kind = 'installment', String status = 'active'}) => {
          'erpPlanId': id,
          'product': 'Fridge',
          'startDate': '2026-01-01',
          'finalDueDate': '2027-01-01',
          'installmentCount': 12,
          'totalPayablePoisha': 1200000,
          'paidPoisha': 0,
          'outstandingPoisha': status == 'closed' ? 0 : 1200000,
          'status': status,
          'kind': kind,
          'invoiceNo': ?invoiceNo,
        };

    Future<void> pull(String id, {String phone = '01712345678', List<Json>? plans}) => CustomerPullHandler(SyncHandlerRegistry.new).upsert(db, id, {
          'id': id,
          'code': 'C-$id',
          'name': {'bn': 'গ্রাহক $id', 'en': 'Customer $id'},
          'phones': [phone],
          'address': 'Kazi Para',
          'totalOutstandingPoisha': 100000,
          'plans': ?plans,
        });

    Future<List<String>> find(String q) async {
      final all = [for (final id in ['a', 'b', 'c']) (await repo.getOne(id))!];
      return applyQuery(all, today: today, search: q, sort: CustomerSort.name).map((c) => c.id).toList();
    }

    Future<void> seed() async {
      await pull('a', plans: [plan('p-1', 'S-24052'), plan('p-2', 'CR-7781', kind: 'credit')]);
      await pull('b', phone: '01811223344', plans: [plan('p-3', 'S-11870', status: 'closed'), plan('p-4', null)]);
      await pull('c', phone: '01999000111');
    }

    test('invoice number with and without the dash, any case, any kind', () async {
      await seed();
      expect(await find('S-24052'), ['a']);
      expect(await find('s24052'), ['a']);
      expect(await find('24052'), ['a']);
      expect(await find('cr-7781'), ['a']);
      expect(await find('S-99999'), isEmpty);
    });

    test('an invoice of a closed plan still finds its customer', () async {
      await seed();
      expect(await find('S-11870'), ['b']);
      expect(await find('11870'), ['b']);
    });

    test('a mobile typed with spaces or dashes, or in part', () async {
      await seed();
      expect(await find('01712 345678'), ['a']);
      expect(await find('0181 122 3344'), ['b']);
      expect(await find('01999-000111'), ['c']);
      expect(await find('3344'), ['b']);
    });

    test('a mobile in Bangla digits, with or without spaces', () async {
      await seed();
      expect(await find('০১৭১২৩৪৫৬৭৮'), ['a']);
      expect(await find('০১৮১১ ২২৩৩৪৪'), ['b']);
      expect(await find('২৪০৫২'), ['a']); // an invoice number in Bangla digits
    });

    test('names and address still match with and without spaces', () async {
      await seed();
      expect(await find('গ্রাহক b'), ['b']);
      expect(await find('customer c'), ['c']);
      expect(await find('kazipara'), ['a', 'b', 'c']);
    });

    test('a payload without plans keeps the invoice numbers the phone already holds', () async {
      await seed();
      await pull('a'); // e.g. a list change without the embedded plans
      expect(await find('24052'), ['a']);
    });

    test('a later pull drops an invoice that is no longer on the customer', () async {
      await seed();
      await pull('a', plans: [plan('p-2', 'CR-7781', kind: 'credit')]);
      expect(await find('24052'), isEmpty);
      expect(await find('7781'), ['a']);
    });

    test('re-indexing an old row adds its invoice numbers and the space-free line, keeping pending numbers', () async {
      await seed();
      // as 0.x left it: words only, no invoices; a number added here and not yet sent
      await db.customStatement(
          "UPDATE customers SET search_text = 'গ্রাহক b customer b cb 01811223344 kazi para', "
          "phones_json = '[\"01811223344\",{\"n\":\"01700111222\",\"s\":\"f\",\"p\":true}]' WHERE server_id = 'b'");
      expect(await find('11870'), isEmpty);
      expect(await find('kazipara'), ['a', 'c']); // b has no space-free line yet
      await db.reindexCustomerSearch();
      expect(await find('kazipara'), ['a', 'b', 'c']);
      expect(await find('11870'), ['b']);
      expect(await find('01811 223344'), ['b']);
      expect(await find('01700 111222'), ['b']);
      expect((await repo.getOne('b'))!.row.phonesJson, contains('"p":true'));
    });
  });
}
