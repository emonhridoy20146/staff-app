import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/location/location_engine.dart';
import '../../../core/providers.dart';
import '../../../core/sync/sync_handlers.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/auth.dart';
import '../../customers/customers.dart';

const tagReasonCodes = ['plan_ended_unpaid', 'repeated_broken_promise', 'absconded', 'refused_to_pay', 'fraud_suspected', 'other'];
const untagReasonCodes = ['cleared', 'mistake', 'other'];
const tagSeverities = ['watch', 'bad', 'legal'];
const tagReasonMinLength = 10;

String tagReasonLabel(AppLocalizations l, String c) => switch (c) {
      'plan_ended_unpaid' => l.tagReasonLongOverdue,
      'repeated_broken_promise' => l.tagReasonBrokenPromise,
      'absconded' => l.tagReasonAbsconded,
      'refused_to_pay' => l.tagReasonRefuses,
      'fraud_suspected' => l.tagReasonFraud,
      'cleared' => l.tagReasonCleared,
      'mistake' => l.tagReasonMistake,
      _ => l.tagReasonOther,
    };

String tagSeverityLabel(AppLocalizations l, String s) => switch (s) {
      'watch' => l.tagSeverityWatch,
      'legal' => l.tagSeverityLegal,
      _ => l.tagSeverityBad,
    };

/// Validation shared by UI and tests (FR-TAG-002: reason ≥ 10 chars).
bool isValidTagReason(String text) => text.trim().length >= tagReasonMinLength;

class TagPushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'tag'};
  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) =>
      (db.update(db.tagEvents)..where((t) => t.clientId.equals(m.mutationId))).write(
        TagEventsCompanion(syncState: Value(r.result == 'rejected' ? 'failed' : 'synced')),
      );
}

/// Sets or clears a tag offline-first. A staff tag applies locally at once
/// (safer: the customer shows as tagged); removing a tag waits for the
/// manager's review, so the local state stays tagged until the next pull.
Future<void> setTag(
  WidgetRef ref, {
  required String customerId,
  required bool tag,
  required String reasonCode,
  required String reason,
  String severity = 'bad',
}) async {
  final db = ref.read(databaseProvider);
  final id = const Uuid().v7();
  final at = ref.read(clockProvider).nowUtc();
  final repo = ref.read(customerRepositoryProvider);
  final c = await repo.getOne(customerId);
  final previous = {'state': c?.row.tagState ?? 'none', 'severity': c?.row.tagSeverity};
  final next = {'state': tag ? 'tagged' : 'none', if (tag) 'severity': severity};
  final GeoFix? fix = await ref.read(locationEngineProvider).currentFix(timeout: const Duration(seconds: 5));
  final me = ref.read(sessionProvider).user;
  await db.transaction(() async {
    await db.into(db.tagEvents).insert(TagEventsCompanion.insert(
          clientId: id,
          customerId: customerId,
          previousJson: jsonEncode(previous),
          nextJson: jsonEncode(next),
          reasonCode: reasonCode,
          reason: reason,
          at: at,
        ));
    if (tag) {
      await repo.applyLocalTag(customerId,
          state: 'tagged', severity: severity, reasonJson: jsonEncode({'reason': reason, 'setBy': me?.name.bn, 'setAt': at.toIso8601String(), 'pendingReview': true}));
    }
    await ref.read(outboxWriterProvider).enqueue(mutationId: id, entity: 'tag', payload: {
      'clientId': id,
      'customerId': customerId,
      'state': tag ? 'tagged' : 'none',
      if (tag) 'severity': severity,
      'reasonCode': reasonCode,
      'reason': reason,
      'geo': ?fix?.toJson(),
    });
  });
  unawaited(ref.read(syncEngineProvider).kick(reason: 'tag'));
}

Future<void> showTagSheet(BuildContext context, String customerId) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _TagSheet(customerId: customerId),
    );

class _TagSheet extends ConsumerStatefulWidget {
  const _TagSheet({required this.customerId});
  final String customerId;
  @override
  ConsumerState<_TagSheet> createState() => _TagSheetState();
}

class _TagSheetState extends ConsumerState<_TagSheet> {
  final _reason = TextEditingController();
  String? _code;
  String _severity = 'bad';
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final customer = ref.watch(customerProvider(widget.customerId)).value;
    final untag = customer?.tagged ?? false;
    final codes = untag ? untagReasonCodes : tagReasonCodes;
    final valid = _code != null && isValidTagReason(_reason.text);
    final st = context.statusColors.of(AppStatus.tagged);

    return Padding(
      padding: EdgeInsets.fromLTRB(Space.s24, 0, Space.s24, MediaQuery.of(context).viewInsets.bottom + Space.s24),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Icon(untag ? Icons.flag_outlined : Icons.flag_rounded, color: st.fg),
            const SizedBox(width: Space.s8),
            Expanded(child: Text(untag ? l.untagTitle : l.tagTitle, style: t.titleLarge)),
          ]),
          if (customer != null) Text(customer.nameOf(Localizations.localeOf(context).languageCode), style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
          if (!untag) ...[
            const SizedBox(height: Space.s16),
            Text(l.tagSeverity, style: t.titleSmall),
            const SizedBox(height: Space.s8),
            SegmentedButton<String>(
              segments: [for (final s in tagSeverities) ButtonSegment(value: s, label: Text(tagSeverityLabel(l, s)))],
              selected: {_severity},
              onSelectionChanged: (s) => setState(() => _severity = s.first),
            ),
          ],
          const SizedBox(height: Space.s16),
          Text(l.tagReason, style: t.titleSmall),
          const SizedBox(height: Space.s8),
          Wrap(spacing: Space.s8, runSpacing: Space.s8, children: [
            for (final c in codes)
              ChoiceChip(showCheckmark: false, selected: _code == c, label: Text(tagReasonLabel(l, c)), onSelected: (_) => setState(() => _code = c)),
          ]),
          const SizedBox(height: Space.s16),
          TextField(
            controller: _reason,
            maxLines: 3,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l.tagReasonHint,
              errorText: _reason.text.isNotEmpty && !isValidTagReason(_reason.text) ? l.tagReasonTooShort : null,
            ),
          ),
          const SizedBox(height: Space.s12),
          FilledButton(
            style: untag ? null : FilledButton.styleFrom(backgroundColor: st.fg, foregroundColor: st.bg),
            onPressed: !valid || _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    await setTag(ref, customerId: widget.customerId, tag: !untag, reasonCode: _code!, reason: _reason.text.trim(), severity: _severity);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    showAppSnack(context, untag ? l.untagSaved : l.tagSaved, icon: Icons.flag_rounded);
                  },
            child: Text(untag ? l.actionUntag : l.actionTag),
          ),
        ]),
      ),
    );
  }
}
