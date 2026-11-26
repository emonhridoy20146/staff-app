import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/media/media.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/chips.dart';
import '../../../core/ui/common.dart';
import '../../../core/ui/money_text.dart';
import '../../../core/ui/refreshable.dart';
import '../../../core/ui/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../cash/cash.dart' show depositByClientIdProvider, depositFailureText, showDepositSheet;
import '../../places/places.dart' show placeByMutationProvider, placeErrorText;

/// Entities that carry money: never offered for discard (CLAUDE.md §2.2).
const moneyEntities = {'collection', 'deposit', 'cash_closing'};

String syncEntityLabel(AppLocalizations l, String e) => switch (e) {
      'collection' => l.syncEntityCollection,
      'visit' || 'visit_checkout' => l.syncEntityVisit,
      'note' => l.syncEntityNote,
      'promise' || 'promise_cancel' => l.syncEntityPromise,
      'deposit' => l.syncEntityDeposit,
      'attendance_event' => l.syncEntityAttendance,
      'tag' => l.syncEntityTag,
      'place' || 'place_edit' || 'place_move_request' => l.syncEntityPlace,
      _ => l.syncEntityOther,
    };

IconData syncEntityIcon(String e) => switch (e) {
      'collection' => Icons.payments_rounded,
      'visit' || 'visit_checkout' => Icons.where_to_vote_rounded,
      'note' => Icons.sticky_note_2_rounded,
      'promise' || 'promise_cancel' => Icons.handshake_rounded,
      'deposit' => Icons.savings_rounded,
      'attendance_event' => Icons.badge_rounded,
      'tag' => Icons.flag_rounded,
      'place' || 'place_edit' || 'place_move_request' => Icons.add_location_alt_rounded,
      _ => Icons.inventory_2_rounded,
    };

final _metaProvider = StreamProvider<SyncMetaRow?>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.syncMeta)..where((t) => t.id.equals(1))).watchSingleOrNull();
});
final _pendingByEntityProvider = StreamProvider<Map<String, int>>((ref) => ref.watch(outboxReaderProvider).watchPendingByEntity());
final _oldestProvider = StreamProvider<DateTime?>((ref) => ref.watch(outboxReaderProvider).watchOldestPending());
final _failedProvider = StreamProvider<List<OutboxRow>>((ref) => ref.watch(outboxReaderProvider).watchFailed());
final _conflictsProvider = StreamProvider<List<CollectionRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.collections)..where((t) => t.status.equals('conflict'))..orderBy([(t) => OrderingTerm.desc(t.recordedAt)])).watch();
});

/// Sync centre (FR-M-011, 06-offline-sync §9): what is waiting, what failed,
/// last success; Sync now and Retry. Nothing here deletes data.
class SyncCentreScreen extends ConsumerWidget {
  const SyncCentreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final status = ref.watch(syncStatusProvider).value ?? ref.read(syncEngineProvider).current;
    final meta = ref.watch(_metaProvider).value;
    final byEntity = ref.watch(_pendingByEntityProvider).value ?? const {};
    final oldest = ref.watch(_oldestProvider).value;
    final failed = ref.watch(_failedProvider).value ?? const <OutboxRow>[];
    final conflicts = ref.watch(_conflictsProvider).value ?? const <CollectionRow>[];
    final photos = ref.watch(waitingMediaProvider).value ?? const <MediaQueueRow>[];
    final media = photos.length;
    final upgrade = ref.watch(upgradeRequiredProvider);
    final last = meta?.lastSuccessAt ?? status.lastSuccessAt;
    final waiting = byEntity.values.fold(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(title: Text(l.syncCentreTitle)),
      // Pull down = "Sync now" (blocked like the button while an update is required).
      body: PullToRefresh(
        onRefresh: upgrade ? () async {} : null,
        child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, Space.s32),
        children: [
          if (upgrade) ...[InfoBanner(icon: Icons.system_update_rounded, tone: BannerTone.danger, text: l.syncBlockedUpgrade), const SizedBox(height: Space.cardGap)],
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const SyncChip(), const Spacer(), if (status.running) const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5))]),
              const SizedBox(height: Space.s12),
              Text(last == null ? l.syncNever : l.syncLastSuccess(f.dateTime(last)), style: t.titleMedium),
              if (oldest != null) ...[const SizedBox(height: Space.s4), Text(l.syncOldest(f.dateTime(oldest)), style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant))],
              const SizedBox(height: Space.s16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: status.running || upgrade ? null : () => ref.read(syncEngineProvider).syncNow(),
                  icon: const Icon(Icons.sync_rounded),
                  label: Text(l.actionSyncNow),
                ),
              ),
            ]),
          ),
          SectionHeader(l.syncWaitingTitle, count: waiting > 0 ? f.num(waiting) : null),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Space.s4),
            child: waiting == 0 && media == 0
                ? ListTile(leading: Icon(Icons.cloud_done_rounded, color: context.semanticColors.success.fg), title: Text(l.syncNothingWaiting))
                : Column(children: [
                    for (final e in byEntity.entries)
                      ListTile(
                        leading: Icon(syncEntityIcon(e.key)),
                        title: Text(syncEntityLabel(l, e.key)),
                        trailing: Text(f.num(e.value), style: t.titleMedium),
                      ),
                    if (media > 0)
                      ListTile(leading: const Icon(Icons.photo_camera_rounded), title: Text(l.syncMediaTitle), trailing: Text(l.syncMediaCount(f.num(media)), style: t.titleSmall)),
                  ]),
          ),
          if (media > 0) ...[const SizedBox(height: Space.cardGap), MediaQueueCard(photos: photos)],
          SectionHeader(l.syncProblemsTitle, count: failed.length + conflicts.length > 0 ? f.num(failed.length + conflicts.length) : null, color: failed.isEmpty && conflicts.isEmpty ? null : cs.error),
          if (failed.isEmpty && conflicts.isEmpty)
            AppCard(child: Row(children: [Icon(Icons.verified_rounded, color: context.semanticColors.success.fg), const SizedBox(width: Space.s12), Text(l.syncNoProblems, style: t.bodyLarge)]))
          else ...[
            for (final c in conflicts) ...[_ConflictCard(row: c), const SizedBox(height: Space.cardGap)],
            for (final m in failed) ...[m.entity == 'deposit' ? _FailedDepositCard(row: m) : _FailedCard(row: m), const SizedBox(height: Space.cardGap)],
            if (failed.any((m) => moneyEntities.contains(m.entity)) || conflicts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.s8),
                child: Row(children: [
                  Icon(Icons.lock_rounded, size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: Space.s8),
                  Expanded(child: Text(l.syncProblemMoneyHint, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant))),
                ]),
              ),
          ],
        ],
      ),
      ),
    );
  }
}

class _ConflictCard extends ConsumerWidget {
  const _ConflictCard({required this.row});
  final CollectionRow row;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final msg = row.conflictMessage == null ? (row.conflictCode ?? '') : I18nText.fromJson(jsonDecode(row.conflictMessage!)).of(lang);
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.payments_rounded, color: cs.error),
          const SizedBox(width: Space.s12),
          Expanded(child: Text(row.customerName, style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
          StatusBadge(AppStatus.overdue, dense: true, label: l.statusConflict),
        ]),
        const SizedBox(height: Space.s8),
        Row(children: [
          MoneyText(row.amountPoisha, style: t.titleLarge),
          const SizedBox(width: Space.s12),
          Text(row.receiptNo, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        ]),
        const SizedBox(height: Space.s8),
        Text(l.syncProblemConflict(msg), style: t.bodyMedium),
        const SizedBox(height: Space.s4),
        Text(l.syncProblemManager, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
      ]),
    );
  }
}

class _FailedCard extends ConsumerWidget {
  const _FailedCard({required this.row});
  final OutboxRow row;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return AppCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(syncEntityIcon(row.entity), color: cs.error),
        const SizedBox(width: Space.s12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(syncEntityLabel(l, row.entity), style: t.titleMedium),
            Text(f.dateTime(row.createdAt), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: Space.s4),
            _FailedReason(row: row),
          ]),
        ),
        TextButton(onPressed: () => ref.read(syncEngineProvider).retryFailed(row.mutationId), child: Text(l.actionRetry)),
      ]),
    );
  }
}

/// Why a mutation was refused. A place (FR-M-063) says it in words with its name, and a refused direct
/// move (ADR-M30) adds that the marker went back; everything else shows the server's code.
class _FailedReason extends ConsumerWidget {
  const _FailedReason({required this.row});
  final OutboxRow row;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final generic = Text(l.syncProblemRejected(row.lastError ?? '—'), style: t.bodyMedium);
    if (!row.entity.startsWith('place')) return generic;
    final p = ref.watch(placeByMutationProvider(row.mutationId)).value;
    if (p == null) return generic;
    final movedBack = p.moveFailed && p.row.moveMutationId == row.mutationId && row.entity == 'place_edit';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.placeProblem(p.name, placeErrorText(l, p.row.errorCode)), style: t.bodyMedium),
      if (movedBack) Text(l.placeProblemMoveBack, style: t.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]);
  }
}

/// A deposit the server refused (FR-M-059): why, in words, and that the collections are back in
/// hand. It is never sent again with the same amount (the cash has changed); the staff member
/// deposits again, and this record stays here (money is never discarded).
class _FailedDepositCard extends ConsumerWidget {
  const _FailedDepositCard({required this.row});
  final OutboxRow row;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final d = ref.watch(depositByClientIdProvider(row.mutationId)).value;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(syncEntityIcon(row.entity), color: cs.error),
          const SizedBox(width: Space.s12),
          Expanded(child: Text(syncEntityLabel(l, row.entity), style: t.titleMedium)),
          StatusBadge(AppStatus.overdue, dense: true, label: l.statusDepositFailed),
        ]),
        const SizedBox(height: Space.s8),
        Row(children: [
          if (d != null) ...[MoneyText(d.amountPoisha, style: t.titleLarge), const SizedBox(width: Space.s12)],
          Text(f.dateTime(row.createdAt), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        ]),
        const SizedBox(height: Space.s8),
        Text(depositFailureText(l, d?.failureCode), style: t.bodyMedium),
        const SizedBox(height: Space.s4),
        Text(l.depositFailedBack, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(onPressed: () => showDepositSheet(context), icon: const Icon(Icons.savings_rounded), label: Text(l.depositAgain)),
        ),
      ]),
    );
  }
}

/// Today banner: problems need attention (failed + conflicts).
class SyncProblemsBanner extends ConsumerWidget {
  const SyncProblemsBanner({super.key, required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = (ref.watch(failedCountProvider).value ?? 0) + (ref.watch(openConflictCountProvider).value ?? 0);
    if (n == 0) return const SizedBox.shrink();
    return InfoBanner(icon: Icons.error_rounded, tone: BannerTone.danger, text: AppLocalizations.of(context).todayProblemsBanner(ref.watch(fmtProvider).num(n)), onTap: onTap);
  }
}



/// The kind of a queued photo in words.
String mediaKindLabel(AppLocalizations l, String kind) => switch (kind) {
      'selfie' => l.mediaKindSelfie,
      'visit_photo' => l.mediaKindVisit,
      'deposit_slip' => l.mediaKindSlip,
      'location_proof' => l.mediaKindPin,
      _ => l.mediaKindOther,
    };

IconData _mediaKindIcon(String kind) => switch (kind) {
      'selfie' => Icons.face_rounded,
      'deposit_slip' => Icons.receipt_long_rounded,
      'location_proof' => Icons.add_location_alt_rounded,
      _ => Icons.photo_camera_rounded,
    };

/// Why a photo upload failed, in words (FR-M-069), from the row's `<step>:<code>`.
String mediaFailureText(AppLocalizations l, String? wire) {
  final f = MediaFailure.parse(wire);
  final reason = switch (f.code) {
    'NETWORK' => l.mediaReasonNetwork,
    'TIMEOUT' => l.mediaReasonTimeout,
    'MISSING' => l.mediaReasonMissing,
    'MEDIA_DELETED' => l.mediaReasonDeleted,
    'VALIDATION_FAILED' || 'HTTP_400' || 'HTTP_422' => l.mediaReasonInvalid,
    'FORBIDDEN' || 'HTTP_403' || 'SIGNATURE_EXPIRED' => l.mediaReasonSignature,
    'NOT_UPLOADED' || 'INVALID_STATE' => l.mediaReasonNotUploaded,
    'UNAVAILABLE' || 'HTTP_500' || 'HTTP_502' || 'HTTP_503' || 'HTTP_504' => l.mediaReasonServer,
    _ => l.mediaReasonCode(f.code),
  };
  return switch (f.step) {
    'presign' => l.mediaStepPresign(reason),
    'upload' => l.mediaStepUpload(reason),
    'confirm' => l.mediaStepConfirm(reason),
    _ => reason,
  };
}

/// Every photo not yet on the server: what it is, when it was taken, its state and the last error in words,
/// with a Retry button each and one for all (FR-M-069). Nothing here deletes a photo.
class MediaQueueCard extends ConsumerWidget {
  const MediaQueueCard({super.key, required this.photos});
  final List<MediaQueueRow> photos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.mediaQueueHint, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        for (final m in photos) ...[
          const Divider(height: Space.s24),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(_mediaKindIcon(m.kind), color: m.state == 'failed' ? cs.error : cs.onSurfaceVariant),
            const SizedBox(width: Space.s12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(mediaKindLabel(l, m.kind), style: t.titleMedium),
                Text(f.dateTime(m.capturedAt), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: Space.s4),
                if (m.state == 'failed') ...[
                  Text(l.mediaStateFailed(mediaFailureText(l, m.lastError)), style: t.bodyMedium!.copyWith(color: cs.error)),
                  if (m.nextAttemptAt != null) Text(l.mediaNextTry(f.num(m.attempts), f.time(m.nextAttemptAt!)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                ] else
                  Text(l.mediaStateWaiting, style: t.bodyMedium),
              ]),
            ),
            TextButton(onPressed: () => ref.read(mediaServiceProvider).retryNow(m.clientId), child: Text(l.actionRetry)),
          ]),
        ],
        if (photos.length > 1) ...[
          const SizedBox(height: Space.s8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(onPressed: () => ref.read(mediaServiceProvider).retryNow(), icon: const Icon(Icons.cloud_upload_rounded), label: Text(l.mediaRetryAll)),
          ),
        ],
      ]),
    );
  }
}
