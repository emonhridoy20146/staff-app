import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../auth/secure_store.dart';

const _dbKeyName = 'db_key_v1';

/// Opens the encrypted on-device database.
///
/// The 256-bit key is random, generated once and kept in Keystore-backed
/// secure storage (FR-M-015). The cipher comes from SQLite3MultipleCiphers
/// selected in pubspec `hooks.user_defines`.
Future<QueryExecutor> openEncryptedDatabase(SecureStore store) async {
  var key = await store.read(_dbKeyName);
  if (key == null) {
    final r = Random.secure();
    key = List.generate(32, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    await store.write(_dbKeyName, key);
  }
  final dir = await getApplicationSupportDirectory();
  final file = File(p.join(dir.path, 'fos_staff.db'));
  final hexKey = key;
  return NativeDatabase.createInBackground(
    file,
    setup: (db) {
      db.execute("PRAGMA key = \"x'$hexKey'\";");
      // Fails fast if the key is wrong or the cipher is missing.
      db.execute('SELECT count(*) FROM sqlite_master;');
      db.execute('PRAGMA journal_mode = WAL;');
    },
  );
}

/// In-memory database for tests and the demo flavour.
QueryExecutor openMemoryDatabase() => NativeDatabase.memory();

/// Deletes the database file (logout wipe after the queue is empty).
Future<void> deleteDatabaseFile() async {
  final dir = await getApplicationSupportDirectory();
  for (final suffix in ['', '-wal', '-shm']) {
    final f = File(p.join(dir.path, 'fos_staff.db$suffix'));
    if (f.existsSync()) await f.delete();
  }
}
