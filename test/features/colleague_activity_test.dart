import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/db/colleague_activity.dart';
import 'package:staff_app/features/today/src/team_activity.dart';
import 'package:staff_app/features/collections/src/data/collection_repository.dart';
import 'package:staff_app/features/customers/src/pin_correction.dart';
import 'package:staff_app/features/promises/src/promises.dart';
import 'package:staff_app/features/visits/src/visits.dart';

/// FR-M-057: a colleague's visit, promise or collection carries their name and
/// never lands in the user's own tables (so Today, cash and reminders stay mine).
void main() {
  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await saveUserId(db, 'me');
  });
  tearDown(() => db.close());

  test('a colleague visit goes to the colleague table with the name; my own visit stays in visits', () async {
    final h = VisitPullHandler();
    await h.upsert(db, 'v-1', {'clientId': 'cv-1', 'customerId': 'c-1', 'userId': 'sara', 'userName': 'Sara', 'checkInAt': '2026-11-20T05:00:00Z', 'outcome': 'not_home'});
    await h.upsert(db, 'v-2', {'clientId': 'cv-2', 'customerId': 'c-1', 'userId': 'me', 'checkInAt': '2026-11-20T06:00:00Z', 'outcome': 'paid'});
    final others = await db.select(db.colleagueActivities).get();
    expect(others.single.id, 'visit:v-1');
    expect([others.single.staffName, others.single.outcome], ['Sara', 'not_home']);
    final own = await db.select(db.visits).get();
    expect(own.single.clientId, 'cv-2');
    expect(own.single.userName, isNull);
  });

  test('a joint visit I took part in stays mine even when a partner recorded it', () async {
    await VisitPullHandler().upsert(db, 'v-3', {
      'clientId': 'cv-3',
      'customerId': 'c-1',
      'userId': 'sara',
      'checkInAt': '2026-11-20T05:00:00Z',
      'outcome': 'paid',
      'coWork': {'sessionId': 's-1', 'participantIds': ['sara', 'me']},
    });
    expect(await db.select(db.colleagueActivities).get(), isEmpty);
    expect((await db.select(db.visits).get()).single.clientId, 'cv-3');
  });

  test('a colleague promise is kept apart; my promise is saved as before', () async {
    final h = PromisePullHandler();
    await h.upsert(db, 'p-1', {'clientId': 'cp-1', 'customerId': 'c-1', 'ownerId': 'sara', 'createdBy': 'sara', 'createdByName': 'Sara', 'promisedDate': '2026-11-25', 'promisedAmountPoisha': 250000, 'status': 'open', 'createdAt': '2026-11-20T05:00:00Z'});
    await h.upsert(db, 'p-2', {'clientId': 'cp-2', 'customerId': 'c-1', 'ownerId': 'me', 'createdBy': 'me', 'promisedDate': '2026-11-26', 'promisedAmountPoisha': 100000, 'status': 'open', 'createdAt': '2026-11-20T06:00:00Z'});
    final other = (await db.select(db.colleagueActivities).get()).single;
    expect([other.id, other.staffName, other.amountPoisha, other.promisedDate], ['promise:p-1', 'Sara', 250000, '2026-11-25']);
    expect((await db.select(db.promises).get()).single.clientId, 'cp-2');
    await h.delete(db, 'p-1');
    expect(await db.select(db.colleagueActivities).get(), isEmpty);
  });

  test('a colleague collection is kept apart and never touches my collections', () async {
    await CollectionPullHandler().upsert(db, 'k-1', {
      'clientId': 'ck-1',
      'customer': {'id': 'c-1'},
      'collector': {'id': 'sara', 'name': 'Sara'},
      'amountPoisha': 300000,
      'method': 'cash',
      'status': 'received',
      'recordedAt': '2026-11-20T07:00:00Z',
      'receivedAt': '2026-11-20T07:00:05Z',
    });
    final other = (await db.select(db.colleagueActivities).get()).single;
    expect([other.id, other.staffName, other.amountPoisha, other.method], ['collection:k-1', 'Sara', 300000, 'cash']);
    expect(await db.select(db.collections).get(), isEmpty);
  });

  test('a promise a colleague made on a customer assigned to me stays mine (to follow up) and says who made it', () async {
    await PromisePullHandler().upsert(db, 'p-4', {'clientId': 'cp-4', 'customerId': 'c-1', 'ownerId': 'me', 'createdBy': 'sara', 'createdByName': 'Sara', 'promisedDate': '2026-11-25', 'promisedAmountPoisha': 5, 'createdAt': '2026-11-20T05:00:00Z'});
    expect(await db.select(db.colleagueActivities).get(), isEmpty);
    expect((await db.select(db.promises).get()).single.createdByName, 'Sara');
  });

  test('a colleague pin goes to the colleague table with the proposer; my own pin proposal stays in my proposals', () async {
    final h = LocationProposalPullHandler();
    await h.upsert(db, 'l-1', {'clientId': 'cl-1', 'customerId': 'c-1', 'status': 'approved', 'lat': 22.7, 'lng': 90.3, 'createdAt': '2026-11-20T05:00:00Z', 'proposer': {'id': 'sara', 'name': 'Sara'}});
    await db.into(db.locationProposals).insert(LocationProposalsCompanion.insert(clientId: 'cl-2', customerId: 'c-1', lat: 22.7, lng: 90.3, accuracyM: 5));
    await h.upsert(db, 'l-2', {'clientId': 'cl-2', 'customerId': 'c-1', 'status': 'rejected', 'decisionReason': 'too far', 'proposer': {'id': 'me', 'name': 'Me'}});
    final other = (await db.select(db.colleagueActivities).get()).single;
    expect([other.id, other.kind, other.staffName, other.status], ['pin:l-1', 'pin', 'Sara', 'approved']);
    final own = (await db.select(db.locationProposals).get()).single;
    expect([own.clientId, own.status, own.decisionReason], ['cl-2', 'rejected', 'too far']);
  });

  test('the team list of a day holds only that Dhaka day, latest first', () async {
    // 2026-11-20 in Dhaka runs from 2026-11-19 18:00 UTC to 2026-11-20 18:00 UTC.
    await upsertColleagueActivity(db, kind: 'visit', serverId: 'a', customerId: 'c-1', staffId: 'sara', staffName: 'Sara', at: DateTime.utc(2026, 11, 19, 17, 59), outcome: 'paid');
    await upsertColleagueActivity(db, kind: 'visit', serverId: 'b', customerId: 'c-1', staffId: 'sara', staffName: 'Sara', at: DateTime.utc(2026, 11, 19, 18, 1), outcome: 'paid');
    await upsertColleagueActivity(db, kind: 'collection', serverId: 'c', customerId: 'c-2', staffId: 'rafi', staffName: 'Rafi', at: DateTime.utc(2026, 11, 20, 9), amountPoisha: 100);
    await upsertColleagueActivity(db, kind: 'promise', serverId: 'd', customerId: 'c-2', staffId: 'rafi', staffName: 'Rafi', at: DateTime.utc(2026, 11, 20, 18, 1));
    final rows = await teamActivityOn(db, '2026-11-20').get();
    expect(rows.map((r) => r.id), ['collection:c', 'visit:b']);
  });

  test('who voided a collection is kept: my own line and a colleague line', () async {
    await db.into(db.collections).insert(CollectionsCompanion.insert(
      clientId: 'ck-9',
      customerId: 'c-1',
      customerName: 'A',
      customerCode: 'C1',
      amountPoisha: 100,
      method: 'cash',
      receiptNo: 'R-9',
      recordedAt: DateTime.utc(2026, 11, 20),
      deviceTime: DateTime.utc(2026, 11, 20),
      businessDate: '2026-11-20',
    ));
    final h = CollectionPullHandler();
    await h.upsert(db, 'k-9', {
      'clientId': 'ck-9',
      'customer': {'id': 'c-1'},
      'collector': {'id': 'me', 'name': 'Me'},
      'status': 'voided',
      'voided': {'kind': 'admin', 'byName': 'Manager', 'reason': 'wrong customer'},
      'edited': {'previousAmountPoisha': 250},
    });
    final own = (await db.select(db.collections).get()).single;
    expect([own.status, own.voidedKind, own.voidedByName, own.voidedReason, own.previousAmountPoisha], ['voided', 'admin', 'Manager', 'wrong customer', 250]);
    await h.upsert(db, 'k-10', {
      'clientId': 'ck-10',
      'customer': {'id': 'c-1'},
      'collector': {'id': 'sara', 'name': 'Sara'},
      'amountPoisha': 5,
      'status': 'voided',
      'voided': {'kind': 'withdrawn'},
      'recordedAt': '2026-11-20T07:00:00Z',
    });
    final other = (await db.select(db.colleagueActivities).get()).single;
    expect([other.id, other.status, other.voidedKind], ['collection:k-10', 'voided', 'withdrawn']);
  });

  test('until the user id is saved every record is treated as mine (old behaviour)', () async {
    await db.delete(db.kvSettings).go();
    await PromisePullHandler().upsert(db, 'p-3', {'clientId': 'cp-3', 'customerId': 'c-1', 'ownerId': 'sara', 'promisedDate': '2026-11-25', 'promisedAmountPoisha': 1, 'createdAt': '2026-11-20T05:00:00Z'});
    expect(await db.select(db.colleagueActivities).get(), isEmpty);
    expect(await db.select(db.promises).get(), hasLength(1));
  });
}
