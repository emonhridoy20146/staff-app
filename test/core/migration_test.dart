import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';

/// v1 (0.1.0) → v2 (0.2.0): adds contact_attempts and the location_queue
/// time index; existing rows survive.
void main() {
  test('migrates a 0.1.0 database to the current schema without losing outbox rows', () async {
    final dir = await Directory.systemTemp.createTemp('mig');
    final file = File('${dir.path}/app.db');

    // Build a v1-shaped file: current schema minus what v2 added.
    final v1 = AppDatabase(NativeDatabase(file));
    await v1.customStatement('SELECT 1');
    await v1.customStatement('DROP TABLE contact_attempts');
    await v1.customStatement('DROP INDEX IF EXISTS idx_location_queue_t');
    await v1.customStatement('ALTER TABLE location_proposals DROP COLUMN decision_reason');
    await v1.customStatement(
        "INSERT INTO location_proposals (client_id, customer_id, lat, lng, accuracy_m) VALUES ('p-1', 'c-1', 22.7, 90.35, 9)");
    await v1.customStatement(
        "INSERT INTO outbox (mutation_id, entity, op, payload_json, created_at) VALUES ('m-1', 'collection', 'create', '{}', 0)");
    await v1.customStatement('PRAGMA user_version = 1');
    await v1.close();

    final v2 = AppDatabase(NativeDatabase(file));
    expect(v2.schemaVersion, 3);
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
    await v2.customStatement('ALTER TABLE location_proposals DROP COLUMN decision_reason');
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
}
