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
import '../../../core/theme/tag_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../core/ui/tag_mark.dart';
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
          state: 'tagged',
          severity: severity,
          reasonCode: reasonCode,
          reasonJson: jsonEncode({'reason': reason, 'setBy': me?.name.bn, 'setAt': at.toIso8601String(), 'pendingReview': true}));
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
    // FR-M-081: what the customer's row will show for this level and reason (null = a watch tag: no frame).
    final preview = untag || _code == null ? null : tagKindForChoice(severity: _severity, reasonCode: _code);
    final previewStyle = preview == null ? null : context.tagColors.of(preview);

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
          // Each reason shows the colour and icon a customer's row gets with it (FR-M-081), so the mapping is
          // learnt where the tag is set. Removing a tag has no colours.
          for (final c in codes) ...[
            _ReasonOption(
              key: ValueKey('tag-reason-$c'),
              label: tagReasonLabel(l, c),
              kind: untag ? null : tagKindForReason(c),
              selected: _code == c,
              onTap: () => setState(() => _code = c),
            ),
            const SizedBox(height: Space.s8),
          ],
          if (!untag && _code != null) ...[
            const SizedBox(height: Space.s4),
            Semantics(
              liveRegion: true,
              child: preview == null
                  ? Text(l.tagWatchPreview, key: const Key('tag-preview-watch'), style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant))
                  : Wrap(spacing: Space.s8, runSpacing: Space.s4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      Text(l.tagRowPreview, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                      TagChip(preview, key: const Key('tag-preview-chip')),
                    ]),
            ),
          ],
          const SizedBox(height: Space.s12),
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
            // The button takes the colour the tag will have; before a reason is picked, and for a watch tag, the plain tagged look.
            style: untag ? null : FilledButton.styleFrom(backgroundColor: previewStyle?.fg ?? st.bg, foregroundColor: previewStyle?.bg ?? st.fg),
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

/// One reason in the tag sheet: a full-width, 56 dp option with the reason's swatch (its icon in its colour on
/// its tint), its words, and a radio mark. Picked, it takes the frame colour and tint a customer's row gets.
/// [kind] null (removing a tag) gives a plain option.
class _ReasonOption extends StatelessWidget {
  const _ReasonOption({super.key, required this.label, required this.kind, required this.selected, required this.onTap});
  final String label;
  final TagKind? kind;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final st = kind == null ? null : context.tagColors.of(kind!);
    final line = st?.fg ?? cs.primary;
    final radio = Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, color: selected ? line : cs.outline);
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? (st?.bg ?? cs.primaryContainer) : cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.brLg,
          side: selected ? BorderSide(color: line, width: kind == null ? 1.5 : TagFrame.strokeOf(context, kind!)) : BorderSide(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Sizes.primaryButton),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s8),
              child: Row(children: [
                if (st != null) ...[
                  Container(
                    key: ValueKey('tag-swatch-${kind!.name}'),
                    width: Space.s32,
                    height: Space.s32,
                    decoration: BoxDecoration(color: kind!.strong ? st.fg : st.bg, borderRadius: Radii.brMd, border: Border.all(color: st.fg)),
                    child: Icon(tagKindIcon(kind!), size: 20, color: kind!.strong ? st.bg : st.fg),
                  ),
                  const SizedBox(width: Space.s12),
                ],
                Expanded(child: Text(label, style: t.bodyLarge!.copyWith(color: cs.onSurface, fontWeight: selected ? FontWeight.w600 : null))),
                const SizedBox(width: Space.s8),
                radio,
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
