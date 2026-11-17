import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/sync/sync_handlers.dart';

/// Notices from the office (master FR-NOT-005, FR-M-027, contract 1.12.0).
///
/// They arrive as the `broadcast` sync entity. Tapping "read" is stored on
/// the phone at once and sent as the `broadcast_ack` mutation, so it works
/// without a network like every other field action.
class BroadcastPullHandler implements PullHandler {
  @override
  String get entity => 'broadcast';

  @override
  Future<void> upsert(AppDatabase db, String id, Json d) async {
    final title = I18nText.fromJson(d['title']);
    final body = I18nText.fromJson(d['body']);
    final by = d['createdBy'];
    final existing = await (db.select(db.broadcasts)..where((t) => t.serverId.equals(id))).getSingleOrNull();
    final serverAcked = (d['acked'] as bool?) ?? false;
    final serverAt = d['ackedAt'] == null ? null : DateTime.parse(d['ackedAt'] as String).toUtc();
    // A tap not yet sent stays as it is; otherwise the server is the truth.
    final keepLocal = existing != null && existing.ackedAt != null && existing.ackState != 'synced' && !serverAcked;
    final createdAt = DateTime.parse(d['createdAt'] as String).toUtc();
    // Broadcasts read before 1.12.0 have no read time: the sending time stands in.
    final ackedAt = keepLocal ? existing.ackedAt : (serverAcked ? (serverAt ?? existing?.ackedAt ?? createdAt) : null);
    final state = keepLocal ? existing.ackState : (serverAcked ? 'synced' : 'none');
    await db.into(db.broadcasts).insertOnConflictUpdate(BroadcastsCompanion.insert(
          serverId: id,
          titleBn: title.bn,
          titleEn: Value(title.en),
          bodyBn: body.bn,
          bodyEn: Value(body.en),
          requireAck: Value((d['requireAck'] as bool?) ?? false),
          senderName: Value(by is Map ? by['name'] as String? : null),
          createdAt: createdAt,
          ackedAt: Value(ackedAt),
          ackState: Value(state),
          ackMutationId: Value(existing?.ackMutationId),
        ));
  }

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) =>
      // Never drop a tap that is still waiting to be sent.
      (db.delete(db.broadcasts)..where((t) => t.serverId.equals(id) & t.ackState.equals('queued').not())).go();
}

class BroadcastAckPushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'broadcast_ack'};

  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) =>
      (db.update(db.broadcasts)..where((t) => t.ackMutationId.equals(m.mutationId))).write(
        BroadcastsCompanion(ackState: Value(r.result == 'rejected' ? 'failed' : 'synced')),
      );
}

/// A notice on the phone, in the user's language.
class Notice {
  const Notice(this.row);
  final BroadcastRow row;

  String get id => row.serverId;
  String title(String lang) => lang == 'en' ? (row.titleEn?.isNotEmpty == true ? row.titleEn! : row.titleBn) : row.titleBn;
  String body(String lang) => lang == 'en' ? (row.bodyEn?.isNotEmpty == true ? row.bodyEn! : row.bodyBn) : row.bodyBn;
  bool get read => row.ackedAt != null;

  /// The office asked for a confirmation and I have not given it yet.
  bool get mustRead => row.requireAck && !read;

  /// Read on the phone, still waiting for the network.
  bool get readNotSent => read && row.ackState == 'queued';
}

/// All notices, newest first.
final noticesProvider = StreamProvider<List<Notice>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.broadcasts)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch().map((rows) => [for (final r in rows) Notice(r)]);
});

final noticeProvider = StreamProvider.family<Notice?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.broadcasts)..where((t) => t.serverId.equals(id))).watchSingleOrNull().map((r) => r == null ? null : Notice(r));
});

/// Not yet marked read (badge on Me).
final unreadNoticesProvider = Provider<List<Notice>>((ref) => [for (final n in ref.watch(noticesProvider).value ?? const <Notice>[]) if (!n.read) n]);

/// The office asked for a confirmation (banner on Today).
final mustReadNoticesProvider = Provider<List<Notice>>((ref) => [for (final n in ref.watch(unreadNoticesProvider)) if (n.row.requireAck) n]);

class NoticeService {
  NoticeService(this._ref);
  final Ref _ref;

  /// "পড়েছি": saved now, sent when there is a network. Tapping twice is harmless.
  Future<void> markRead(String id) async {
    final db = _ref.read(databaseProvider);
    final at = _ref.read(clockProvider).nowUtc();
    var queued = false;
    await db.transaction(() async {
      final row = await (db.select(db.broadcasts)..where((t) => t.serverId.equals(id))).getSingleOrNull();
      if (row == null || row.ackedAt != null) return;
      final mutationId = const Uuid().v7();
      await (db.update(db.broadcasts)..where((t) => t.serverId.equals(id))).write(
        BroadcastsCompanion(ackedAt: Value(at), ackState: const Value('queued'), ackMutationId: Value(mutationId)),
      );
      await _ref.read(outboxWriterProvider).enqueue(mutationId: mutationId, entity: 'broadcast_ack', payload: {'broadcastId': id, 'at': at.toIso8601String()});
      queued = true;
    });
    if (queued) unawaited(_ref.read(syncEngineProvider).kick(reason: 'notice'));
  }
}

final noticeServiceProvider = Provider<NoticeService>(NoticeService.new);
