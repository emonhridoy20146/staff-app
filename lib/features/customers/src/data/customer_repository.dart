import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/api/api_models.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/sync/sync_handlers.dart';
import '../domain/customer.dart';
import '../domain/schedule.dart';

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
    final phones = <String>{if (d['phone'] != null) d['phone'] as String, ...((d['phones'] as List?) ?? const []).cast<String>()}.toList();
    final badges = ((d['badges'] as List?) ?? const []).cast<String>();
    final search = normalizeSearch([name.bn, name.en ?? '', d['code'] ?? '', ...phones, d['address'] ?? ''].join(' '));

    // Keep locally-recorded pending amounts until the server confirms them.
    final existing = await (db.select(db.customers)..where((t) => t.serverId.equals(id))).getSingleOrNull();
    final serverPending = (d['pendingFieldPoisha'] as num?)?.toInt() ?? 0;

    await db.into(db.customers).insertOnConflictUpdate(
          CustomersCompanion.insert(
            serverId: id,
            erpCustomerId: Value(d['erpCustomerId'] as String?),
            code: (d['code'] as String?) ?? id,
            nameBn: name.bn,
            nameEn: Value(name.en),
            phonesJson: Value(jsonEncode(phones)),
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
          ),
        );

    final plans = (d['plans'] as List?)?.cast<Json>();
    if (plans != null) {
      final planIds = plans.map((p) => p['erpPlanId'] as String).toList();
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
              kind: Value((p['kind'] as String?) ?? 'installment'),
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

  /// Returned (closed) or cancelled in the ERP: shown muted, never offered for collection.
  bool get closedInErp => plan.status == 'closed' || plan.status == 'cancelled';

  /// Money can be taken against it: not returned/cancelled/settled and something is still owed.
  bool get collectable => isCollectablePlan(status: plan.status, outstandingPoisha: plan.outstandingPoisha);

  List<PlanItem> get items => decodePlanItems(plan.itemsJson);
  Guarantor? get guarantor => Guarantor.parse(plan.guarantorJson);
}

/// Local reads for the customers feature (all from SQLite, offline).
class CustomerRepository {
  CustomerRepository(this._db);
  final AppDatabase _db;

  Stream<List<Customer>> watchAll() => (_db.select(_db.customers)
        ..where((t) => t.assigneeId.isNotValue('__leaving__') | t.assigneeId.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.nameBn)]))
      .watch()
      .map((rows) => rows.map(Customer.new).toList());

  Stream<Customer?> watchOne(String id) =>
      (_db.select(_db.customers)..where((t) => t.serverId.equals(id))).watchSingleOrNull().map((r) => r == null ? null : Customer(r));

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
