import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/features/customers/customers.dart';
import 'package:staff_app/features/customers/src/domain/customer.dart' show LastVisit;
import 'package:staff_app/features/today/today.dart';

/// FR-M-082 / FR-M-083: what the Home filters hold and count, whose customers they cover, and how many quick
/// actions the grid shows. Pure rules over the phone's own rows.
void main() {
  const today = '2026-11-15';
  const me = 'u-me';
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<Customer> c(String id, {String? assignee = me, int days = 0, bool due = false, bool promised = false, String tag = 'none', String? severity, String? code, int? dist, LastVisit? visit}) async {
    await db.into(db.customers).insert(CustomersCompanion.insert(
          serverId: id,
          code: id,
          nameBn: id,
          assigneeId: Value(assignee),
          daysOverdue: Value(days),
          overdue: Value(days > 0),
          dueToday: Value(due),
          openPromiseDate: Value(promised ? today : null),
          tagState: Value(tag),
          tagSeverity: Value(severity),
          tagReasonCode: Value(code),
          lastVisitAt: Value(visit?.at),
        ));
    final row = await (db.select(db.customers)..where((t) => t.serverId.equals(id))).getSingle();
    return Customer(row, distanceM: dist, lastVisit: visit);
  }

  List<String> ids(List<Customer> l) => [for (final x in l) x.id];

  test('the first four filters are the work list: three disjoint groups, All is their sum, counts are the rows', () async {
    final all = [
      await c('p1', promised: true, days: 40, dist: 900), // promised wins over overdue
      await c('p2', promised: true, due: true, dist: 100),
      await c('d1', due: true, days: 10, dist: 300), // due wins over overdue
      await c('o1', days: 5, dist: 700),
      await c('o2', days: 90, dist: 200),
      await c('ok', dist: 50), // nothing to do today
    ];
    final w = homeWorkOf(all, today, scopeUserId: me);
    expect(ids(w.listOf(HomeFilter.promised)), ['p2', 'p1']); // nearest first
    expect(ids(w.listOf(HomeFilter.due)), ['d1']);
    expect(ids(w.listOf(HomeFilter.overdue)), ['o2', 'o1']);
    expect(ids(w.listOf(HomeFilter.all)), ['p2', 'p1', 'd1', 'o2', 'o1']);
    for (final f in HomeFilter.values) {
      expect(w.count(f), w.listOf(f).length, reason: f.name);
    }
    expect(w.count(HomeFilter.all), w.count(HomeFilter.promised) + w.count(HomeFilter.due) + w.count(HomeFilter.overdue));
    // The same groups as the sections and the summary card (one rule).
    final p = prioritize(all, today, myUserId: me);
    expect([ids(p.promised), ids(p.due), ids(p.overdue)], [ids(w.priorities.promised), ids(w.priorities.due), ids(w.priorities.overdue)]);
  });

  test('scope: a field staff member gets their own and unassigned customers; a branch user gets everyone in view', () async {
    final all = [
      await c('mine', days: 3),
      await c('nobody', assignee: null, days: 3),
      await c('colleague', assignee: 'u-other', days: 3, tag: 'tagged', severity: 'bad', code: 'absconded'),
    ];
    final staff = homeWorkOf(all, today, scopeUserId: me, brokenPromiseCustomerIds: {'colleague', 'mine'});
    expect(ids(staff.listOf(HomeFilter.overdue)).toSet(), {'mine', 'nobody'});
    expect(ids(staff.badTag), isEmpty);
    expect(ids(staff.brokenPromise), ['mine']);

    final branch = homeWorkOf(all, today, scopeUserId: null, brokenPromiseCustomerIds: {'colleague', 'mine'});
    expect(ids(branch.listOf(HomeFilter.overdue)).toSet(), {'mine', 'nobody', 'colleague'});
    expect(ids(branch.badTag), ['colleague']);
    expect(ids(branch.brokenPromise).toSet(), {'mine', 'colleague'});
  });

  test('Bad tag is a lens over the whole scope: bad and legal tags and runaway visits, not watch tags; nearest first', () async {
    final at = DateTime.utc(2026, 11, 14, 6);
    final all = [
      await c('far-overdue', days: 30, dist: 5000, tag: 'tagged', severity: 'bad', code: 'refused_to_pay'),
      await c('near-current', dist: 100, tag: 'tagged', severity: 'legal', code: 'other'), // not in the work list at all
      await c('watch', days: 9, dist: 10, tag: 'tagged', severity: 'watch', code: 'absconded'),
      await c('runaway', dist: 400, visit: (outcome: 'runaway', at: at)),
      await c('plain', days: 2, dist: 1),
    ];
    final w = homeWorkOf(all, today, scopeUserId: me);
    expect(ids(w.badTag), ['near-current', 'runaway', 'far-overdue']);
    expect(w.count(HomeFilter.badTag), 3);
    // It overlaps the work list, it does not move anyone out of it.
    expect(ids(w.listOf(HomeFilter.overdue)).toSet(), {'far-overdue', 'watch', 'plain'});
  });

  test('Broken promise lists the customers named, in scope, nearest first; none named is an empty list', () async {
    final all = [await c('a', dist: 300), await c('b', dist: 20, days: 4), await c('z')];
    expect(ids(homeWorkOf(all, today, scopeUserId: me, brokenPromiseCustomerIds: {'a', 'b', 'gone'}).brokenPromise), ['b', 'a']);
    expect(homeWorkOf(all, today, scopeUserId: me).brokenPromise, isEmpty);
    expect(HomeWork.empty.count(HomeFilter.all), 0);
  });

  test('the quick-action grid shows full rows of three: 9, 6 or 3; with fewer than three, what there is', () {
    expect([for (var n = 0; n <= 13; n++) quickGridCount(n)], [0, 1, 2, 3, 3, 3, 6, 6, 6, 9, 9, 9, 9, 9]);
  });
}
