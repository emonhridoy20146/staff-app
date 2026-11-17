import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';

/// Every released schema upgrades to the current one (v6, 0.9.0) and
/// existing rows survive.
void main() {
  test('migrates a 0.1.0 database to the current schema without losing outbox rows', () async {
    final dir = await Directory.systemTemp.createTemp('mig');
    final file = File('${dir.path}/app.db');

    // Build a v1-shaped file: current schema minus what v2 added.
    final v1 = AppDatabase(NativeDatabase(file));
    await v1.customStatement('SELECT 1');
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
    expect(v2.schemaVersion, 6);
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
}
