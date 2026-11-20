import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/sync/sync_handlers.dart';
import 'package:staff_app/features/customers/src/data/customer_repository.dart';
import 'package:staff_app/features/customers/src/domain/customer.dart';

/// Contract 1.19.0 (field-api ADR-038, FR-M-032): the phone holds every
/// customer of the staff member's branches; assignment still marks their own
/// work. Fake names only.
void main() {
  const today = '2026-11-19';
  late AppDatabase db;
  late CustomerRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CustomerRepository(db);
  });
  tearDown(() => db.close());

  Future<void> pull(String id, {String? assignee, String? assigneeName, String branch = 'br-1', String branchCode = 'BRL01', String? branchBn = 'বরিশাল সদর', int daysOverdue = 0, bool dueToday = false}) =>
      CustomerPullHandler(SyncHandlerRegistry.new).upsert(db, id, {
        'id': id,
        'code': 'C-$id',
        'name': {'bn': 'গ্রাহক $id', 'en': 'Customer $id'},
        'branchId': branch,
        'branch': {'id': branch, 'code': branchCode, 'name': {'bn': branchBn, 'en': 'Branch $branchCode'}},
        if (assignee != null) 'assignee': {'id': assignee, 'name': assigneeName ?? assignee},
        'totalOutstandingPoisha': 100000,
        'daysOverdue': daysOverdue,
        'badges': [if (dueToday) 'due_today', if (daysOverdue > 0) 'overdue'],
      });

  test('the pull keeps branch and assignee name; branch name falls back to the code', () async {
    await pull('a', assignee: 'u-2', assigneeName: 'Test Colleague');
    await pull('b', branch: 'br-2', branchCode: 'PTK01', branchBn: null);
    final a = (await repo.getOne('a'))!;
    expect(a.branchId, 'br-1');
    expect(a.branchName('bn'), 'বরিশাল সদর');
    expect(a.branchName('en'), 'Branch BRL01');
    expect(a.assigneeName, 'Test Colleague');
    final b = (await repo.getOne('b'))!;
    expect(b.branchName('bn'), 'Branch PTK01');
    expect(b.row.assigneeId, isNull);
  });

  test('a branch picked in the top bar narrows the customers; none picked shows all (FR-M-045)', () async {
    await pull('a', dueToday: true);
    await pull('b', branch: 'br-2', branchCode: 'ULN01', dueToday: true);
    await pull('c', branch: 'br-2', branchCode: 'ULN01');
    final all = await repo.watchAll().first;

    expect(inBranch(all, null).map((c) => c.id).toSet(), {'a', 'b', 'c'});
    expect(inBranch(all, 'br-2').map((c) => c.id).toSet(), {'b', 'c'});
    expect(inBranch(all, 'br-9'), isEmpty);
    // Today follows the same pick
    expect(prioritize(inBranch(all, 'br-1'), today).due.map((c) => c.id), ['a']);
  });

  test("Today lists own and unassigned customers, never a colleague's; Mine narrows the list", () async {
    await pull('mine', assignee: 'me', dueToday: true);
    await pull('free', daysOverdue: 3);
    await pull('theirs', assignee: 'u-2', dueToday: true);
    final all = await repo.watchAll().first;

    final p = prioritize(all, today, myUserId: 'me');
    expect(p.due.map((c) => c.id), ['mine']);
    expect(p.overdue.map((c) => c.id), ['free']);
    // no signed-in user known: everything counts (old behaviour)
    expect(prioritize(all, today).due.map((c) => c.id).toSet(), {'mine', 'theirs'});

    final theirs = all.firstWhere((c) => c.id == 'theirs');
    expect(theirs.isOthers('me'), isTrue);
    expect(theirs.isMine('me'), isFalse);
    expect(all.firstWhere((c) => c.id == 'free').isOthers('me'), isFalse);
    expect(applyQuery(all, today: today, filter: CustomerFilter.mine, myUserId: 'me').map((c) => c.id), ['mine']);
    expect(applyQuery(all, today: today, myUserId: 'me'), hasLength(3));
  });

  test('a colleague taking over a customer keeps it on the phone with the new owner', () async {
    await pull('x', assignee: 'me');
    await pull('x', assignee: 'u-2', assigneeName: 'Test Colleague');
    final x = (await repo.getOne('x'))!;
    expect(x.row.assigneeId, 'u-2');
    expect(x.isOthers('me'), isTrue);
    expect(await repo.watchAll().first, hasLength(1));
  });
}
