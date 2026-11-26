import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/api/api_models.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/sync/sync_handlers.dart';
import '../../../../core/text/search_text.dart';
import '../domain/customer.dart';
import '../domain/month_people.dart';
import '../domain/phones.dart';
import '../domain/schedule.dart';
import '../domain/work_marks.dart';

/// Pull handler for `customer` changes. Payload = contract `CustomerDetail`.
///
/// Embedded `recentNotes` and `openPromise` are forwarded to the `note` /
/// `promise` handlers of their own features through the registry, so this
/// feature never writes another feature's tables.
class CustomerPullHandler implements PullHandler {
  CustomerPullHandler(this._registry);
  final SyncHandlerRegistry Function() _registry;

  @override
  String get entity => 'customer';

  @override
  Future<void> upsert(AppDatabase db, String id, Json d) async {
    final name = I18nText.fromJson(d['name']);
    final loc = (d['location'] as Json?) ?? const {};
    final tag = (d['tag'] as Json?) ?? const {};
    final promise = d['openPromise'] as Json?;
    final branch = (d['branch'] as Json?) ?? const {};
    final branchName = branch['name'] == null ? null : I18nText.fromJson(branch['name']);
    final assignee = d['assignee'] as Json?;
    final badges = ((d['badges'] as List?) ?? const []).cast<String>();

    // Keep locally-recorded pending amounts until the server confirms them.
    final existing = await (db.select(db.customers)..where((t) => t.serverId.equals(id))).getSingleOrNull();
    // 1.23.0 (FR-M-037): ERP numbers and added ones; a number typed on this phone and not yet sent stays in the list.
    final phoneList = keepPending(phonesFromServer(d), existing == null ? const [] : decodePhones(existing.phonesJson));
    final phones = [for (final p in phoneList) p.number];
    // FR-CUS-023, FR-M-080 (1.50.0, ADR-M43): invoices returned in the ERP are never shown. `returnedPlanIds` lists the
    // ones to delete; its presence marks a ≥1.50 server, whose `plans` is the complete list, so `plans: []`
    // clears them. An older server omits the key: a payload with no plans (missing or empty) keeps ours.
    final returned = ((d['returnedPlanIds'] as List?) ?? const []).whereType<String>().toSet();
    final payloadPlans = [
      for (final p in ((d['plans'] as List?) ?? const []).cast<Json>())
        if (!returned.contains(p['erpPlanId'])) p,
    ];
    final replacePlans = d.containsKey('returnedPlanIds') ? d['plans'] is List : payloadPlans.isNotEmpty;
    final storedPlans = await (db.select(db.plans)..where((t) => t.customerId.equals(id))).get();
    // FR-M-076: every invoice number of the customer's plans (all kinds, open or closed); kept plans are read
    // from the table. A returned invoice's number is never in it.
    final invoiceNos = replacePlans
        ? [for (final p in payloadPlans) if (p['invoiceNo'] is String) p['invoiceNo'] as String]
        : [
            for (final p in storedPlans)
              if (p.invoiceNo != null && !returned.contains(p.erpPlanId)) p.invoiceNo!,
          ];
    final search = customerSearchText(
      nameBn: name.bn,
      nameEn: name.en,
      code: d['code'] as String?,
      phones: phones,
      address: d['address'] as String?,
      invoiceNos: invoiceNos,
    );
    final serverPending = (d['pendingFieldPoisha'] as num?)?.toInt() ?? 0;

    await db.into(db.customers).insertOnConflictUpdate(
          CustomersCompanion.insert(
            serverId: id,
            erpCustomerId: Value(d['erpCustomerId'] as String?),
            code: (d['code'] as String?) ?? id,
            nameBn: name.bn,
            nameEn: Value(name.en),
            phonesJson: Value(encodePhones(phoneList)),
            address: Value(d['address'] as String?),
            areaId: Value(d['areaId'] as String?),
            areaName: Value(d['areaName'] as String?),
            lat: Value((loc['lat'] as num?)?.toDouble()),
            lng: Value((loc['lng'] as num?)?.toDouble()),
            locationStatus: Value((loc['status'] as String?) ?? (loc['lat'] == null ? 'missing' : 'ok')),
            totalOutstandingPoisha: Value((d['totalOutstandingPoisha'] as num?)?.toInt() ?? 0),
            installmentPoisha: Value((d['installmentPoisha'] as num?)?.toInt()),
            overduePoisha: Value((d['overduePoisha'] as num?)?.toInt() ?? 0),
            nextDueDate: Value(d['nextDueDate'] as String?),
            daysOverdue: Value((d['daysOverdue'] as num?)?.toInt() ?? 0),
            dueToday: Value(badges.contains('due_today')),
            overdue: Value(badges.contains('overdue')),
            badSuggested: Value(badges.contains('bad_suggested') || d['badSuggestion'] != null),
            badReasonJson: Value(d['badSuggestion'] == null ? null : jsonEncode(d['badSuggestion'])),
            tagState: Value((tag['state'] as String?) ?? 'none'),
            tagSeverity: Value(tag['severity'] as String?),
            tagReason: Value(tag['reason'] == null ? null : jsonEncode({'reason': tag['reason'], 'setBy': tag['setBy'], 'setAt': tag['setAt']})),
            lastVisitAt: Value(d['lastVisitAt'] == null ? existing?.lastVisitAt : DateTime.parse(d['lastVisitAt'] as String).toUtc()),
            openPromiseId: Value(promise?['id'] as String?),
            openPromiseDate: Value(promise?['promisedDate'] as String?),
            openPromisePoisha: Value((promise?['promisedAmountPoisha'] as num?)?.toInt()),
            pendingFieldPoisha: Value(serverPending > (existing?.pendingFieldPoisha ?? 0) ? serverPending : (existing?.pendingFieldPoisha ?? serverPending)),
            assigneeId: Value(assignee?['id'] as String?),
            assigneeName: Value(assignee?['name'] as String?),
            branchId: Value((branch['id'] ?? d['branchId']) as String?),
            branchCode: Value(branch['code'] as String?),
            branchNameBn: Value(branchName?.bn),
            branchNameEn: Value(branchName?.en),
            erpFetchedAt: Value(d['erpFetchedAt'] == null ? null : DateTime.parse(d['erpFetchedAt'] as String).toUtc()),
            guarantorJson: Value(d['guarantor'] == null ? null : jsonEncode(d['guarantor'])),
            detailedAddress: Value(d['detailedAddress'] as String?),
            directions: Value(d['directions'] as String?),
            erpRiskJson: Value(d['erpRisk'] == null ? null : jsonEncode(d['erpRisk'])),
            searchText: Value(search),
            version: Value((d['version'] as num?)?.toInt() ?? 0),
            // 1.44.0 (FR-M-068): who did this month's work. An older server sends none: keep what we had.
            activityJson: Value(encodeActivity(d) ?? existing?.activityJson),
          ),
        );

    // FR-CUS-023: only ERP-derived rows go (plans, schedule lines). Collections, outbox and media that name a
    // returned plan stay (CLAUDE.md §2.3); the server answers them with PLAN_CLOSED, shown in Problems.
    if (returned.isNotEmpty) {
      final elsewhere = await (db.select(db.plans)..where((t) => t.erpPlanId.isIn(returned) & t.customerId.equals(id).not())).get();
      await (db.delete(db.scheduleLines)..where((t) => t.erpPlanId.isIn(returned))).go();
      await (db.delete(db.plans)..where((t) => t.erpPlanId.isIn(returned))).go();
      // A returned plan held under another customer here: that customer's search text drops its number too.
      await db.reindexCustomerSearch(only: {for (final p in elsewhere) p.customerId});
    }
    final plans = payloadPlans;
    if (replacePlans) {
      final planIds = {...plans.map((p) => p['erpPlanId'] as String), ...storedPlans.map((p) => p.erpPlanId)};
      await (db.delete(db.scheduleLines)..where((t) => t.erpPlanId.isIn(planIds))).go();
      await (db.delete(db.plans)..where((t) => t.customerId.equals(id))).go();
      for (final p in plans) {
        final pid = p['erpPlanId'] as String;
        await db.into(db.plans).insertOnConflictUpdate(PlansCompanion.insert(
              erpPlanId: pid,
              customerId: id,
              product: (p['product'] as String?) ?? '',
              startDate: (p['startDate'] as String?) ?? '',
              finalDueDate: (p['finalDueDate'] as String?) ?? '',
              installmentCount: (p['installmentCount'] as num?)?.toInt() ?? 0,
              totalPayablePoisha: (p['totalPayablePoisha'] as num?)?.toInt() ?? 0,
              downPaymentPoisha: Value((p['downPaymentPoisha'] as num?)?.toInt() ?? 0),
              paidPoisha: (p['paidPoisha'] as num?)?.toInt() ?? 0,
              outstandingPoisha: (p['outstandingPoisha'] as num?)?.toInt() ?? 0,
              status: (p['status'] as String?) ?? 'active',
              badSuggested: Value((p['badSuggested'] as bool?) ?? false),
              kind: Value(planKindOf(p)),
              invoiceNo: Value(p['invoiceNo'] as String?),
              saleDate: Value(p['saleDate'] as String?),
              frequency: Value(p['frequency'] as String?),
              customDays: Value((p['customDays'] as num?)?.toInt()),
              itemsJson: Value(p['items'] == null ? null : jsonEncode(p['items'])),
              guarantorJson: Value(p['guarantor'] == null ? null : jsonEncode(p['guarantor'])),
              writtenOffPoisha: Value((p['writtenOffPoisha'] as num?)?.toInt() ?? 0),
            ));
        for (final s in ((p['schedule'] as List?) ?? const []).cast<Json>()) {
          await db.into(db.scheduleLines).insertOnConflictUpdate(ScheduleLinesCompanion.insert(
                erpPlanId: pid,
                seq: (s['seq'] as num).toInt(),
                dueDate: s['dueDate'] as String,
                amountPoisha: (s['amountPoisha'] as num).toInt(),
                paidPoisha: (s['paidPoisha'] as num?)?.toInt() ?? 0,
                status: (s['status'] as String?) ?? 'upcoming',
                estimated: Value((s['estimated'] as bool?) ?? false),
                lateFeePoisha: Value((s['lateFeePoisha'] as num?)?.toInt() ?? 0),
                rolled: Value((s['rolled'] as bool?) ?? false),
                paidOn: Value(s['paidOn'] as String?),
                daysLate: Value((s['daysLate'] as num?)?.toInt() ?? 0),
                missed: Value((s['missed'] as bool?) ?? false),
                paymentsJson: Value(s['payments'] is List
                    ? jsonEncode([
                        for (final x in (s['payments'] as List).cast<Json>())
                          {'id': x['erpPaymentId'], 'date': x['date'], 'amountPoisha': x['amountPoisha'], 'receiptNo': x['receiptNo']},
                      ])
                    : null),
              ));
        }
      }
    }
    final payments = (d['payments'] as List?)?.cast<Json>();
    if (payments != null) {
      await (db.delete(db.erpPayments)..where((t) => t.customerId.equals(id))).go();
      for (final p in payments.take(20)) {
        await db.into(db.erpPayments).insertOnConflictUpdate(ErpPaymentsCompanion.insert(
              erpPaymentId: p['erpPaymentId'] as String,
              customerId: id,
              planId: Value((p['erpPlanId'] ?? p['planId']) as String?),
              date: p['date'] as String,
              amountPoisha: (p['amountPoisha'] as num).toInt(),
              method: (p['method'] as String?) ?? 'cash',
              source: (p['source'] as String?) ?? 'office',
              receiptNo: Value(p['receiptNo'] as String?),
              reversed: Value((p['reversed'] as bool?) ?? false),
              methodLabel: Value(p['methodLabel'] as String?),
              collectorName: Value(p['collectorName'] as String?),
              referrerName: Value(p['referrerName'] as String?),
              advance: Value((p['advance'] as bool?) ?? false),
              discountPoisha: Value((p['discountPoisha'] as num?)?.toInt() ?? 0),
            ));
      }
    }
    final reg = _registry();
    for (final n in ((d['recentNotes'] as List?) ?? const []).cast<Json>()) {
      await reg.pullFor('note')?.upsert(db, (n['id'] ?? n['clientId']) as String, n);
    }
    if (promise != null) await reg.pullFor('promise')?.upsert(db, promise['id'] as String, promise);
  }

  /// Tombstone: customer left this user's scope (handover, reassignment).
  /// Removed only after this device's pending mutations for it are synced
  /// (04-architecture §6); otherwise kept and retried on the next pull.
  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) async {
    final pending = await (db.select(db.outbox)..where((t) => t.state.isNotValue('done') & t.payloadJson.like('%"customerId":"$id"%'))).get();
    if (pending.isNotEmpty) {
      await (db.update(db.customers)..where((t) => t.serverId.equals(id))).write(const CustomersCompanion(assigneeId: Value('__leaving__')));
      return;
    }
    final planIds = (await (db.select(db.plans)..where((t) => t.customerId.equals(id))).get()).map((p) => p.erpPlanId).toList();
    await (db.delete(db.scheduleLines)..where((t) => t.erpPlanId.isIn(planIds))).go();
    await (db.delete(db.plans)..where((t) => t.customerId.equals(id))).go();
    await (db.delete(db.erpPayments)..where((t) => t.customerId.equals(id))).go();
    await (db.delete(db.customers)..where((t) => t.serverId.equals(id))).go();
  }
}

class PlanWithSchedule {
  const PlanWithSchedule(this.plan, this.schedule);
  final PlanRow plan;
  final List<ScheduleLineRow> schedule;

  /// Lines the ERP rolled forward (amount 0) are hidden so the schedule matches the office's.
  List<ScheduleLineRow> get visibleSchedule => schedule.where((s) => !s.rolled).toList();
  int get rolledCount => schedule.where((s) => s.rolled).length;

  /// Lines with nothing left on them (a partly paid line is not counted as paid).
  int get paidCount => visibleSchedule.where((s) => lineMoney(amountPoisha: s.amountPoisha, paidPoisha: s.paidPoisha).settled).length;

  /// Open installments and the overdue money of this invoice (unpaid part only).
  PlanDues get dues => planDues(visibleSchedule.map((s) => (status: s.status, amountPoisha: s.amountPoisha, paidPoisha: s.paidPoisha)));

  /// Installments to show: the visible lines when the ERP sent a schedule, else the plan's count.
  int get shownCount => schedule.isEmpty ? plan.installmentCount : visibleSchedule.length;

  bool get credit => plan.kind == 'credit';

  /// A cash sale (contract 1.44.0; unknown kinds too): no schedule, never due or collectable.
  bool get cash => isCashKind(plan.kind);

  /// Returned (closed) or cancelled in the ERP: shown muted, never offered for collection.
  /// A cash sale's `closed` means money is still owed (contract 1.44.0), not returned.
  bool get closedInErp => plan.status == 'cancelled' || (plan.status == 'closed' && !cash);

  /// Money can be taken against it: not returned/cancelled/settled and something is still owed.
  bool get collectable => isCollectablePlan(status: plan.status, outstandingPoisha: plan.outstandingPoisha, kind: plan.kind);

  List<PlanItem> get items => decodePlanItems(plan.itemsJson);
  Guarantor? get guarantor => Guarantor.parse(plan.guarantorJson);
}

/// Local reads for the customers feature (all from SQLite, offline).
class CustomerRepository {
  CustomerRepository(this._db);
  final AppDatabase _db;

  /// Every customer with its open invoices counted by kind and their numbers (FR-M-066, FR-M-067), in one
  /// SQL read: the invoice-type chips, the row label and the Home row read these, never the widgets.
  Stream<List<Customer>> watchAll() => _withInvoices(
        "WHERE c.assignee_id IS NULL OR c.assignee_id != '__leaving__' ORDER BY c.name_bn",
        const [],
      ).watch().map((rows) => rows.map(_customerOf).toList());

  Stream<Customer?> watchOne(String id) =>
      _withInvoices('WHERE c.server_id = ?', [Variable.withString(id)]).watch().map((rows) => rows.isEmpty ? null : _customerOf(rows.first));

  /// An installment or credit invoice is open when [isCollectablePlan] says so: something still owed, not
  /// returned, cancelled or settled. Cash sales (and unknown kinds, [isCashKind]) are never open.
  static const _open =
      "p.customer_id = c.server_id AND p.kind IN ('installment', 'credit') AND p.outstanding_poisha > 0 AND p.status NOT IN ('closed', 'cancelled', 'completed')";

  /// A cash sale counts while it stands: anything but cancelled (its `closed` means still owed).
  static const _cash = "p.customer_id = c.server_id AND p.kind NOT IN ('installment', 'credit') AND p.status != 'cancelled'";

  Selectable<QueryRow> _withInvoices(String tail, List<Variable<Object>> vars) => _db.customSelect(
        'SELECT c.*, '
        "(SELECT COUNT(*) FROM plans p WHERE $_open AND p.kind = 'installment') AS open_installment, "
        "(SELECT COUNT(*) FROM plans p WHERE $_open AND p.kind = 'credit') AS open_credit, "
        '(SELECT COUNT(*) FROM plans p WHERE $_cash) AS open_cash, '
        "(SELECT GROUP_CONCAT(invoice_no, char(31)) FROM (SELECT p.invoice_no FROM plans p WHERE $_open AND p.invoice_no IS NOT NULL AND p.invoice_no != '' "
        'ORDER BY p.sale_date DESC, p.invoice_no DESC)) AS open_invoice_nos '
        'FROM customers c $tail',
        variables: vars,
        readsFrom: {_db.customers, _db.plans},
      );

  Customer _customerOf(QueryRow r) {
    final nos = r.readNullable<String>('open_invoice_nos');
    return Customer(
      _db.customers.map(r.data),
      kinds: InvoiceKinds(
        installment: r.read<int>('open_installment'),
        credit: r.read<int>('open_credit'),
        cash: r.read<int>('open_cash'),
      ),
      invoiceNos: nos == null || nos.isEmpty ? const [] : nos.split(String.fromCharCode(31)),
    );
  }

  /// Who made the open promise of each customer that has one (Home row "promised by", FR-M-067): the
  /// promise's `createdByName` (contract 1.31.0; null on the phone means the user made it, shown as [myName]),
  /// else a colleague's promise from `colleague_activities`. Read only; the promises feature owns its table.
  Stream<Map<String, String>> watchPromiseMakers({required String? myName}) =>
      _promiseMakersQuery().watch().map((rows) => _promiseMakersOf(rows, myName));

  Selectable<QueryRow> _promiseMakersQuery({String? customerId}) => _db.customSelect(
        'SELECT c.server_id AS cid, p.client_id AS pid, p.created_by_name AS pname, ca.staff_name AS cname '
        'FROM customers c '
        'LEFT JOIN promises p ON p.client_id = c.open_promise_id OR p.server_id = c.open_promise_id '
        "LEFT JOIN colleague_activities ca ON ca.id = 'promise:' || c.open_promise_id "
        'WHERE c.open_promise_id IS NOT NULL${customerId == null ? '' : ' AND c.server_id = ?'}',
        variables: [if (customerId != null) Variable.withString(customerId)],
        readsFrom: {_db.customers, _db.promises, _db.colleagueActivities},
      );

  static Map<String, String> _promiseMakersOf(List<QueryRow> rows, String? myName) {
    final out = <String, String>{};
    for (final r in rows) {
      final name = promiseMakerName(
        ownRow: r.readNullable<String>('pid') != null,
        createdByName: r.readNullable<String>('pname'),
        colleagueName: r.readNullable<String>('cname'),
        myName: myName,
      );
      if (name != null) out[r.read<String>('cid')] = name;
    }
    return out;
  }

  /// Who did this month's work on one customer (FR-M-068): the latest visit of the month, the ERP payments'
  /// collectors and the open promise's maker. Names already on the phone only; each is null when unknown.
  Stream<MonthPeople> watchMonthPeople(String customerId, {required String today, required String? myName, required String? myUserId}) {
    final month = today.substring(0, 7);
    // One drift stream that fires on any change to the tables read below, then reads them once. Several
    // combined streams would cancel one after another and leave drift's close timers behind the screen.
    final trigger = _db.customSelect('SELECT 1', readsFrom: {_db.visits, _db.colleagueActivities, _db.erpPayments, _db.promises, _db.customers}).watch();
    return trigger.asyncMap((_) async {
      final mine = await (_db.select(_db.visits)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([(t) => OrderingTerm.desc(t.checkInAt)])
            ..limit(5))
          .get();
      final colleagues = await (_db.select(_db.colleagueActivities)
            ..where((t) => t.customerId.equals(customerId) & t.kind.equals('visit'))
            ..orderBy([(t) => OrderingTerm.desc(t.at)])
            ..limit(5))
          .get();
      final payments = await (_db.select(_db.erpPayments)
            ..where((t) => t.customerId.equals(customerId) & t.date.like('$month%') & t.reversed.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();
      final makers = _promiseMakersOf(await _promiseMakersQuery(customerId: customerId).get(), myName);
      final row = await (_db.select(_db.customers)..where((t) => t.serverId.equals(customerId))).getSingleOrNull();
      return monthPeopleOf(
        server: ServerActivity.parse(row?.activityJson),
        today: today,
        myName: myName,
        myVisits: [for (final v in mine) (at: v.checkInAt, userName: v.userName, byMe: v.userId == null || v.userId == myUserId)],
        colleagueVisits: [for (final a in colleagues) (at: a.at, name: a.staffName)],
        paymentPeople: [for (final p in payments) paymentPersonName(source: p.source, referrerName: p.referrerName, collectorName: p.collectorName)],
        promiseBy: makers[customerId],
      );
    });
  }

  Future<Customer?> getOne(String id) async {
    final r = await (_db.select(_db.customers)..where((t) => t.serverId.equals(id))).getSingleOrNull();
    return r == null ? null : Customer(r);
  }

  Stream<List<PlanWithSchedule>> watchPlans(String customerId) {
    final plans = (_db.select(_db.plans)..where((t) => t.customerId.equals(customerId))).watch();
    return plans.asyncMap((ps) async {
      final out = <PlanWithSchedule>[];
      for (final p in ps) {
        final lines = await (_db.select(_db.scheduleLines)
              ..where((t) => t.erpPlanId.equals(p.erpPlanId))
              ..orderBy([(t) => OrderingTerm.asc(t.seq)]))
            .get();
        out.add(PlanWithSchedule(p, lines));
      }
      return out;
    });
  }

  /// Plans (invoices) that already have an ERP payment on [day] (not removed, not an
  /// advance). The ERP takes one payment per installment invoice per day (OD-27).
  Stream<Set<String>> watchPlansPaidOn(String customerId, String day) => (_db.select(_db.erpPayments)
        ..where((t) => t.customerId.equals(customerId) & t.date.equals(day) & t.reversed.equals(false) & t.advance.equals(false) & t.planId.isNotNull()))
      .watch()
      .map((rows) => {for (final r in rows) r.planId!});

  /// Every invoice on the phone, in the shape the invoice totals need (FR-M-052): who it belongs to,
  /// its status and what it still owes.
  Stream<List<({String customerId, String status, int outstandingPoisha, String kind})>> watchPlanSummaries() => (_db.selectOnly(_db.plans)
        ..addColumns([_db.plans.customerId, _db.plans.status, _db.plans.outstandingPoisha, _db.plans.kind]))
      .watch()
      .map((rows) => [
            for (final r in rows)
              (
                customerId: r.read(_db.plans.customerId)!,
                status: r.read(_db.plans.status)!,
                outstandingPoisha: r.read(_db.plans.outstandingPoisha)!,
                kind: r.read(_db.plans.kind)!,
              ),
          ]);

  /// ERP money per customer in the month of [today] (FR-M-038): only this month's rows are read.
  Stream<Map<String, int>> watchPaidThisMonth(String today) => (_db.select(_db.erpPayments)
        ..where((t) => t.date.like('${today.substring(0, 7)}%') & t.reversed.equals(false)))
      .watch()
      .map((rows) => paidThisMonth(rows.map((r) => (customerId: r.customerId, date: r.date, amountPoisha: r.amountPoisha, reversed: r.reversed)), today));

  Stream<List<ErpPaymentRow>> watchPayments(String customerId) => (_db.select(_db.erpPayments)
        ..where((t) => t.customerId.equals(customerId))
        ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .watch();

  /// Called by other features through the barrel (never by touching the
  /// table directly): a field collection was recorded locally.
  Future<void> applyLocalCollection(String customerId, int amountPoisha, DateTime at) async {
    final c = await getOne(customerId);
    if (c == null) return;
    await (_db.update(_db.customers)..where((t) => t.serverId.equals(customerId))).write(
      CustomersCompanion(pendingFieldPoisha: Value(c.row.pendingFieldPoisha + amountPoisha), lastVisitAt: Value(at)),
    );
  }

  Future<void> applyLocalVisit(String customerId, DateTime at) =>
      (_db.update(_db.customers)..where((t) => t.serverId.equals(customerId))).write(CustomersCompanion(lastVisitAt: Value(at)));

  Future<void> applyLocalPromise(String customerId, {required String? id, required String? date, required int? amountPoisha}) =>
      (_db.update(_db.customers)..where((t) => t.serverId.equals(customerId))).write(
        CustomersCompanion(openPromiseId: Value(id), openPromiseDate: Value(date), openPromisePoisha: Value(amountPoisha)),
      );

  Future<void> applyLocalTag(String customerId, {required String state, String? severity, String? reasonJson}) =>
      (_db.update(_db.customers)..where((t) => t.serverId.equals(customerId))).write(
        CustomersCompanion(tagState: Value(state), tagSeverity: Value(severity), tagReason: Value(reasonJson)),
      );
}
