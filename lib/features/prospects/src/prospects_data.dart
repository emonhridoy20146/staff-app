import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/colleague_activity.dart' show savedUserId;
import '../../../core/location/location_engine.dart';
import '../../../core/providers.dart';
import '../../../core/sync/sync_handlers.dart';
import '../../attendance/attendance.dart';
import '../../customers/customers.dart' show normalizeMobile;

/// Possible customers (prospects, contract 1.45.0, FR-M-073).
///
/// A staff member notes someone who may become a customer: name, phone numbers, address, a note and, only
/// while on duty (CLAUDE.md §2.6), where they are now. Saved on the phone at once (`client_id` = my clientId)
/// and sent as the `prospect` mutation (`op: create`); my own may be changed while the office has not acted on
/// it (status `new`) with `op: update`. The office decides the status; the phone only shows it.

const prospectNameMax = 80;
const prospectAddressMax = 200;
const prospectNoteMax = 500;
const prospectMaxPhones = 3;

enum ProspectError { nameMissing, nameTooLong, phoneMissing, phoneInvalid, phoneRepeated, addressTooLong, noteTooLong, notEditable }

class ProspectInvalid implements Exception {
  const ProspectInvalid(this.error);
  final ProspectError error;
}

/// What the form holds, checked by [validateProspect].
typedef ProspectDraft = ({String name, List<String> phones, String address, String note});

/// The draft cleaned (trimmed, numbers as 01XXXXXXXXX, empties dropped), or the first problem.
({ProspectDraft? draft, ProspectError? error}) validateProspect(ProspectDraft d) {
  final name = d.name.trim();
  if (name.isEmpty) return (draft: null, error: ProspectError.nameMissing);
  if (name.length > prospectNameMax) return (draft: null, error: ProspectError.nameTooLong);
  final typed = [for (final p in d.phones) if (p.trim().isNotEmpty) p.trim()];
  if (typed.isEmpty) return (draft: null, error: ProspectError.phoneMissing);
  final phones = <String>[];
  for (final p in typed.take(prospectMaxPhones)) {
    final n = normalizeMobile(p);
    if (n == null) return (draft: null, error: ProspectError.phoneInvalid);
    if (phones.contains(n)) return (draft: null, error: ProspectError.phoneRepeated);
    phones.add(n);
  }
  final address = d.address.trim();
  if (address.length > prospectAddressMax) return (draft: null, error: ProspectError.addressTooLong);
  final note = d.note.trim();
  if (note.length > prospectNoteMax) return (draft: null, error: ProspectError.noteTooLong);
  return (draft: (name: name, phones: phones, address: address, note: note), error: null);
}

/// A prospect on the phone.
class Prospect {
  const Prospect(this.row, {required this.mine});
  final ProspectRow row;
  final bool mine;
  List<String> get phones => (jsonDecode(row.phonesJson) as List).cast<String>();
  bool get hasLocation => row.lat != null && row.lng != null;

  /// My own, still `new` at the office, and not refused: may be changed.
  bool get editable => mine && row.status == 'new' && row.syncState != 'failed';
  bool get waiting => row.syncState == 'queued' || row.editState == 'queued';
  bool get refused => row.syncState == 'failed' || row.editState == 'failed';
}

class ProspectPullHandler implements PullHandler {
  @override
  String get entity => 'prospect';

  @override
  Future<void> upsert(AppDatabase db, String id, Json d) async {
    final clientId = d['clientId'] as String?;
    final existing = await (db.select(db.prospects)..where((t) => t.serverId.equals(id) | (clientId == null ? const Constant(false) : t.clientId.equals(clientId)))).getSingleOrNull();
    // My edit that is not sent yet wins over what the server had before it.
    final keep = existing != null && existing.editState == 'queued';
    final loc = d['location'];
    final by = d['createdBy'];
    final phones = (d['phones'] as List?)?.map((p) => p is Map ? p['number'] as String? ?? '' : '$p').where((p) => p.isNotEmpty).toList();
    await db.into(db.prospects).insertOnConflictUpdate(ProspectsCompanion(
          clientId: Value(existing?.clientId ?? clientId ?? id),
          serverId: Value(id),
          name: Value(keep ? existing.name : (d['name'] as String?) ?? existing?.name ?? ''),
          phonesJson: Value(keep ? existing.phonesJson : jsonEncode(phones ?? const <String>[])),
          address: Value(keep ? existing.address : d['address'] as String?),
          note: Value(keep ? existing.note : d['note'] as String?),
          lat: Value(loc is Map ? (loc['lat'] as num?)?.toDouble() : existing?.lat),
          lng: Value(loc is Map ? (loc['lng'] as num?)?.toDouble() : existing?.lng),
          accuracyM: Value(loc is Map ? (loc['accuracyM'] as num?)?.toDouble() : existing?.accuracyM),
          status: Value((d['status'] as String?) ?? 'new'),
          createdById: Value(by is Map ? by['id'] as String? : (d['createdById'] as String?) ?? existing?.createdById),
          createdByName: Value(by is Map ? by['name'] as String? : (d['createdByName'] as String?) ?? existing?.createdByName),
          createdAt: Value(d['createdAt'] == null ? existing?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true) : DateTime.parse(d['createdAt'] as String).toUtc()),
          updatedAt: Value(d['updatedAt'] == null ? null : DateTime.parse(d['updatedAt'] as String).toUtc()),
          syncState: const Value('synced'),
          // A refused edit stays visible with its reason (never silently dropped); the words are the server's again.
          editState: Value(keep ? 'queued' : (existing?.editState == 'failed' ? 'failed' : 'none')),
          errorCode: Value(keep || existing?.editState == 'failed' ? existing!.errorCode : null),
        ));
  }

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) =>
      // Never drop one of mine that is still waiting to be sent (CLAUDE.md §2.3).
      (db.delete(db.prospects)..where((t) => t.serverId.equals(id) & t.syncState.equals('queued').not() & t.editState.equals('queued').not())).go();
}

class ProspectPushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'prospect'};

  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) async {
    final rejected = r.result == 'rejected' || r.result == 'conflict';
    final details = r.error?.details;
    final rule = details?['rule'] ?? details?['reason'];
    final code = rejected ? (rule is String ? rule : r.error?.code ?? r.conflictCode) : null;
    if (m.op == 'create') {
      await (db.update(db.prospects)..where((t) => t.clientId.equals(m.mutationId))).write(ProspectsCompanion(
            syncState: Value(rejected ? 'failed' : 'synced'),
            errorCode: Value(code),
            serverId: !rejected && r.entityId != null ? Value(r.entityId) : const Value.absent(),
          ));
      return;
    }
    final target = (jsonDecode(m.payloadJson) as Json)['prospectId'] as String?;
    if (target == null) return;
    await (db.update(db.prospects)..where((t) => (t.serverId.equals(target) | t.clientId.equals(target)) & t.editState.equals('queued'))).write(ProspectsCompanion(
          editState: Value(rejected ? 'failed' : 'none'),
          errorCode: Value(code),
        ));
  }
}

/// Every prospect on the phone, newest first, with whether it is mine.
final prospectsProvider = StreamProvider<List<Prospect>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.prospects)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch().asyncMap((rows) async {
    final me = await savedUserId(db);
    return [for (final r in rows) Prospect(r, mine: r.createdById == null || r.createdById == me)];
  });
});

final prospectProvider = StreamProvider.family<Prospect?, String>((ref, clientId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.prospects)..where((t) => t.clientId.equals(clientId))).watchSingleOrNull().asyncMap((r) async {
    if (r == null) return null;
    final me = await savedUserId(db);
    return Prospect(r, mine: r.createdById == null || r.createdById == me);
  });
});

/// May the form offer "add where I am now"? Only while on duty or on a break (CLAUDE.md §2.6).
final prospectLocationAllowedProvider = Provider<bool>((ref) {
  final s = ref.watch(todayAttendanceProvider).value?.status;
  return s == DayStatus.onDuty || s == DayStatus.onBreak;
});

class ProspectService {
  ProspectService(this._ref);
  final Ref _ref;
  AppDatabase get _db => _ref.read(databaseProvider);

  bool _onDuty() {
    final s = _ref.read(todayAttendanceProvider).value?.status;
    return s == DayStatus.onDuty || s == DayStatus.onBreak;
  }

  /// Saves a new prospect offline-first and queues it. Returns its clientId (generated once, here).
  /// [fix] is used only while on duty; off duty it is dropped (CLAUDE.md §2.6).
  Future<String> create(ProspectDraft input, {GeoFix? fix}) async {
    final v = validateProspect(input);
    if (v.error != null) throw ProspectInvalid(v.error!);
    final d = v.draft!;
    final place = _onDuty() ? fix : null;
    final id = const Uuid().v7();
    final now = _ref.read(clockProvider).nowUtc();
    await _db.transaction(() async {
      await _db.into(_db.prospects).insert(ProspectsCompanion.insert(
            clientId: id,
            name: d.name,
            phonesJson: Value(jsonEncode(d.phones)),
            address: Value(d.address.isEmpty ? null : d.address),
            note: Value(d.note.isEmpty ? null : d.note),
            lat: Value(place?.lat),
            lng: Value(place?.lng),
            accuracyM: Value(place?.accuracyM),
            createdAt: now,
          ));
      await _ref.read(outboxWriterProvider).enqueue(mutationId: id, entity: 'prospect', payload: {
        'clientId': id,
        'name': d.name,
        'phones': d.phones,
        if (d.address.isNotEmpty) 'address': d.address,
        if (d.note.isNotEmpty) 'note': d.note,
        if (place != null) 'location': {'lat': place.lat, 'lng': place.lng, 'accuracyM': place.accuracyM},
        'capturedAt': now.toIso8601String(),
      });
    });
    _kick();
    return id;
  }

  /// Changes the words of my own prospect while it is `new` (`op: update`). Location is not changed here.
  Future<void> update(String clientId, ProspectDraft input) async {
    final row = await (_db.select(_db.prospects)..where((t) => t.clientId.equals(clientId))).getSingleOrNull();
    final me = await savedUserId(_db);
    if (row == null || !Prospect(row, mine: row.createdById == null || row.createdById == me).editable) {
      throw const ProspectInvalid(ProspectError.notEditable);
    }
    final v = validateProspect(input);
    if (v.error != null) throw ProspectInvalid(v.error!);
    final d = v.draft!;
    final id = const Uuid().v7();
    await _db.transaction(() async {
      await (_db.update(_db.prospects)..where((t) => t.clientId.equals(clientId))).write(ProspectsCompanion(
            name: Value(d.name),
            phonesJson: Value(jsonEncode(d.phones)),
            address: Value(d.address.isEmpty ? null : d.address),
            note: Value(d.note.isEmpty ? null : d.note),
            editState: const Value('queued'),
            errorCode: const Value(null),
          ));
      await _ref.read(outboxWriterProvider).enqueue(
        mutationId: id,
        entity: 'prospect',
        op: 'update',
        payload: {
          'clientId': id,
          'prospectId': row.serverId ?? row.clientId,
          'name': d.name,
          'phones': d.phones,
          'address': d.address.isEmpty ? null : d.address,
          'note': d.note.isEmpty ? null : d.note,
        },
        // Not on the server yet: the change waits for the create.
        dependsOn: row.serverId == null ? [row.clientId] : const [],
      );
    });
    _kick();
  }

  void _kick() => _ref.read(syncEngineProvider).kick(reason: 'prospect').ignore();
}

final prospectServiceProvider = Provider<ProspectService>(ProspectService.new);
