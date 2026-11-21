import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';

/// The signed-in user's id as saved at sign-in (`my_user_id`), so a pull
/// handler can tell the user's own record from a colleague's. Null on a phone
/// that has not signed in since this was added: handlers then keep the old
/// behaviour (every record is treated as the user's own).
Future<String?> savedUserId(AppDatabase db) async {
  final raw = await db.kvGet('my_user_id');
  return raw == null ? null : jsonDecode(raw) as String?;
}

Future<void> saveUserId(AppDatabase db, String id) => db.kvSet('my_user_id', jsonEncode(id));

/// True when the record was made by somebody else (and the user is no partner of it).
bool isColleague({required String? me, required String? staffId}) => me != null && staffId != null && staffId != me;

Future<void> upsertColleagueActivity(
  AppDatabase db, {
  required String kind,
  required String serverId,
  required String customerId,
  required String staffId,
  required String staffName,
  required DateTime at,
  String? outcome,
  int? amountPoisha,
  String? method,
  String? promisedDate,
  String? status,
  String? note,
  String? voidedKind,
}) =>
    db.into(db.colleagueActivities).insertOnConflictUpdate(ColleagueActivitiesCompanion.insert(
          id: '$kind:$serverId',
          kind: kind,
          customerId: customerId,
          staffId: staffId,
          staffName: Value(staffName),
          at: at,
          outcome: Value(outcome),
          amountPoisha: Value(amountPoisha),
          method: Value(method),
          promisedDate: Value(promisedDate),
          status: Value(status),
          note: Value(note),
          voidedKind: Value(voidedKind),
        ));

Future<void> deleteColleagueActivity(AppDatabase db, String kind, String serverId) =>
    (db.delete(db.colleagueActivities)..where((t) => t.id.equals('$kind:$serverId'))).go();

Stream<List<ColleagueActivityRow>> watchColleagueActivities(AppDatabase db, String customerId, String kind) =>
    (db.select(db.colleagueActivities)
          ..where((t) => t.customerId.equals(customerId) & t.kind.equals(kind))
          ..orderBy([(t) => OrderingTerm.desc(t.at)]))
        .watch();

/// Latest value of two streams together (emits once both have a value).
Stream<R> combineLatest2<A, B, R>(Stream<A> a, Stream<B> b, R Function(A, B) f) {
  late StreamController<R> c;
  StreamSubscription<A>? sa;
  StreamSubscription<B>? sb;
  A? la;
  B? lb;
  var hasA = false, hasB = false;
  void emit() {
    if (hasA && hasB) c.add(f(la as A, lb as B));
  }

  c = StreamController<R>(
    onListen: () {
      sa = a.listen((v) {
        la = v;
        hasA = true;
        emit();
      }, onError: c.addError);
      sb = b.listen((v) {
        lb = v;
        hasB = true;
        emit();
      }, onError: c.addError);
    },
    onCancel: () async {
      await sa?.cancel();
      await sb?.cancel();
    },
  );
  return c.stream;
}
