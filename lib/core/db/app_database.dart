import 'dart:convert';

import 'package:drift/drift.dart';

import '../text/search_text.dart';
import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

/// Encrypted local database (SQLite3MultipleCiphers via package:sqlite3
/// hooks, key from Android Keystore — see `db_connection.dart`).
///
/// Migration rule (docs/06 §3): bump [schemaVersion], add a step to
/// [migration], dump the schema (`make schema-dump`), add a migration test
/// from every released version. Never drop outbox/collections data.
@DriftDatabase(
  tables: [
    Customers,
    Plans,
    ScheduleLines,
    ErpPayments,
    ReturnedPlans,
    LocationProposals,
    Collections,
    ReceiptBlocks,
    CashPositions,
    Deposits,
    CashClosings,
    Visits,
    Notes,
    Promises,
    TagEvents,
    AttendanceEvents,
    AttendanceDays,
    Handovers,
    MediaQueue,
    Outbox,
    IdMap,
    SyncMeta,
    LocationQueue,
    ContactAttempts,
    CoworkSessions,
    Broadcasts,
    Tasks,
    Notifications,
    KvSettings,
    ColleagueActivities,
    MapPlaces,
    Prospects,
    StaffRequests,
    RequestComments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 21;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_customers_overdue ON customers (overdue, days_overdue)',
          );
          await customStatement('CREATE INDEX IF NOT EXISTS idx_customers_due ON customers (due_today)');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_customers_geo ON customers (lat, lng)');
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_collections_recorded ON collections (recorded_at DESC)',
          );
          await customStatement('CREATE INDEX IF NOT EXISTS idx_collections_status ON collections (status)');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_outbox_state ON outbox (state, created_at)');
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_promises_date ON promises (promised_date, status)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_visits_customer ON visits (customer_id, check_in_at DESC)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_notes_customer ON notes (customer_id, created_at DESC)',
          );
          await customStatement('CREATE INDEX IF NOT EXISTS idx_location_queue_t ON location_queue (t)');
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_colleague_customer ON colleague_activities (customer_id, kind, at DESC)',
          );
          await customStatement('CREATE INDEX IF NOT EXISTS idx_staff_requests_created ON staff_requests (created_at DESC)');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_returned_plans_customer ON returned_plans (customer_id)');
        },
        onUpgrade: (m, from, to) async {
          // v2 (0.2.0): contact attempts + location queue time index.
          if (from < 2) {
            await m.createTable(contactAttempts);
            await customStatement('CREATE INDEX IF NOT EXISTS idx_location_queue_t ON location_queue (t)');
          }
          // v3 (0.3.0): manager's reason on pin proposals.
          if (from < 3) {
            await m.addColumn(locationProposals, locationProposals.decisionReason);
          }
          // v4 (0.6.0): co-work sessions; recorder and co-work fields on visits.
          if (from < 4) {
            await m.createTable(coworkSessions);
            await m.addColumn(visits, visits.userId);
            await m.addColumn(visits, visits.coWorkSessionId);
            await m.addColumn(visits, visits.coWorkParticipantIdsJson);
          }
          // v5 (0.8.0): map pins: how a pin proposal was made, and where the phone was.
          if (from < 5) {
            await m.addColumn(locationProposals, locationProposals.method);
            await m.addColumn(locationProposals, locationProposals.deviceGeoJson);
          }
          // v6 (0.9.0, contract 1.12.0): notices from the office; who a call was to.
          if (from < 6) {
            await m.createTable(broadcasts);
            // A v1 file got contact_attempts from the v2 step above, already with the column.
            if (from >= 2) await m.addColumn(contactAttempts, contactAttempts.target);
          }
          // v7 (0.10.0, contract 1.13.0): the real ERP's shape. Cached ERP data only; the next
          // sync fills the new columns, nothing unsynced is touched.
          if (from < 7) {
            for (final c in [customers.detailedAddress, customers.directions, customers.erpRiskJson]) {
              await m.addColumn(customers, c);
            }
            for (final c in [plans.kind, plans.invoiceNo, plans.saleDate, plans.frequency, plans.customDays, plans.itemsJson, plans.guarantorJson, plans.writtenOffPoisha]) {
              await m.addColumn(plans, c);
            }
            await m.addColumn(scheduleLines, scheduleLines.lateFeePoisha);
            await m.addColumn(scheduleLines, scheduleLines.rolled);
            for (final c in [erpPayments.methodLabel, erpPayments.collectorName, erpPayments.advance, erpPayments.discountPoisha]) {
              await m.addColumn(erpPayments, c);
            }
          }
          // v8 (0.11.0, contract 1.19.0): a customer's branch and assignee name. Staff now see
          // every customer of their branches, so the next sync takes a fresh snapshot (bootstrap
          // only upserts: the outbox, collections and everything unsynced stay as they are).
          if (from < 8) {
            for (final c in [customers.branchId, customers.branchCode, customers.branchNameBn, customers.branchNameEn, customers.assigneeName]) {
              await m.addColumn(customers, c);
            }
            await customStatement('UPDATE sync_state SET bootstrap_done = 0');
          }
          // v9 (0.12.0, contract 1.20.0): tasks from the office. A new table only, nothing existing is
          // touched. No new snapshot is forced: tasks come on the change feed from the moment the
          // super admin turns `module.tasks` on, and a fresh install or v7 update already takes one.
          if (from < 9) {
            await m.createTable(tasks);
          }
          // v10 (0.13.x, contract 1.25.0): the server's overtime and over-break minutes on a day
          // (FR-M-051). Two columns with a default of 0; the next pull fills them. Nothing else moves.
          if (from < 10) {
            await m.addColumn(attendanceDays, attendanceDays.overtimeMin);
            await m.addColumn(attendanceDays, attendanceDays.overBreakMin);
          }
          // v11 (contract 1.14.0): paid-on date, days late, missed and the payments of a schedule line
          // (FR-M-054). Defaults only; the next pull of the customer fills them. Nothing else moves.
          if (from < 11) {
            await m.addColumn(scheduleLines, scheduleLines.paidOn);
            await m.addColumn(scheduleLines, scheduleLines.daysLate);
            await m.addColumn(scheduleLines, scheduleLines.missed);
            await m.addColumn(scheduleLines, scheduleLines.paymentsJson);
          }
          // v12/v13 (contract 1.31.0-1.33.0): colleagues' visits, promises and collections with their
          // names, who made a promise, edited and voided collections (FR-M-057, FR-M-058). One idempotent
          // step: v12 changed while it was still being built, so a phone that ran such a build is at 12
          // with some columns missing; v13 adds whatever is missing and touches nothing else. The server's
          // resync floor makes the phone take one fresh snapshot, which only upserts: the outbox and
          // everything unsynced stay.
          if (from < 13) {
            await _ensureV12(m);
          }
          // v14 (contract 1.35.0, FR-M-059): which deposit handed a collection in, and what a deposit took
          // besides cash. Nullable columns only; the next pull fills them. Nothing unsynced is touched.
          if (from < 14) {
            for (final c in [collections.depositId, collections.depositedAt]) {
              await _ensureColumn(m, collections, c);
            }
            for (final c in [deposits.collectionCount, deposits.nonCashPoisha, deposits.nonCashCount, deposits.failureCode]) {
              await _ensureColumn(m, deposits, c);
            }
          }
          // v15 (contract 1.38.0, FR-PLC-001): places on the map. A new table only; nothing else moves.
          // The places arrive with the next pull (the server sends the branch's places in the snapshot).
          if (from < 15) {
            if (!await _hasTable('map_places')) await m.createTable(mapPlaces);
          }
          // v16 (contract 1.44.0, FR-M-068): who did this month's work, as the server counts it, and the ERP
          // referrer of a payment. Nullable columns only; the next pull fills them. Nothing unsynced is touched.
          if (from < 16) {
            await _ensureColumn(m, customers, customers.activityJson);
            await _ensureColumn(m, erpPayments, erpPayments.referrerName);
          }
          // v17 (FR-M-069, FR-M-072): why a photo upload failed and when it was last tried (sync centre), and the
          // promise follow-up chain, and the prospects table. New columns (nullable or with a default) and a new table only;
          // nothing unsynced is touched.
          if (from < 17) {
            await _ensureColumn(m, mediaQueue, mediaQueue.lastError);
            await _ensureColumn(m, mediaQueue, mediaQueue.lastAttemptAt);
            // contract 1.45.0 (FR-M-072): promise follow-up chain. Existing promises are attempt 1.
            await _ensureColumn(m, promises, promises.followUpOf);
            await _ensureColumn(m, promises, promises.followUpId);
            await _ensureColumn(m, promises, promises.attempt);
            // contract 1.45.0 (FR-M-073): possible customers. A new table only.
            if (!await _hasTable('prospects')) await m.createTable(prospects);
          }
          // v18 (FR-M-075, contract 1.48.0): staff requests and my comments on them. New tables only; nothing
          // unsynced is touched.
          if (from < 18) {
            if (!await _hasTable('staff_requests')) await m.createTable(staffRequests);
            if (!await _hasTable('request_comments')) await m.createTable(requestComments);
            await customStatement('CREATE INDEX IF NOT EXISTS idx_staff_requests_created ON staff_requests (created_at DESC)');
          }
          // v19 (FR-M-076): customer search finds invoice numbers and numbers typed with spaces. No new column:
          // search_text is rebuilt from the customers and plans tables already on the phone, offline. Only that
          // one cached column changes; the outbox, collections, media and every other table are not touched.
          if (from < 19) await reindexCustomerSearch();
          // v20 (FR-M-081): the reason code of a customer's tag, so each bad-tag reason has its own colour. One
          // nullable column. A tag this phone set is filled from its own `tag_events` here, offline; the others
          // come with the customer's next pull and show the generic bad colour until then (ADR-M44). Nothing
          // unsynced is touched.
          if (from < 20) {
            await _ensureColumn(m, customers, customers.tagReasonCode);
            await backfillTagReasonCodes();
          }
          // v21 (contract 1.53.0, FR-CUS-024, FR-M-085, ADR-M46): invoices returned in the ERP are shown again,
          // never counted. A new table for them and columns with defaults (0 / false / '[]') only. No forced
          // resync: the server re-sends the affected customers on the next pull. Nothing unsynced is touched.
          if (from < 21) {
            if (!await _hasTable('returned_plans')) await m.createTable(returnedPlans);
            await customStatement('CREATE INDEX IF NOT EXISTS idx_returned_plans_customer ON returned_plans (customer_id)');
            await _ensureColumn(m, customers, customers.returnedInvoiceCount);
            await _ensureColumn(m, customers, customers.onlyReturned);
            await _ensureColumn(m, erpPayments, erpPayments.returned);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Rebuilds `customers.search_text` of every row from what the phone holds
  /// (names, code, phones incl. ones added here, address, every plan's invoice
  /// number). Schema 19 runs it once; it writes nothing but that column.
  /// [only] limits it to those customers (FR-CUS-023: a returned invoice
  /// removed from a customer other than the one being pulled).
  Future<void> reindexCustomerSearch({Iterable<String>? only}) async {
    final ids = only?.toSet();
    if (ids != null && ids.isEmpty) return;
    final invoices = <String, List<String>>{};
    // FR-M-085 (1.53.0): a returned invoice's number finds its customer too (the hit carries the marker). The
    // schema 19 step runs this before schema 21 makes `returned_plans`.
    final returned = await _hasTable('returned_plans')
        ? ' UNION ALL SELECT customer_id, invoice_no FROM returned_plans WHERE invoice_no IS NOT NULL'
        : '';
    for (final r in await customSelect('SELECT customer_id, invoice_no FROM plans WHERE invoice_no IS NOT NULL$returned').get()) {
      invoices.putIfAbsent(r.read<String>('customer_id'), () => []).add(r.read<String>('invoice_no'));
    }
    final rows = await customSelect('SELECT server_id, name_bn, name_en, code, phones_json, address FROM customers').get();
    for (final r in rows) {
      if (ids != null && !ids.contains(r.read<String>('server_id'))) continue;
      final id = r.read<String>('server_id');
      final text = customerSearchText(
        nameBn: r.read<String>('name_bn'),
        nameEn: r.read<String?>('name_en'),
        code: r.read<String>('code'),
        phones: _storedPhoneNumbers(r.read<String>('phones_json')),
        address: r.read<String?>('address'),
        invoiceNos: invoices[id] ?? const [],
      );
      await customStatement('UPDATE customers SET search_text = ? WHERE server_id = ?', [text, id]);
    }
  }

  /// Fills `customers.tag_reason_code` of tagged customers that have none from this phone's own `tag_events`
  /// (schema 20 runs it once, offline): the newest "tag" event of the customer names the reason when the tag
  /// on the row is still the one set here (waiting for review), or carries the same reason text. A tag someone
  /// else set stays null (generic colour) until the server sends its code. Writes nothing but that column.
  Future<void> backfillTagReasonCodes() async {
    final rows = await customSelect("SELECT server_id, tag_reason FROM customers WHERE tag_state = 'tagged' AND tag_reason_code IS NULL").get();
    for (final r in rows) {
      final id = r.read<String>('server_id');
      final events = await customSelect(
        'SELECT reason_code, reason, next_json FROM tag_events WHERE customer_id = ? ORDER BY at DESC',
        variables: [Variable.withString(id)],
      ).get();
      final own = events.where((e) => _jsonMap(e.read<String>('next_json'))['state'] == 'tagged').firstOrNull;
      if (own == null) continue;
      final onRow = _jsonMap(r.read<String?>('tag_reason'));
      final same = onRow['pendingReview'] == true || (onRow['reason'] is String && onRow['reason'] == own.read<String>('reason'));
      if (!same) continue;
      await customStatement('UPDATE customers SET tag_reason_code = ? WHERE server_id = ?', [own.read<String>('reason_code'), id]);
    }
  }

  static Map<String, dynamic> _jsonMap(String? json) {
    if (json == null || json.isEmpty) return const {};
    try {
      final v = jsonDecode(json);
      return v is Map<String, dynamic> ? v : const {};
    } on FormatException {
      return const {};
    }
  }

  /// The numbers in `customers.phones_json`: an ERP number is a plain string,
  /// one added in the app is `{"n": number, ...}` (customers `domain/phones.dart`).
  static List<String> _storedPhoneNumbers(String json) {
    final Object? raw;
    try {
      raw = jsonDecode(json);
    } on FormatException {
      return const [];
    }
    if (raw is! List) return const [];
    return [
      for (final e in raw)
        if (e is String && e.isNotEmpty) e else if (e is Map && e['n'] is String) e['n'] as String,
    ];
  }

  Future<bool> _hasTable(String name) async =>
      (await customSelect("SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?", variables: [Variable.withString(name)]).get()).isNotEmpty;

  Future<void> _ensureColumn(Migrator m, TableInfo<Table, dynamic> table, GeneratedColumn<Object> column) async {
    final cols = await customSelect('PRAGMA table_info(${table.actualTableName})').get();
    if (cols.any((r) => r.read<String>('name') == column.name)) return;
    await m.addColumn(table, column);
  }

  /// Everything schemas 12 and 13 add, safe to run on a phone that already has some of it.
  Future<void> _ensureV12(Migrator m) async {
    if (!await _hasTable('colleague_activities')) await m.createTable(colleagueActivities);
    await _ensureColumn(m, colleagueActivities, colleagueActivities.voidedKind);
    await _ensureColumn(m, promises, promises.createdByName);
    for (final c in [collections.previousAmountPoisha, collections.voidedKind, collections.voidedByName, collections.voidedReason]) {
      await _ensureColumn(m, collections, c);
    }
    await customStatement('CREATE INDEX IF NOT EXISTS idx_colleague_customer ON colleague_activities (customer_id, kind, at DESC)');
  }

  // ── key/value settings ──────────────────────────────────────────────────
  Future<String?> kvGet(String key) async =>
      (await (select(kvSettings)..where((t) => t.key.equals(key))).getSingleOrNull())?.valueJson;

  Future<void> kvSet(String key, String valueJson) =>
      into(kvSettings).insertOnConflictUpdate(KvSettingsCompanion.insert(key: key, valueJson: valueJson));

  Stream<String?> kvWatch(String key) => (select(kvSettings)..where((t) => t.key.equals(key)))
      .watchSingleOrNull()
      .map((r) => r?.valueJson);

  /// Wipes everything except unsynced work (logout path decides separately).
  Future<void> wipeAll() => transaction(() async {
        for (final t in allTables) {
          await delete(t).go();
        }
      });
}
