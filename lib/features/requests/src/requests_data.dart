import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/colleague_activity.dart' show savedUserId;
import '../../../core/media/media.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/sync/outbox.dart';
import '../../../core/sync/sync_handlers.dart';
import 'requests_domain.dart';

/// Staff requests (FR-M-075, contract 1.48.0, field-api ADR-066): data, sync and the use cases.
///
/// * Mine are saved on the phone at once and queued as the `request` mutation (idempotent by clientId). With
///   photos the mutation waits `held` until every photo is on the server, then goes with `photoMediaIds`.
/// * Comments are saved at once and queued as `request_comment` (waiting for the request when it is unsent).
/// * The pull entity `request` brings mine and those the office gave me, with the server's timeline.

/// Media owner entity of a request's photos.
const requestMediaOwner = 'request';

/// Photo kind sent to `POST /media/upload-url`. Contract 1.48.0 adds no kind for requests; a field photo of the
/// enum (`visit_photo`) is used (ADR-M38).
const requestPhotoKind = 'visit_photo';

String? _nameOf(Object? o) {
  if (o is! Map) return null;
  final n = o['name'];
  if (n is String) return n;
  if (n is Map) return (n['bn'] ?? n['en']) as String?;
  return null;
}

DateTime? _time(Object? v) => v is String ? DateTime.tryParse(v)?.toUtc() : null;

class RequestPullHandler implements PullHandler {
  @override
  String get entity => 'request';

  @override
  Future<void> upsert(AppDatabase db, String id, Json d) async {
    final clientId = d['clientId'] as String?;
    final existing = await (db.select(db.staffRequests)
          ..where((t) => t.serverId.equals(id) | (clientId == null ? const Constant(false) : t.clientId.equals(clientId))))
        .getSingleOrNull();
    final key = existing?.clientId ?? clientId ?? id;
    final by = d['createdBy'];
    final assignee = d['assignee'];
    final customer = d['customer'];
    final photos = d['photoMediaIds'] as List?;
    final events = d['timeline'] as List?;
    await db.into(db.staffRequests).insertOnConflictUpdate(StaffRequestsCompanion(
          clientId: Value(key),
          serverId: Value(id),
          type: Value((d['type'] as String?) ?? existing?.type ?? 'request'),
          priority: Value((d['priority'] as String?) ?? existing?.priority ?? 'normal'),
          title: Value((d['title'] as String?) ?? existing?.title ?? ''),
          details: Value((d['body'] as String?) ?? existing?.details ?? ''),
          customerId: Value(customer is Map ? customer['id'] as String? : (d['customerId'] as String?) ?? existing?.customerId),
          customerName: Value(customer is Map ? _nameOf(customer) : existing?.customerName),
          status: Value((d['status'] as String?) ?? 'open'),
          createdById: Value(by is Map ? by['id'] as String? : (d['createdById'] as String?) ?? existing?.createdById),
          createdByName: Value(_nameOf(by) ?? existing?.createdByName),
          assigneeId: Value(assignee is Map ? assignee['id'] as String? : d['assigneeId'] as String?),
          assigneeName: Value(_nameOf(assignee)),
          currentQueue: Value(d['currentQueue'] as String?),
          level: Value(d['level'] as String?),
          photoIdsJson: Value(jsonEncode([for (final p in photos ?? const []) p is Map ? p['id'] : p])),
          eventsJson: Value(jsonEncode(events ?? const [])),
          createdAt: Value(_time(d['createdAt']) ?? existing?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)),
          updatedAt: Value(_time(d['updatedAt'])),
          seenAt: Value(existing?.seenAt),
          syncState: const Value('synced'),
          errorCode: const Value(null),
        ));
    // My comments the server's timeline now holds are no longer needed (sent ones only; CLAUDE.md §2.3).
    final onServer = {
      for (final e in events ?? const [])
        if (e is Map && e['clientId'] is String) e['clientId'] as String,
    };
    if (onServer.isNotEmpty) {
      await (db.delete(db.requestComments)..where((t) => t.clientId.isIn(onServer) & t.syncState.equals('synced'))).go();
    }
  }

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) async {
    final row = await (db.select(db.staffRequests)..where((t) => t.serverId.equals(id))).getSingleOrNull();
    if (row == null || row.syncState == 'queued') return;
    // Never drop it while a comment of mine on it is unsent.
    final unsent = await (db.select(db.requestComments)..where((t) => t.requestClientId.equals(row.clientId) & t.syncState.isNotValue('synced'))).get();
    if (unsent.isNotEmpty) return;
    await (db.delete(db.requestComments)..where((t) => t.requestClientId.equals(row.clientId))).go();
    await (db.delete(db.staffRequests)..where((t) => t.clientId.equals(row.clientId))).go();
  }
}

String? _refusalCode(SyncPushResult r) {
  final details = r.error?.details;
  final rule = details?['rule'] ?? details?['reason'];
  return rule is String ? rule : r.error?.code ?? r.conflictCode;
}

class RequestPushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'request', 'request_comment'};

  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) async {
    final rejected = r.result == 'rejected' || r.result == 'conflict';
    if (m.entity == 'request') {
      await (db.update(db.staffRequests)..where((t) => t.clientId.equals(m.mutationId))).write(StaffRequestsCompanion(
            syncState: Value(rejected ? 'failed' : 'synced'),
            errorCode: Value(rejected ? _refusalCode(r) : null),
            serverId: !rejected && r.entityId != null ? Value(r.entityId) : const Value.absent(),
          ));
    } else {
      await (db.update(db.requestComments)..where((t) => t.clientId.equals(m.mutationId))).write(RequestCommentsCompanion(
            syncState: Value(rejected ? 'failed' : 'synced'),
            errorCode: Value(rejected ? _refusalCode(r) : null),
          ));
    }
  }
}

/// Media hook (owner `request`): once every photo of the request is on the server, its held `request` mutation
/// goes with `photoMediaIds`. A photo still waiting keeps it held; a second call does nothing (already released).
Future<void> linkRequestPhotos(OutboxWriter w, AppDatabase db, String requestClientId, List<String> serverMediaIds) async {
  final waiting = await (db.select(db.mediaQueue)
        ..where((t) => t.ownerEntity.equals(requestMediaOwner) & t.ownerClientId.equals(requestClientId) & t.state.isNotValue('confirmed')))
      .get();
  if (waiting.isNotEmpty) return;
  await w.release(requestClientId, {'photoMediaIds': serverMediaIds});
}

/// My user id as saved at sign-in.
final _myIdProvider = StreamProvider<String?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.kvWatch('my_user_id').map((raw) => raw == null ? null : jsonDecode(raw) as String?);
});

final _rowsProvider = StreamProvider<List<StaffRequestRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.staffRequests)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
});

final _commentsProvider = StreamProvider<List<RequestCommentRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.requestComments)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).watch();
});

/// Photos of requests still on this phone, per request.
final _localPhotosProvider = StreamProvider<Map<String, int>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.mediaQueue)..where((t) => t.ownerEntity.equals(requestMediaOwner) & t.state.isNotValue('confirmed'))).watch().map((rows) {
    final m = <String, int>{};
    for (final r in rows) {
      m[r.ownerClientId] = (m[r.ownerClientId] ?? 0) + 1;
    }
    return m;
  });
});

/// Every request on the phone (mine and given to me), newest first.
final requestsProvider = Provider<List<StaffRequest>>((ref) {
  final rows = ref.watch(_rowsProvider).value ?? const <StaffRequestRow>[];
  final comments = ref.watch(_commentsProvider).value ?? const <RequestCommentRow>[];
  final photos = ref.watch(_localPhotosProvider).value ?? const <String, int>{};
  final me = ref.watch(_myIdProvider).value;
  final byRequest = <String, List<RequestCommentRow>>{};
  for (final c in comments) {
    (byRequest[c.requestClientId] ??= []).add(c);
  }
  return [
    for (final r in rows) StaffRequest(r, me: me, myComments: byRequest[r.clientId] ?? const [], localPhotos: photos[r.clientId] ?? 0),
  ];
});

final requestProvider = Provider.family<StaffRequest?, String>((ref, key) => ref.watch(requestsProvider).where((r) => r.key == key).firstOrNull);

/// Requests with a step by someone else I have not opened yet (alerts behind the bell).
final requestsWithNewsProvider = Provider<List<StaffRequest>>((ref) => [
      for (final r in ref.watch(requestsProvider))
        if ((r.mine || r.assignedToMe) && r.unseenChange != null) r,
    ]);

class RequestService {
  RequestService(this._ref);
  final Ref _ref;
  AppDatabase get _db => _ref.read(databaseProvider);

  /// Saves a new request offline-first and queues it. Returns its clientId (generated once, here).
  /// [photos] are raw camera bytes (camera only, CLAUDE.md §2.5); with photos the mutation is held until they
  /// are uploaded.
  Future<String> create(RequestDraft input, {List<Uint8List> photos = const []}) async {
    final v = validateRequest((type: input.type, priority: input.priority, title: input.title, details: input.details, customerId: input.customerId, customerName: input.customerName, photoCount: photos.length));
    if (v.error != null) throw RequestInvalid(v.error!);
    final d = v.draft!;
    final id = const Uuid().v7();
    final now = _ref.read(clockProvider).nowUtc();
    final me = await savedUserId(_db);
    final wm = await _watermark(now);
    final processed = [for (final p in photos) await processPhoto(p, watermark: wm)];
    await _db.transaction(() async {
      await _db.into(_db.staffRequests).insert(StaffRequestsCompanion.insert(
            clientId: id,
            type: d.type.wire,
            priority: Value(d.priority.wire),
            title: d.title,
            details: Value(d.details),
            customerId: Value(d.customerId),
            customerName: Value(d.customerName),
            createdById: Value(me),
            createdAt: now,
            seenAt: Value(now),
          ));
      for (final p in processed) {
        await _ref.read(mediaServiceProvider).enqueue(photo: p, kind: requestPhotoKind, ownerEntity: requestMediaOwner, ownerClientId: id);
      }
      await _ref.read(outboxWriterProvider).enqueue(mutationId: id, entity: 'request', held: processed.isNotEmpty, payload: requestPayload(id, d));
    });
    if (processed.isNotEmpty) unawaited(_ref.read(mediaServiceProvider).uploadPending().catchError((Object _) {}));
    _kick();
    return id;
  }

  /// Saves my comment offline-first and queues it (`request_comment`). Returns its clientId.
  Future<String> comment(String requestKey, String text) async {
    final v = validateComment(text);
    if (v.error != null) throw RequestInvalid(v.error!);
    final row = await (_db.select(_db.staffRequests)..where((t) => t.clientId.equals(requestKey))).getSingleOrNull();
    if (row == null || row.syncState == 'failed' || row.status == 'closed') throw const RequestInvalid(RequestError.notOpen);
    final id = const Uuid().v7();
    final now = _ref.read(clockProvider).nowUtc();
    await _db.transaction(() async {
      await _db.into(_db.requestComments).insert(RequestCommentsCompanion.insert(clientId: id, requestClientId: requestKey, body: v.text!, createdAt: now));
      await _ref.read(outboxWriterProvider).enqueue(
            mutationId: id,
            entity: 'request_comment',
            // Unsent request: the comment waits for it and names it by its clientId.
            dependsOn: row.serverId == null ? [row.clientId] : const [],
            payload: {
              'clientId': id,
              if (row.serverId != null) 'requestId': row.serverId else 'requestClientId': row.clientId,
              'text': v.text,
            },
          );
      await (_db.update(_db.staffRequests)..where((t) => t.clientId.equals(requestKey))).write(StaffRequestsCompanion(seenAt: Value(now)));
    });
    _kick();
    return id;
  }

  /// Reopens my resolved or closed request with a note: online only (POST /requests/{id}/reopen, contract 1.48.0;
  /// there is no sync mutation for it, ADR-M08). The answer is stored like a pull. Throws [ApiException] when the
  /// server cannot be reached or refuses.
  Future<void> reopen(String requestKey, String note) async {
    final v = validateReopenNote(note);
    if (v.error != null) throw RequestInvalid(v.error!);
    final row = await (_db.select(_db.staffRequests)..where((t) => t.clientId.equals(requestKey))).getSingleOrNull();
    if (row?.serverId == null) throw const RequestInvalid(RequestError.notOpen);
    final r = await _ref.read(fieldApiProvider).reopenRequest(row!.serverId!, note: v.text!);
    await _db.transaction(() => RequestPullHandler().upsert(_db, row.serverId!, r));
    await markSeen(requestKey);
  }

  /// Opening a request clears its alert.
  Future<void> markSeen(String requestKey) async {
    final now = _ref.read(clockProvider).nowUtc();
    await (_db.update(_db.staffRequests)..where((t) => t.clientId.equals(requestKey))).write(StaffRequestsCompanion(seenAt: Value(now)));
  }

  Future<String> _watermark(DateTime at) async {
    final user = await _ref.read(secureStoreProvider).read('session_user');
    final code = user == null ? '' : ((jsonDecode(user) as Map)['employeeCode'] ?? '').toString();
    final f = _ref.read(fmtProvider);
    return '${f.dateTime(at).replaceAll(RegExp('[^\\x00-\\x7F]'), '')} $code'.trim();
  }

  void _kick() => _ref.read(syncEngineProvider).kick(reason: 'request').ignore();
}

final requestServiceProvider = Provider<RequestService>(RequestService.new);
