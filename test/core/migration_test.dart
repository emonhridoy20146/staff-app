import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';

/// Every released schema upgrades to the current one (v17) and
/// existing rows survive.
void main() {
  test('migrates a 0.1.0 database to the current schema without losing outbox rows', () async {
    final dir = await Directory.systemTemp.createTemp('mig');
    final file = File('${dir.path}/app.db');

    // Build a v1-shaped file: current schema minus what v2 added.
    final v1 = AppDatabase(NativeDatabase(file));
    await v1.customStatement('SELECT 1');
    await _dropV12(v1);
    await _dropV11(v1);
    await _dropV10(v1);
    await _dropV9(v1);
    await _dropV8(v1);
    await _dropV7(v1);
    await v1.customStatement('DROP TABLE broadcasts');
    await v1.customStatement('ALTER TABLE location_proposals DROP COLUMN method');
    await v1.customStatement('ALTER TABLE location_proposals DROP COLUMN device_geo_json');
    await v1.customStatement('DROP TABLE contact_attempts');
    await v1.customStatement('DROP INDEX IF EXISTS idx_location_queue_t');
    await v1.customStatement('ALTER TABLE location_proposals DROP COLUMN decision_reason');
    await v1.customStatement('DROP TABLE cowork_sessions');
    await v1.customStatement('ALTER TABLE visits DROP COLUMN user_id');
    await v1.customStatement('ALTER TABLE visits DROP COLUMN co_work_session_id');
    await v1.customStatement('ALTER TABLE visits DROP COLUMN co_work_participant_ids_json');
    await v1.customStatement(
        "INSERT INTO location_proposals (client_id, customer_id, lat, lng, accuracy_m) VALUES ('p-1', 'c-1', 22.7, 90.35, 9)");
    await v1.customStatement(
        "INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('m-1', 'collection', 'create', '{}', 0)");
    await v1.customStatement('PRAGMA user_version = 1');
    await v1.close();

    final v2 = AppDatabase(NativeDatabase(file));
    expect(v2.schemaVersion, 17);
    expect(await v2.select(v2.coworkSessions).get(), isEmpty);
    final props = await v2.select(v2.locationProposals).get();
    expect(props.single.decisionReason, isNull);
    expect(await v2.select(v2.contactAttempts).get(), isEmpty);
    final idx = await v2.customSelect("SELECT name FROM sqlite_master WHERE type = 'index' AND name = 'idx_location_queue_t'").get();
    expect(idx, hasLength(1));
    final ob = await v2.select(v2.outbox).get();
    expect(ob.single.mutationId, 'm-1');
    expect(ob.single.state, 'pending');
    await v2.close();
    await dir.delete(recursive: true);
  });

  test('migrates a 0.2.0 (schema 2) database: adds decision_reason, keeps proposals', () async {
    final dir = await Directory.systemTemp.createTemp('mig2');
    final file = File('${dir.path}/app.db');
    final v2 = AppDatabase(NativeDatabase(file));
    await v2.customStatement('SELECT 1');
    await _dropV12(v2);
    await _dropV11(v2);
    await _dropV10(v2);
    await _dropV9(v2);
    await _dropV8(v2);
    await _dropV7(v2);
    await v2.customStatement('DROP TABLE broadcasts');
    await v2.customStatement('ALTER TABLE contact_attempts DROP COLUMN target');
    await v2.customStatement('ALTER TABLE location_proposals DROP COLUMN method');
    await v2.customStatement('ALTER TABLE location_proposals DROP COLUMN device_geo_json');
    await v2.customStatement('ALTER TABLE location_proposals DROP COLUMN decision_reason');
    await v2.customStatement('DROP TABLE cowork_sessions');
    await v2.customStatement('ALTER TABLE visits DROP COLUMN user_id');
    await v2.customStatement('ALTER TABLE visits DROP COLUMN co_work_session_id');
    await v2.customStatement('ALTER TABLE visits DROP COLUMN co_work_participant_ids_json');
    await v2.customStatement(
        "INSERT INTO location_proposals (client_id, customer_id, lat, lng, accuracy_m) VALUES ('p-2', 'c-2', 22.7, 90.35, 9)");
    await v2.customStatement('PRAGMA user_version = 2');
    await v2.close();

    final v3 = AppDatabase(NativeDatabase(file));
    final props = await v3.select(v3.locationProposals).get();
    expect(props.single.clientId, 'p-2');
    expect(props.single.decisionReason, isNull);
    await v3.close();
    await dir.delete(recursive: true);
  });

  test('migrates a 0.5.0 (schema 3) database: adds co-work table and visit columns, keeps visits and queue', () async {
    final dir = await Directory.systemTemp.createTemp('mig3');
    final file = File('${dir.path}/app.db');
    final v3 = AppDatabase(NativeDatabase(file));
    await v3.customStatement('SELECT 1');
    await _dropV12(v3);
    await _dropV11(v3);
    await _dropV10(v3);
    await _dropV9(v3);
    await _dropV8(v3);
    await _dropV7(v3);
    await v3.customStatement('DROP TABLE broadcasts');
    await v3.customStatement('ALTER TABLE contact_attempts DROP COLUMN target');
    await v3.customStatement('ALTER TABLE location_proposals DROP COLUMN method');
    await v3.customStatement('ALTER TABLE location_proposals DROP COLUMN device_geo_json');
    await v3.customStatement('DROP TABLE cowork_sessions');
    await v3.customStatement('ALTER TABLE visits DROP COLUMN user_id');
    await v3.customStatement('ALTER TABLE visits DROP COLUMN co_work_session_id');
    await v3.customStatement('ALTER TABLE visits DROP COLUMN co_work_participant_ids_json');
    await v3.customStatement(
        "INSERT INTO visits (client_id, customer_id, check_in_at, outcome) VALUES ('v-1', 'c-1', 0, 'not_home')");
    await v3.customStatement(
        "INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('v-1', 'visit', 'create', '{}', 0)");
    await v3.customStatement('PRAGMA user_version = 3');
    await v3.close();

    final v4 = AppDatabase(NativeDatabase(file));
    final visits = await v4.select(v4.visits).get();
    expect(visits.single.clientId, 'v-1');
    expect(visits.single.coWorkSessionId, isNull);
    expect(visits.single.userId, isNull);
    expect(await v4.select(v4.coworkSessions).get(), isEmpty);
    expect((await v4.select(v4.outbox).get()).single.mutationId, 'v-1');
    await v4.close();
    await dir.delete(recursive: true);
  });

  test('migrates a 0.7.0 (schema 4) database: map pin columns, old proposals stay GPS and keep their outbox row', () async {
    final dir = await Directory.systemTemp.createTemp('mig4');
    final file = File('${dir.path}/app.db');
    final v4 = AppDatabase(NativeDatabase(file));
    await v4.customStatement('SELECT 1');
    await _dropV12(v4);
    await _dropV11(v4);
    await _dropV10(v4);
    await _dropV9(v4);
    await _dropV8(v4);
    await _dropV7(v4);
    await v4.customStatement('DROP TABLE broadcasts');
    await v4.customStatement('ALTER TABLE contact_attempts DROP COLUMN target');
    await v4.customStatement('ALTER TABLE location_proposals DROP COLUMN method');
    await v4.customStatement('ALTER TABLE location_proposals DROP COLUMN device_geo_json');
    await v4.customStatement(
        "INSERT INTO location_proposals (client_id, customer_id, lat, lng, accuracy_m, sync_state) VALUES ('p-4', 'c-4', 22.7, 90.35, 9, 'queued')");
    await v4.customStatement(
        "INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('p-4', 'location_proposal', 'create', '{}', 0)");
    await v4.customStatement('PRAGMA user_version = 4');
    await v4.close();

    final v5 = AppDatabase(NativeDatabase(file));
    final p = (await v5.select(v5.locationProposals).get()).single;
    expect(p.clientId, 'p-4');
    expect(p.method, 'gps');
    expect(p.deviceGeoJson, isNull);
    expect(p.accuracyM, 9);
    expect((await v5.select(v5.outbox).get()).single.mutationId, 'p-4');
    await v5.close();
    await dir.delete(recursive: true);
  });

  test('migrates a 0.8.0 (schema 5) database: notices table and call target, old calls were to the customer', () async {
    final dir = await Directory.systemTemp.createTemp('mig5');
    final file = File('${dir.path}/app.db');
    final v5 = AppDatabase(NativeDatabase(file));
    await v5.customStatement('SELECT 1');
    await _dropV12(v5);
    await _dropV11(v5);
    await _dropV10(v5);
    await _dropV9(v5);
    await _dropV8(v5);
    await _dropV7(v5);
    await v5.customStatement('DROP TABLE broadcasts');
    await v5.customStatement('ALTER TABLE contact_attempts DROP COLUMN target');
    await v5.customStatement(
        "INSERT INTO contact_attempts (client_id, customer_id, channel, at, phone_index, sync_state) VALUES ('ca-5', 'c-5', 'call', 0, 1, 'queued')");
    await v5.customStatement(
        "INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('ca-5', 'contact_attempt', 'create', '{}', 0)");
    await v5.customStatement('PRAGMA user_version = 5');
    await v5.close();

    final v6 = AppDatabase(NativeDatabase(file));
    final a = (await v6.select(v6.contactAttempts).get()).single;
    expect(a.clientId, 'ca-5');
    expect(a.target, 'customer');
    expect(a.phoneIndex, 1);
    expect(await v6.select(v6.broadcasts).get(), isEmpty);
    expect((await v6.select(v6.outbox).get()).single.mutationId, 'ca-5');
    await v6.close();
    await dir.delete(recursive: true);
  });

  test('migrates a 0.9.0 (schema 6) database: ERP invoice columns get their defaults, cached plans and the outbox stay', () async {
    final dir = await Directory.systemTemp.createTemp('mig6');
    final file = File('${dir.path}/app.db');
    final v6 = AppDatabase(NativeDatabase(file));
    await v6.customStatement('SELECT 1');
    await _dropV12(v6);
    await _dropV11(v6);
    await _dropV10(v6);
    await _dropV9(v6);
    await _dropV8(v6);
    await _dropV7(v6);
    await v6.customStatement("INSERT INTO customers (server_id, code, name_bn) VALUES ('c-6', 'C-6', 'গ্রাহক')");
    await v6.customStatement(
        'INSERT INTO plans (erp_plan_id, customer_id, product, start_date, final_due_date, installment_count, total_payable_poisha, paid_poisha, outstanding_poisha, status) '
        "VALUES ('pl-6', 'c-6', 'Fridge', '2026-01-01', '2026-12-01', 12, 1200000, 300000, 900000, 'active')");
    await v6.customStatement(
        "INSERT INTO schedule_lines (erp_plan_id, seq, due_date, amount_poisha, paid_poisha, status) VALUES ('pl-6', 1, '2026-02-01', 100000, 100000, 'paid')");
    await v6.customStatement(
        "INSERT INTO erp_payments (erp_payment_id, customer_id, plan_id, date, amount_poisha, method, source) VALUES ('ep-6', 'c-6', 'pl-6', '2026-02-01', 100000, 'cash', 'office')");
    await v6.customStatement(
        "INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('col-6', 'collection', 'create', '{}', 0)");
    await v6.customStatement('PRAGMA user_version = 6');
    await v6.close();

    final v7 = AppDatabase(NativeDatabase(file));
    final c = (await v7.select(v7.customers).get()).single;
    expect(c.serverId, 'c-6');
    expect(c.detailedAddress, isNull);
    expect(c.erpRiskJson, isNull);
    final plan = (await v7.select(v7.plans).get()).single;
    expect(plan.erpPlanId, 'pl-6');
    expect(plan.kind, 'installment');
    expect(plan.invoiceNo, isNull);
    expect(plan.writtenOffPoisha, 0);
    expect(plan.outstandingPoisha, 900000);
    final line = (await v7.select(v7.scheduleLines).get()).single;
    expect(line.rolled, isFalse);
    expect(line.lateFeePoisha, 0);
    final pay = (await v7.select(v7.erpPayments).get()).single;
    expect(pay.advance, isFalse);
    expect(pay.discountPoisha, 0);
    expect(pay.collectorName, isNull);
    expect((await v7.select(v7.outbox).get()).single.mutationId, 'col-6');
    await v7.close();
    await dir.delete(recursive: true);
  });

  test('migrates a 0.10.x (schema 7) database: branch and assignee columns, a fresh snapshot is asked for, the outbox stays', () async {
    final dir = await Directory.systemTemp.createTemp('mig7');
    final file = File('${dir.path}/app.db');
    final v7 = AppDatabase(NativeDatabase(file));
    await v7.customStatement('SELECT 1');
    await _dropV12(v7);
    await _dropV11(v7);
    await _dropV10(v7);
    await _dropV9(v7);
    await _dropV8(v7);
    await v7.customStatement("INSERT INTO customers (server_id, code, name_bn, assignee_id) VALUES ('c-7', 'C-7', 'গ্রাহক', 'u-1')");
    await v7.customStatement("INSERT INTO sync_state (id, pull_cursor, bootstrap_done) VALUES (1, 's_42', 1)");
    await v7.customStatement(
        "INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('col-7', 'collection', 'create', '{}', 0)");
    await v7.customStatement('PRAGMA user_version = 7');
    await v7.close();

    final v8 = AppDatabase(NativeDatabase(file));
    final c = (await v8.select(v8.customers).get()).single;
    expect(c.serverId, 'c-7');
    expect(c.assigneeId, 'u-1');
    expect(c.branchId, isNull);
    expect(c.assigneeName, isNull);
    final meta = (await v8.select(v8.syncMeta).get()).single;
    expect(meta.bootstrapDone, isFalse); // the next sync bootstraps the whole branch
    expect(meta.pullCursor, 's_42');
    expect((await v8.select(v8.outbox).get()).single.mutationId, 'col-7');
    expect(await v8.select(v8.tasks).get(), isEmpty); // the tasks table came with the same update
    await v8.close();
    await dir.delete(recursive: true);
  });

  test('migrates a 0.11.x (schema 8) database: tasks table is added, customers, the outbox and the finished sync stay', () async {
    final dir = await Directory.systemTemp.createTemp('mig8');
    final file = File('${dir.path}/app.db');
    final v8 = AppDatabase(NativeDatabase(file));
    await v8.customStatement('SELECT 1');
    await _dropV12(v8);
    await _dropV11(v8);
    await _dropV10(v8);
    await _dropV9(v8);
    await v8.customStatement("INSERT INTO customers (server_id, code, name_bn, branch_id, branch_code) VALUES ('c-8', 'C-8', 'গ্রাহক', 'b-1', 'PTK')");
    await v8.customStatement("INSERT INTO sync_state (id, pull_cursor, bootstrap_done) VALUES (1, 's_99', 1)");
    await v8.customStatement(
        "INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('col-8', 'collection', 'create', '{}', 0)");
    await v8.customStatement('PRAGMA user_version = 8');
    await v8.close();

    final v9 = AppDatabase(NativeDatabase(file));
    expect(v9.schemaVersion, 17);
    expect(await v9.select(v9.tasks).get(), isEmpty);
    // The new table works, with its defaults.
    await v9.into(v9.tasks).insert(TasksCompanion.insert(serverId: 't-1', title: 'কাজ', createdAt: DateTime.utc(2026, 11, 18)));
    final t = (await v9.select(v9.tasks).get()).single;
    expect(t.status, 'open');
    expect(t.resolveState, 'none');
    expect(t.eventsJson, '[]');
    expect((await v9.select(v9.customers).get()).single.branchCode, 'PTK');
    final meta = (await v9.select(v9.syncMeta).get()).single;
    expect(meta.bootstrapDone, isTrue); // no new snapshot is forced for tasks
    expect(meta.pullCursor, 's_99');
    expect((await v9.select(v9.outbox).get()).single.mutationId, 'col-8');
    await v9.close();
    await dir.delete(recursive: true);
  });
  test('migrates a 0.12.x / 0.13.0 (schema 9) database: overtime and over-break columns are added with 0, days, tasks and the outbox stay', () async {
    final dir = await Directory.systemTemp.createTemp('mig9');
    final file = File('${dir.path}/app.db');
    final v9 = AppDatabase(NativeDatabase(file));
    await v9.customStatement('SELECT 1');
    await _dropV12(v9);
    await _dropV11(v9);
    await _dropV10(v9);
    await v9.customStatement("INSERT INTO attendance_day (business_date, status, break_min, late_min) VALUES ('2026-11-20', 'off_duty', 70, 25)");
    await v9.customStatement("INSERT INTO tasks (server_id, title, created_at) VALUES ('t-9', 'কাজ', 0)");
    await v9.customStatement("INSERT INTO sync_state (id, pull_cursor, bootstrap_done) VALUES (1, 's_120', 1)");
    await v9.customStatement(
        "INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('col-9', 'collection', 'create', '{}', 0)");
    await v9.customStatement('PRAGMA user_version = 9');
    await v9.close();

    final v10 = AppDatabase(NativeDatabase(file));
    expect(v10.schemaVersion, 17);
    final day = (await v10.select(v10.attendanceDays).get()).single;
    expect(day.businessDate, '2026-11-20');
    expect(day.lateMin, 25);
    expect(day.breakMin, 70);
    expect(day.overtimeMin, 0); // filled by the next pull
    expect(day.overBreakMin, 0);
    // the new columns take values
    await v10.into(v10.attendanceDays).insertOnConflictUpdate(AttendanceDaysCompanion.insert(businessDate: '2026-11-21', status: 'off_duty', overtimeMin: const Value(45), overBreakMin: const Value(12)));
    final today = (await v10.select(v10.attendanceDays).get()).firstWhere((d) => d.businessDate == '2026-11-21');
    expect(today.overtimeMin, 45);
    expect(today.overBreakMin, 12);
    expect((await v10.select(v10.tasks).get()).single.serverId, 't-9');
    final meta = (await v10.select(v10.syncMeta).get()).single;
    expect(meta.bootstrapDone, isTrue); // no new snapshot is forced
    expect(meta.pullCursor, 's_120');
    expect((await v10.select(v10.outbox).get()).single.mutationId, 'col-9');
    await v10.close();
    await dir.delete(recursive: true);
  });

  test('migrates a schema 10 database: schedule lines get paid-on, days late, missed and payments; nothing else moves', () async {
    final dir = await Directory.systemTemp.createTemp('mig10');
    final file = File('${dir.path}/app.db');
    final v10 = AppDatabase(NativeDatabase(file));
    await v10.customStatement('SELECT 1');
    await _dropV12(v10);
    await _dropV11(v10);
    await v10.customStatement("INSERT INTO schedule_lines (erp_plan_id, seq, due_date, amount_poisha, paid_poisha, status) VALUES ('p-1', 1, '2026-10-05', 500000, 500000, 'paid')");
    await v10.customStatement(
        "INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('col-10', 'collection', 'create', '{}', 0)");
    await v10.customStatement('PRAGMA user_version = 10');
    await v10.close();

    final v11 = AppDatabase(NativeDatabase(file));
    expect(v11.schemaVersion, 17);
    final line = (await v11.select(v11.scheduleLines).get()).single;
    expect([line.seq, line.amountPoisha, line.paidPoisha], [1, 500000, 500000]);
    expect(line.paidOn, isNull);
    expect(line.daysLate, 0);
    expect(line.missed, isFalse);
    expect(line.paymentsJson, isNull);
    expect((await v11.select(v11.outbox).get()).single.mutationId, 'col-10');
    await v11.close();
    await dir.delete(recursive: true);
  });
  test('migrates a schema 11 database: the colleagues table is added, the outbox, own rows and the finished sync stay', () async {
    final dir = await Directory.systemTemp.createTemp('mig11');
    final file = File('${dir.path}/app.db');
    final v11 = AppDatabase(NativeDatabase(file));
    await v11.customStatement('SELECT 1');
    await _dropV12(v11);
    await v11.customStatement(
        "INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('col-11', 'collection', 'create', '{}', 0)");
    await v11.customStatement("INSERT INTO promises (client_id, customer_id, promised_date, promised_amount_poisha, created_at) VALUES ('pr-1', 'c-1', '2026-11-25', 100000, 0)");
    await v11.customStatement('INSERT INTO sync_state (id, bootstrap_done) VALUES (1, 1)');
    await v11.customStatement('PRAGMA user_version = 11');
    await v11.close();

    final v12 = AppDatabase(NativeDatabase(file));
    expect(v12.schemaVersion, 17);
    expect(await v12.select(v12.colleagueActivities).get(), isEmpty);
    expect((await v12.select(v12.outbox).get()).single.mutationId, 'col-11');
    expect((await v12.select(v12.promises).get()).single.clientId, 'pr-1');
    expect((await v12.select(v12.syncMeta).get()).single.bootstrapDone, isTrue);
    await v12.close();
    await dir.delete(recursive: true);
  });
  test('migrates a phone that ran a build from the middle of schema 12: the missing columns are added, nothing is lost', () async {
    final dir = await Directory.systemTemp.createTemp('mig12');
    final file = File('${dir.path}/app.db');
    final v12 = AppDatabase(NativeDatabase(file));
    await v12.customStatement('SELECT 1');
    // That build had the colleagues table but not the later columns.
    await _dropV14(v12);
    await v12.customStatement('ALTER TABLE promises DROP COLUMN created_by_name');
    for (final c in ['previous_amount_poisha', 'voided_kind', 'voided_by_name', 'voided_reason']) {
      await v12.customStatement('ALTER TABLE collections DROP COLUMN $c');
    }
    await v12.customStatement('ALTER TABLE colleague_activities DROP COLUMN voided_kind');
    await v12.customStatement("INSERT INTO promises (client_id, customer_id, promised_date, promised_amount_poisha, created_at) VALUES ('pr-12', 'c-1', '2026-11-25', 100000, 0)");
    await v12.customStatement("INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('col-12', 'collection', 'create', '{}', 0)");
    await v12.customStatement('PRAGMA user_version = 12');
    await v12.close();

    final v13 = AppDatabase(NativeDatabase(file));
    expect(v13.schemaVersion, 17);
    expect((await v13.select(v13.promises).get()).single.createdByName, isNull);
    expect(await v13.select(v13.collections).get(), isEmpty);
    expect(await v13.select(v13.colleagueActivities).get(), isEmpty);
    expect((await v13.select(v13.outbox).get()).single.mutationId, 'col-12');
    await v13.close();
    await dir.delete(recursive: true);
  });
  test('migrates a schema 13 database: deposit columns are added, an unsent deposit, its outbox row and the collections stay', () async {
    final dir = await Directory.systemTemp.createTemp('mig13');
    final file = File('${dir.path}/app.db');
    final v13 = AppDatabase(NativeDatabase(file));
    await v13.customStatement('SELECT 1');
    await _dropV14(v13);
    await v13.customStatement(
        'INSERT INTO collections (client_id, customer_id, customer_name, customer_code, amount_poisha, method, receipt_no, recorded_at, device_time, business_date, status, sync_state) '

        "VALUES ('col-13', 'c-1', 'A', 'C-1', 150000, 'bkash', 'R-13', 0, 0, '2026-11-15', 'received', 'synced')");
    await v13.customStatement("INSERT INTO deposits (client_id, amount_poisha, destination, deposited_at, status, sync_state) VALUES ('dep-13', 300000, 'branch_cashier', 0, 'pending', 'queued')");
    await v13.customStatement("INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('dep-13', 'deposit', 'create', '{}', 0)");
    await v13.customStatement('PRAGMA user_version = 13');
    await v13.close();

    final v14 = AppDatabase(NativeDatabase(file));
    expect(v14.schemaVersion, 17);
    final c = (await v14.select(v14.collections).get()).single;
    expect([c.clientId, c.amountPoisha, c.depositId, c.depositedAt], ['col-13', 150000, null, null]);
    final d = (await v14.select(v14.deposits).get()).single;
    expect([d.clientId, d.amountPoisha, d.syncState, d.collectionCount, d.nonCashPoisha, d.nonCashCount, d.failureCode], ['dep-13', 300000, 'queued', null, null, null, null]);
    final ob = (await v14.select(v14.outbox).get()).single;
    expect([ob.mutationId, ob.state], ['dep-13', 'pending']);
    await v14.close();
    await dir.delete(recursive: true);
  });

  test('migrates a schema 14 database: the places table is added, unsent work and the outbox stay', () async {
    final dir = await Directory.systemTemp.createTemp('mig14');
    final file = File('${dir.path}/app.db');
    final v14 = AppDatabase(NativeDatabase(file));
    await v14.customStatement('SELECT 1');
    await _dropV15(v14);
    await v14.customStatement("INSERT INTO deposits (client_id, amount_poisha, destination, deposited_at, status, sync_state) VALUES ('dep-14', 300000, 'branch_cashier', 0, 'pending', 'queued')");
    await v14.customStatement("INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('dep-14', 'deposit', 'create', '{}', 0)");
    await v14.customStatement('PRAGMA user_version = 14');
    await v14.close();

    final v15 = AppDatabase(NativeDatabase(file));
    expect(v15.schemaVersion, 17);
    expect(await v15.select(v15.mapPlaces).get(), isEmpty);
    // the new table works: a place made offline is stored with its queued create
    await v15.into(v15.mapPlaces).insert(MapPlacesCompanion.insert(localId: 'c-1', clientId: const Value('c-1'), name: 'করিম স্টোর', icon: 'shop', lat: 22.7, lng: 90.37, createState: const Value('queued')));
    expect((await v15.select(v15.mapPlaces).get()).single.createState, 'queued');
    expect((await v15.select(v15.deposits).get()).single.syncState, 'queued');
    expect((await v15.select(v15.outbox).get()).single.mutationId, 'dep-14');
    await v15.close();
    await dir.delete(recursive: true);
  });

  test('migrates a schema 15 database: activity and referrer columns are added empty, customers, payments and the outbox stay', () async {
    final dir = await Directory.systemTemp.createTemp('mig15');
    final file = File('${dir.path}/app.db');
    final v15 = AppDatabase(NativeDatabase(file));
    await v15.customStatement('SELECT 1');
    await _dropV16(v15);
    await v15.customStatement("INSERT INTO customers (server_id, code, name_bn) VALUES ('c-15', 'BRL-15', 'করিম')");
    await v15.customStatement("INSERT INTO erp_payments (erp_payment_id, customer_id, date, amount_poisha, method, source) VALUES ('e-15', 'c-15', '2026-11-03', 50000, 'cash', 'office')");
    await v15.customStatement("INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('m-15', 'visit', 'create', '{}', 0)");
    await v15.customStatement('PRAGMA user_version = 15');
    await v15.close();

    final v16 = AppDatabase(NativeDatabase(file));
    expect(v16.schemaVersion, 17);
    final c = (await v16.select(v16.customers).get()).single;
    expect([c.serverId, c.activityJson], ['c-15', null]);
    final p = (await v16.select(v16.erpPayments).get()).single;
    expect([p.erpPaymentId, p.referrerName], ['e-15', null]);
    expect((await v16.select(v16.outbox).get()).single.mutationId, 'm-15');
    // the new columns work
    await v16.customStatement("UPDATE erp_payments SET referrer_name = 'সালমা' WHERE erp_payment_id = 'e-15'");
    expect((await v16.select(v16.erpPayments).get()).single.referrerName, 'সালমা');
    await v16.close();
    await dir.delete(recursive: true);
  });

  test('migrates a schema 16 database: photo error and promise chain columns are added, queued photos, promises and the outbox stay', () async {
    final dir = await Directory.systemTemp.createTemp('mig16');
    final file = File('${dir.path}/app.db');
    final v16 = AppDatabase(NativeDatabase(file));
    await v16.customStatement('SELECT 1');
    await _dropV17(v16);
    await v16.customStatement(
        "INSERT INTO media_queue (client_id, kind, local_path, sha256, size_bytes, captured_at, owner_entity, owner_client_id, state, attempts, next_attempt_at) VALUES ('md-16', 'selfie', '/x/md-16.jpg', 'ab', 10, 0, 'attendance_event', 'a-16', 'failed', 7, 900)");
    await v16.customStatement("INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('a-16', 'attendance_event', 'create', '{}', 0)");
    await v16.customStatement("INSERT INTO promises (client_id, server_id, customer_id, promised_date, promised_amount_poisha, status, created_at, sync_state) VALUES ('p-16', 'promise-p-16', 'c-16', '2026-11-20', 50000, 'broken', 0, 'synced')");
    await v16.customStatement('PRAGMA user_version = 16');
    await v16.close();

    final v17 = AppDatabase(NativeDatabase(file));
    expect(v17.schemaVersion, 17);
    final m = (await v17.select(v17.mediaQueue).get()).single;
    expect([m.clientId, m.state, m.attempts, m.lastError, m.lastAttemptAt], ['md-16', 'failed', 7, null, null]);
    expect((await v17.select(v17.outbox).get()).single.mutationId, 'a-16');
    final p = (await v17.select(v17.promises).get()).single;
    expect([p.clientId, p.status, p.followUpOf, p.attempt], ['p-16', 'broken', null, 1]);
    // the prospects table exists and works
    await v17.into(v17.prospects).insert(ProspectsCompanion.insert(clientId: 'pr-1', name: 'জামাল', createdAt: DateTime.utc(2026, 11, 23)));
    expect((await v17.select(v17.prospects).get()).single.syncState, 'queued');
    await v17.customStatement("UPDATE media_queue SET last_error = 'presign:VALIDATION_FAILED' WHERE client_id = 'md-16'");
    expect((await v17.select(v17.mediaQueue).get()).single.lastError, 'presign:VALIDATION_FAILED');
    await v17.close();
    await dir.delete(recursive: true);
  });
}

/// What schema 17 (FR-M-069, FR-M-072) added: why a photo upload failed and when it was last tried; the promise
/// follow-up chain; the prospects table.
Future<void> _dropV17(AppDatabase db) async {
  await db.customStatement('ALTER TABLE media_queue DROP COLUMN last_error');
  await db.customStatement('ALTER TABLE media_queue DROP COLUMN last_attempt_at');
  await db.customStatement('ALTER TABLE promises DROP COLUMN follow_up_of');
  await db.customStatement('ALTER TABLE promises DROP COLUMN attempt');
  await db.customStatement('DROP TABLE prospects');
}

/// What schema 16 (contract 1.44.0, FR-M-068) added: the server's month activity and the payment referrer.
Future<void> _dropV16(AppDatabase db) async {
  await _dropV17(db);
  await db.customStatement('ALTER TABLE customers DROP COLUMN activity_json');
  await db.customStatement('ALTER TABLE erp_payments DROP COLUMN referrer_name');
}

/// What schema 15 (contract 1.38.0, FR-PLC-001) added: the map places table. A file older than 15 has nothing of 16.
Future<void> _dropV15(AppDatabase db) async {
  await _dropV16(db);
  await db.customStatement('DROP TABLE map_places');
}

/// What schema 14 (contract 1.35.0, FR-M-059) added: the deposit that handed a collection in, and
/// what a deposit took besides cash.
Future<void> _dropV14(AppDatabase db) async {
  await _dropV16(db);
  for (final c in ['deposit_id', 'deposited_at']) {
    await db.customStatement('ALTER TABLE collections DROP COLUMN $c');
  }
  for (final c in ['collection_count', 'non_cash_poisha', 'non_cash_count', 'failure_code']) {
    await db.customStatement('ALTER TABLE deposits DROP COLUMN $c');
  }
}

/// What schema 12 (contract 1.31.0) added: colleagues' visits, promises and collections.
/// A file older than 12 has nothing of 14 either.
Future<void> _dropV12(AppDatabase db) async {
  await _dropV14(db);
  await db.customStatement('DROP TABLE colleague_activities');
  await db.customStatement('ALTER TABLE promises DROP COLUMN created_by_name');
  for (final c in ['previous_amount_poisha', 'voided_kind', 'voided_by_name', 'voided_reason']) {
    await db.customStatement('ALTER TABLE collections DROP COLUMN $c');
  }
}

/// What schema 11 (contract 1.14.0 fields) added: the ERP's paid-on, days late, missed and payments per line.
Future<void> _dropV11(AppDatabase db) async {
  for (final c in ['paid_on', 'days_late', 'missed', 'payments_json']) {
    await db.customStatement('ALTER TABLE schedule_lines DROP COLUMN $c');
  }
}

/// What schema 9 (0.12.0, contract 1.20.0) added: the tasks table.
Future<void> _dropV9(AppDatabase db) => db.customStatement('DROP TABLE tasks');

/// What schema 10 (0.13.x, contract 1.25.0) added: the server's overtime and over-break minutes on a day.
Future<void> _dropV10(AppDatabase db) async {
  for (final c in ['overtime_min', 'over_break_min']) {
    await db.customStatement('ALTER TABLE attendance_day DROP COLUMN $c');
  }
}

/// What schema 7 (0.10.0, contract 1.13.0) added: the real ERP shape on the cached tables.
Future<void> _dropV7(AppDatabase db) async {
  for (final c in ['detailed_address', 'directions', 'erp_risk_json']) {
    await db.customStatement('ALTER TABLE customers DROP COLUMN $c');
  }
  for (final c in ['kind', 'invoice_no', 'sale_date', 'frequency', 'custom_days', 'items_json', 'guarantor_json', 'written_off_poisha']) {
    await db.customStatement('ALTER TABLE plans DROP COLUMN $c');
  }
  for (final c in ['late_fee_poisha', 'rolled']) {
    await db.customStatement('ALTER TABLE schedule_lines DROP COLUMN $c');
  }
  for (final c in ['method_label', 'collector_name', 'advance', 'discount_poisha']) {
    await db.customStatement('ALTER TABLE erp_payments DROP COLUMN $c');
  }
}

/// What schema 8 (0.11.0, contract 1.19.0) added: a customer's branch and assignee name.
Future<void> _dropV8(AppDatabase db) async {
  for (final c in ['branch_id', 'branch_code', 'branch_name_bn', 'branch_name_en', 'assignee_name']) {
    await db.customStatement('ALTER TABLE customers DROP COLUMN $c');
  }
}
