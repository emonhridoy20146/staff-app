import 'package:drift/drift.dart';

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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 11;

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
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

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
