import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/api/api_models.dart';
import '../../../core/api/field_api.dart';
import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/sync/sync_handlers.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../core/ui/money_text.dart';
import '../../../core/ui/refreshable.dart';
import '../../../core/ui/status_badge.dart';
import '../../../l10n/app_localizations.dart';

class HandoverPullHandler implements PullHandler {
  @override
  String get entity => 'handover';
  @override
  Future<void> upsert(AppDatabase db, String id, Json d) => db.into(db.handovers).insertOnConflictUpdate(HandoversCompanion.insert(
        serverId: id,
        fromUserName: I18nText.fromJson(d['fromUserName'] ?? d['createdByName'] ?? '—').bn,
        toUserId: (d['toUserId'] as String?) ?? '',
        summaryJson: jsonEncode(d['summary'] ?? const {}),
        reason: Value(d['reason'] as String?),
        status: (d['status'] as String?) ?? 'pending_acceptance',
        expiresAt: Value(d['expiresAt'] == null ? null : DateTime.parse(d['expiresAt'] as String).toUtc()),
        role: (d['role'] as String?) ?? 'incoming',
      ));

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) => (db.delete(db.handovers)..where((t) => t.serverId.equals(id))).go();
}

class HandoverSummary {
  HandoverSummary(Json j)
      : customers = ((j['customers'] as num?) ?? 0).toInt(),
        outstandingPoisha = ((j['outstandingPoisha'] as num?) ?? 0).toInt(),
        overdue = ((j['overdue'] as num?) ?? 0).toInt(),
        openPromises = ((j['openPromises'] as num?) ?? 0).toInt(),
        openConflicts = ((j['openConflicts'] as num?) ?? 0).toInt();
  final int customers;
  final int outstandingPoisha;
  final int overdue;
  final int openPromises;
  final int openConflicts;
}

final handoversProvider = StreamProvider<List<HandoverRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.handovers)..orderBy([(t) => OrderingTerm.desc(t.expiresAt)])).watch();
});

/// Incoming handovers still waiting for my answer (Today banner).
final pendingHandoversProvider = Provider<List<HandoverRow>>((ref) {
  final now = ref.watch(clockProvider).nowUtc();
  return [
    for (final h in ref.watch(handoversProvider).value ?? const <HandoverRow>[])
      if (h.role == 'incoming' && h.status == 'pending_acceptance' && (h.expiresAt == null || h.expiresAt!.isAfter(now))) h,
  ];
});

enum HandoverDecisionResult { ok, offline, failed }

/// Accept / reject are online-only (FR-HND-003): the office must see the
/// answer at once. The UI calls this service, never the network.
class HandoverService {
  HandoverService(this._ref);
  final Ref _ref;

  Future<HandoverDecisionResult> decide(String id, {required bool accept, String? reason}) async {
    final api = _ref.read(fieldApiProvider);
    final db = _ref.read(databaseProvider);
    try {
      if (accept) {
        await api.acceptHandover(id);
      } else {
        await api.rejectHandover(id, reason ?? '');
      }
    } on ApiException catch (e) {
      return e.isNetwork ? HandoverDecisionResult.offline : HandoverDecisionResult.failed;
    }
    await (db.update(db.handovers)..where((t) => t.serverId.equals(id))).write(HandoversCompanion(status: Value(accept ? 'accepted' : 'rejected')));
    // Pull at once so the handed-over customers appear.
    await _ref.read(syncEngineProvider).kick(reason: 'handover');
    return HandoverDecisionResult.ok;
  }
}

final handoverServiceProvider = Provider<HandoverService>(HandoverService.new);

class HandoversScreen extends ConsumerWidget {
  const HandoversScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final list = ref.watch(handoversProvider).value ?? const <HandoverRow>[];
    return Scaffold(
      appBar: AppBar(title: Text(l.handoverTitle)),
      body: PullToRefresh(
        child: list.isEmpty
          ? PullableFill(alignment: Alignment.topCenter, child: EmptyState(icon: Icons.swap_horizontal_circle_outlined, title: l.handoverNone, body: ''))
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(Space.screen),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: Space.cardGap),
              itemBuilder: (_, i) => HandoverCard(handover: list[i]),
            ),
      ),
    );
  }
}

class HandoverCard extends ConsumerStatefulWidget {
  const HandoverCard({super.key, required this.handover});
  final HandoverRow handover;
  @override
  ConsumerState<HandoverCard> createState() => _HandoverCardState();
}

class _HandoverCardState extends ConsumerState<HandoverCard> {
  bool _busy = false;

  Future<void> _decide(bool accept) async {
    final l = AppLocalizations.of(context);
    String? reason;
    if (!accept) {
      reason = await _askReason(context);
      if (reason == null) return;
    }
    setState(() => _busy = true);
    final r = await ref.read(handoverServiceProvider).decide(widget.handover.serverId, accept: accept, reason: reason);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case HandoverDecisionResult.ok:
        showAppSnack(context, accept ? l.handoverAccepted : l.handoverRejected);
      case HandoverDecisionResult.offline:
        showAppSnack(context, l.handoverNeedsInternet, icon: Icons.wifi_off_rounded);
      case HandoverDecisionResult.failed:
        showAppSnack(context, l.errorGeneric, icon: Icons.error_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final h = widget.handover;
    final s = HandoverSummary((jsonDecode(h.summaryJson) as Map).cast<String, dynamic>());
    final pending = h.status == 'pending_acceptance' && h.role == 'incoming';
    final (tone, label) = switch (h.status) {
      'pending_acceptance' => (AppStatus.pending, l.handoverStatusPending),
      'accepted' || 'active' => (AppStatus.paid, l.handoverStatusAccepted),
      'rejected' => (AppStatus.overdue, l.handoverStatusRejected),
      _ => (AppStatus.current, l.handoverStatusOther),
    };
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(backgroundColor: cs.primaryContainer, foregroundColor: cs.onPrimaryContainer, child: const Icon(Icons.swap_horiz_rounded)),
          const SizedBox(width: Space.s12),
          Expanded(child: Text(l.handoverFrom(h.fromUserName), style: t.titleMedium)),
          StatusBadge(tone, dense: true, label: label),
        ]),
        if (h.reason != null) ...[const SizedBox(height: Space.s8), Text(l.handoverReason(h.reason!), style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant))],
        const SizedBox(height: Space.s12),
        Row(children: [
          Expanded(child: _Stat(label: l.handoverCustomers, value: Text(f.num(s.customers), style: t.titleLarge))),
          Expanded(flex: 2, child: _Stat(label: l.handoverOutstanding, value: MoneyText(s.outstandingPoisha, style: t.titleLarge))),
        ]),
        const SizedBox(height: Space.s8),
        Row(children: [
          Expanded(child: _Stat(label: l.handoverOverdue, value: Text(f.num(s.overdue), style: t.titleMedium!.copyWith(color: context.statusColors.of(AppStatus.overdue).fg)))),
          Expanded(child: _Stat(label: l.handoverOpenPromises, value: Text(f.num(s.openPromises), style: t.titleMedium))),
          if (s.openConflicts > 0) Expanded(child: _Stat(label: l.handoverOpenConflicts, value: Text(f.num(s.openConflicts), style: t.titleMedium))),
        ]),
        if (pending) ...[
          if (h.expiresAt != null) ...[
            const SizedBox(height: Space.s12),
            Row(children: [
              Icon(Icons.schedule_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: Space.s4),
              Text(l.handoverExpires(f.dateTime(h.expiresAt!)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
            ]),
          ],
          const SizedBox(height: Space.s4),
          Row(children: [
            Icon(Icons.wifi_rounded, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: Space.s4),
            Expanded(child: Text(l.handoverNeedsInternet, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant))),
          ]),
          const SizedBox(height: Space.s16),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: _busy ? null : () => _decide(false), child: Text(l.actionReject))),
            const SizedBox(width: Space.s12),
            Expanded(
              child: FilledButton(
                onPressed: _busy ? null : () => _decide(true),
                child: _busy ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5)) : Text(l.actionAccept),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final Widget value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        value,
      ]);
}

Future<String?> _askReason(BuildContext context) {
  final l = AppLocalizations.of(context);
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (d) => StatefulBuilder(
      builder: (d, setState) => AlertDialog(
        title: Text(l.actionReject),
        content: TextField(controller: c, autofocus: true, maxLines: 3, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: l.handoverReasonHint)),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(), child: Text(l.actionCancel)),
          FilledButton(onPressed: c.text.trim().length < 10 ? null : () => Navigator.of(d).pop(c.text.trim()), child: Text(l.actionReject)),
        ],
      ),
    ),
  );
}
