import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/sync/sync_handlers.dart';
import '../../auth/auth.dart';

/// Map places (master FR-PLC-001..006, contract 1.38.0, field-api ADR-051).
///
/// A place is a name on the map with one of a few icons and an optional note,
/// seen by everyone of the branch. Adding one works offline: the row is saved
/// here at once (its `localId` is my clientId) and sent as the `place`
/// mutation; the server id comes back with the push result and the next pull.
/// I may change the words of places I made (`place_edit`) and ask the office
/// to move any place (`place_move_request`): the marker moves only when the
/// office approves.

/// The fixed icon list, in the order the picker shows them.
const placeIcons = ['shop', 'market', 'mosque', 'school', 'bank', 'hospital', 'bus_stop', 'office', 'landmark', 'other'];
const placeNameMax = 60;
const placeNoteMax = 200;

class PlacePullHandler implements PullHandler {
  @override
  String get entity => 'place';

  @override
  Future<void> upsert(AppDatabase db, String id, Json d) async {
    final clientId = d['clientId'] as String?;
    // My own place made offline is matched by its clientId the first time the server sends it.
    final existing = await (db.select(db.mapPlaces)..where((t) => t.serverId.equals(id) | (clientId == null ? const Constant(false) : t.clientId.equals(clientId)))).getSingleOrNull();
    final loc = d['location'] as Json? ?? const {};
    final by = d['createdBy'];
    // An edit of mine that is not sent yet wins over what the server had before it.
    final keepWords = existing != null && existing.editState == 'queued';
    final pending = d['pendingMove'];
    final row = MapPlacesCompanion(
      localId: Value(existing?.localId ?? id),
      serverId: Value(id),
      clientId: Value(clientId ?? existing?.clientId),
      branchId: Value(d['branchId'] as String?),
      name: Value(keepWords ? existing.name : (d['name'] as String?) ?? ''),
      icon: Value(keepWords ? existing.icon : (d['icon'] as String?) ?? 'other'),
      note: Value(keepWords ? existing.note : d['note'] as String?),
      lat: Value((loc['lat'] as num?)?.toDouble() ?? existing?.lat ?? 0),
      lng: Value((loc['lng'] as num?)?.toDouble() ?? existing?.lng ?? 0),
      version: Value((d['version'] as num?)?.toInt() ?? 0),
      createdById: Value(by is Map ? by['id'] as String? : null),
      createdByName: Value(by is Map ? by['name'] as String? : null),
      pendingMoveJson: Value(pending == null ? null : jsonEncode(pending)),
      lastDecisionJson: Value(d['lastMoveDecision'] == null ? null : jsonEncode(d['lastMoveDecision'])),
      updatedAt: Value(d['updatedAt'] == null ? null : DateTime.parse(d['updatedAt'] as String).toUtc()),
      createState: const Value('synced'),
      // The server now shows my request (or already decided it): nothing of mine is waiting.
      moveState: Value(existing?.moveState == 'queued' ? 'queued' : existing?.moveState == 'failed' ? 'failed' : 'none'),
    );
    await db.into(db.mapPlaces).insertOnConflictUpdate(existing == null ? row : row.copyWith(createMutationId: Value(existing.createMutationId)));
  }

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) =>
      // Removed by the office or out of my branches. Never drop something of mine that is still waiting to be sent.
      (db.delete(db.mapPlaces)..where((t) => t.serverId.equals(id) & t.createState.equals('queued').not() & t.editState.equals('queued').not() & t.moveState.equals('queued').not())).go();
}

class PlacePushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'place', 'place_edit', 'place_move_request'};

  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) async {
    final rejected = r.result == 'rejected' || r.result == 'conflict';
    final code = rejected ? _codeOf(r) : null;
    switch (m.entity) {
      case 'place':
        await (db.update(db.mapPlaces)..where((t) => t.createMutationId.equals(m.mutationId))).write(MapPlacesCompanion(
              createState: Value(rejected ? 'failed' : 'synced'),
              errorCode: Value(code),
              serverId: !rejected && r.entityId != null ? Value(r.entityId) : const Value.absent(),
            ));
      case 'place_edit':
        await (db.update(db.mapPlaces)..where((t) => t.editMutationId.equals(m.mutationId) & t.editState.equals('queued'))).write(MapPlacesCompanion(
              editState: Value(rejected ? 'failed' : 'none'),
              errorCode: Value(code),
            ));
      case 'place_move_request':
        await (db.update(db.mapPlaces)..where((t) => t.moveMutationId.equals(m.mutationId) & t.moveState.equals('queued'))).write(MapPlacesCompanion(
              moveState: Value(rejected ? 'failed' : 'sent'),
              errorCode: Value(code),
            ));
    }
  }

  static String? _codeOf(SyncPushResult r) {
    final details = r.error?.details;
    final rule = details?['rule'] ?? details?['reason'];
    return rule is String ? rule : r.error?.code ?? r.conflictCode;
  }
}

/// A place on the phone.
class MapPlace {
  const MapPlace(this.row);
  final PlaceRow row;

  String get id => row.localId;
  String get name => row.name;
  String get icon => row.icon;

  /// The server knows it (an edit or move can name it by server id).
  bool get onServer => row.serverId != null;
  bool get createQueued => row.createState == 'queued';
  bool get createFailed => row.createState == 'failed';
  bool get editQueued => row.editState == 'queued';
  bool get editFailed => row.editState == 'failed';

  /// My move request is saved here and waits for the network.
  bool get moveQueued => row.moveState == 'queued';
  bool get moveFailed => row.moveState == 'failed';

  /// Waiting for the office: the server's open request, or mine still on the phone.
  bool get movePending => moveQueued || pendingMove != null;

  bool isMine(String? userId) => row.createdById == null ? row.clientId != null : row.createdById == userId;

  /// Where the marker should go, if someone asked (mine first: it is newer).
  ({double lat, double lng})? get requestedPoint {
    if (moveQueued && row.moveLat != null && row.moveLng != null) return (lat: row.moveLat!, lng: row.moveLng!);
    final loc = pendingMove?['location'];
    return loc is Map ? (lat: (loc['lat'] as num).toDouble(), lng: (loc['lng'] as num).toDouble()) : null;
  }

  Json? get pendingMove => _json(row.pendingMoveJson);
  Json? get lastDecision => _json(row.lastDecisionJson);
  String? get pendingByName => (pendingMove?['requestedBy'] as Map?)?['name'] as String?;

  static Json? _json(String? s) {
    if (s == null) return null;
    try {
      return jsonDecode(s) as Json;
    } on FormatException {
      return null;
    }
  }
}

/// Every place on the phone (they are all the branch's; the server sends nothing else).
final placesProvider = StreamProvider<List<MapPlace>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.mapPlaces)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch().map((rows) => [for (final r in rows) MapPlace(r)]);
});

final placeProvider = StreamProvider.family<MapPlace?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.mapPlaces)..where((t) => t.localId.equals(id))).watchSingleOrNull().map((r) => r == null ? null : MapPlace(r));
});

/// Saving is local first; the outbox sends it (offline-first, CLAUDE.md §2.1).
class PlaceService {
  PlaceService(this._ref);
  final Ref _ref;

  static String? _clean(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }

  /// FR-PLC-002: a new place, visible on my map at once. Returns its local id.
  Future<String> create({required String name, required String icon, String? note, required double lat, required double lng}) async {
    final db = _ref.read(databaseProvider);
    final clientId = const Uuid().v4();
    final mutationId = const Uuid().v7();
    final me = _ref.read(sessionProvider).user;
    final text = _clean(note);
    await db.transaction(() async {
      await db.into(db.mapPlaces).insert(MapPlacesCompanion.insert(
            localId: clientId,
            clientId: Value(clientId),
            branchId: Value(me?.branchIds.firstOrNull),
            name: name.trim(),
            icon: icon,
            note: Value(text),
            lat: lat,
            lng: lng,
            createdById: Value(me?.id),
            createdByName: Value(me?.name.of('bn')),
            updatedAt: Value(_ref.read(clockProvider).nowUtc()),
            createState: const Value('queued'),
            createMutationId: Value(mutationId),
          ));
      await _ref.read(outboxWriterProvider).enqueue(
        mutationId: mutationId,
        entity: 'place',
        payload: {'clientId': clientId, 'name': name.trim(), 'icon': icon, 'note': ?text, 'location': {'lat': lat, 'lng': lng}},
      );
    });
    unawaited(_ref.read(syncEngineProvider).kick(reason: 'place'));
    return clientId;
  }

  /// FR-PLC-003: change the words of my own place. Sent only when something changed.
  Future<void> edit(String localId, {required String name, required String icon, String? note}) async {
    final db = _ref.read(databaseProvider);
    var queued = false;
    await db.transaction(() async {
      final row = await (db.select(db.mapPlaces)..where((t) => t.localId.equals(localId))).getSingleOrNull();
      if (row == null) return;
      final text = _clean(note);
      final change = <String, Object?>{
        if (name.trim() != row.name) 'name': name.trim(),
        if (icon != row.icon) 'icon': icon,
        if (text != row.note) 'note': text,
      };
      if (change.isEmpty) return;
      final mutationId = const Uuid().v7();
      await (db.update(db.mapPlaces)..where((t) => t.localId.equals(localId))).write(MapPlacesCompanion(
            name: Value(name.trim()),
            icon: Value(icon),
            note: Value(text),
            editState: const Value('queued'),
            editMutationId: Value(mutationId),
            errorCode: const Value(null),
          ));
      await _ref.read(outboxWriterProvider).enqueue(
        mutationId: mutationId,
        entity: 'place_edit',
        payload: {..._placeRef(row), ...change},
        dependsOn: [if (row.createState == 'queued' && row.createMutationId != null) row.createMutationId!],
      );
      queued = true;
    });
    if (queued) unawaited(_ref.read(syncEngineProvider).kick(reason: 'place'));
  }

  /// FR-PLC-004: ask the office to move a place's marker. One request at a time; the marker stays.
  Future<bool> requestMove(String localId, {required double lat, required double lng, String? reason}) async {
    final db = _ref.read(databaseProvider);
    var queued = false;
    await db.transaction(() async {
      final row = await (db.select(db.mapPlaces)..where((t) => t.localId.equals(localId))).getSingleOrNull();
      if (row == null || row.moveState == 'queued' || row.pendingMoveJson != null) return;
      final mutationId = const Uuid().v7();
      final text = _clean(reason);
      await (db.update(db.mapPlaces)..where((t) => t.localId.equals(localId))).write(MapPlacesCompanion(
            moveState: const Value('queued'),
            moveMutationId: Value(mutationId),
            moveLat: Value(lat),
            moveLng: Value(lng),
            moveReason: Value(text),
            errorCode: const Value(null),
          ));
      await _ref.read(outboxWriterProvider).enqueue(
        mutationId: mutationId,
        entity: 'place_move_request',
        payload: {..._placeRef(row), 'clientId': const Uuid().v4(), 'location': {'lat': lat, 'lng': lng}, 'reason': ?text},
        dependsOn: [if (row.createState == 'queued' && row.createMutationId != null) row.createMutationId!],
      );
      queued = true;
    });
    if (queued) unawaited(_ref.read(syncEngineProvider).kick(reason: 'place'));
    return queued;
  }

  /// How a mutation names the place: by server id, or by my clientId while the create is not synced.
  static Map<String, String> _placeRef(PlaceRow row) => row.serverId != null ? {'placeId': row.serverId!} : {'placeClientId': row.clientId ?? row.localId};
}

final placeServiceProvider = Provider<PlaceService>(PlaceService.new);
