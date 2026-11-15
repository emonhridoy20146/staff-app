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
    Notifications,
    KvSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

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
