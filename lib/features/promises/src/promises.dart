import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/format/money.dart';
import '../../../core/notifications/reminders.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/sync/sync_handlers.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/time/clock.dart';
import '../../../core/ui/common.dart';
import '../../../core/ui/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../customers/customers.dart';

/// Max days ahead a promise may be set (spec default, FR-PRM-001).
const promiseMaxDaysAhead = 30;

/// Stable 31-bit notification id for a promise clientId.
int reminderIdFor(String clientId) => clientId.hashCode & 0x7fffffff;

class PromisePullHandler implements PullHandler {
  @override
  String get entity => 'promise';
  @override
  Future<void> upsert(AppDatabase db, String id, Json d) async {
    final clientId = (d['clientId'] as String?) ?? id;
    await db.into(db.promises).insertOnConflictUpdate(PromisesCompanion.insert(
          clientId: clientId,
          serverId: Value(id),
          customerId: d['customerId'] as String,
          erpPlanId: Value(d['erpPlanId'] as String?),
          promisedDate: d['promisedDate'] as String,
          promisedAmountPoisha: (d['promisedAmountPoisha'] as num).toInt(),
          paidTowardsPoisha: Value(((d['paidTowardsPoisha'] as num?) ?? 0).toInt()),
          status: Value((d['status'] as String?) ?? 'open'),
          note: Value(d['note'] as String?),
          createdAt: d['createdAt'] == null ? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true) : DateTime.parse(d['createdAt'] as String).toUtc(),
          syncState: const Value('synced'),
        ));
  }

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) => (db.delete(db.promises)..where((t) => t.serverId.equals(id))).go();
}

class PromisePushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'promise', 'promise_cancel'};
  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) async {
    if (m.entity != 'promise') return;
    await (db.update(db.promises)..where((t) => t.clientId.equals(m.mutationId))).write(
      PromisesCompanion(serverId: Value(r.entityId), syncState: Value(r.result == 'rejected' ? 'failed' : 'synced')),
    );
  }
}

Stream<List<PromiseRow>> watchPromisesFor(WidgetRef ref, String customerId) {
  final db = ref.read(databaseProvider);
  return (db.select(db.promises)..where((t) => t.customerId.equals(customerId))..orderBy([(t) => OrderingTerm.desc(t.createdAt)])..limit(10)).watch();
}

/// Open promises that fall due today (FR-M-044): the bell lists them.
final promisesDueTodayProvider = StreamProvider<List<PromiseRow>>((ref) {
  final db = ref.watch(databaseProvider);
  final today = ref.watch(clockProvider).businessDate();
  return (db.select(db.promises)..where((t) => t.status.equals('open') & t.promisedDate.equals(today))).watch();
});

/// Promises created today by me (end-of-day summary).
final todayPromiseCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final clock = ref.watch(clockProvider);
  final start = parseBusinessDate(clock.businessDate()).subtract(dhakaOffset);
  final q = db.selectOnly(db.promises)
    ..addColumns([db.promises.clientId.count()])
    ..where(db.promises.createdAt.isBiggerOrEqualValue(start));
  return q.map((r) => r.read(db.promises.clientId.count()) ?? 0).watchSingle();
});

/// Records a promise offline-first (FR-PRM-001). A new promise supersedes
/// the open one locally; the server does the same on push.
Future<void> recordPromise(
  WidgetRef ref, {
  required String customerId,
  required String date,
  required int amountPoisha,
  String? note,
  String? erpPlanId,
  required String reminderTitle,
  required String reminderBody,
}) async {
  final db = ref.read(databaseProvider);
  final id = const Uuid().v7();
  final at = ref.read(clockProvider).nowUtc();
  final repo = ref.read(customerRepositoryProvider);
  final open = await (db.select(db.promises)..where((t) => t.customerId.equals(customerId) & t.status.equals('open'))).get();
  await db.transaction(() async {
    for (final p in open) {
      await (db.update(db.promises)..where((t) => t.clientId.equals(p.clientId))).write(const PromisesCompanion(status: Value('superseded')));
    }
    await db.into(db.promises).insert(PromisesCompanion.insert(
          clientId: id,
          customerId: customerId,
          erpPlanId: Value(erpPlanId),
          promisedDate: date,
          promisedAmountPoisha: amountPoisha,
          note: Value(note),
          createdAt: at,
        ));
    await repo.applyLocalPromise(customerId, id: id, date: date, amountPoisha: amountPoisha);
    await ref.read(outboxWriterProvider).enqueue(mutationId: id, entity: 'promise', payload: {
      'clientId': id,
      'customerId': customerId,
      'erpPlanId': ?erpPlanId,
      'promisedDate': date,
      'promisedAmountPoisha': amountPoisha,
      'note': ?note,
    });
  });
  final reminders = ref.read(reminderSchedulerProvider);
  for (final p in open) {
    unawaited(reminders.cancel(reminderIdFor(p.clientId)).catchError((Object _) {}));
  }
  try {
    await reminders.schedulePromise(id: reminderIdFor(id), businessDate: date, title: reminderTitle, body: reminderBody);
    await (db.update(db.promises)..where((t) => t.clientId.equals(id))).write(const PromisesCompanion(reminderScheduled: Value(true)));
  } catch (_) {
    // Reminder is best effort (notification permission may be denied).
  }
  unawaited(ref.read(syncEngineProvider).kick(reason: 'promise'));
}

/// Cancels an open promise. Depends on the create if it is not yet pushed.
Future<void> cancelPromise(WidgetRef ref, PromiseRow p) async {
  final db = ref.read(databaseProvider);
  final id = const Uuid().v7();
  await db.transaction(() async {
    await (db.update(db.promises)..where((t) => t.clientId.equals(p.clientId))).write(const PromisesCompanion(status: Value('cancelled')));
    await ref.read(customerRepositoryProvider).applyLocalPromise(p.customerId, id: null, date: null, amountPoisha: null);
    await ref.read(outboxWriterProvider).enqueue(
      mutationId: id,
      entity: 'promise_cancel',
      payload: {'clientId': id, 'promiseId': p.serverId ?? p.clientId},
      dependsOn: p.serverId == null ? [p.clientId] : const [],
    );
  });
  unawaited(ref.read(reminderSchedulerProvider).cancel(reminderIdFor(p.clientId)).catchError((Object _) {}));
  unawaited(ref.read(syncEngineProvider).kick(reason: 'promise'));
}

String promiseStatusLabel(AppLocalizations l, String s) => switch (s) {
      'kept' => l.promiseStatusKept,
      'partially_kept' => l.promiseStatusPartial,
      'broken' => l.promiseStatusBroken,
      'cancelled' => l.promiseStatusCancelled,
      'superseded' => l.promiseStatusSuperseded,
      _ => l.promiseStatusOpen,
    };

AppStatus promiseStatusTone(String s) => switch (s) {
      'kept' => AppStatus.paid,
      'partially_kept' => AppStatus.current,
      'broken' => AppStatus.overdue,
      'open' => AppStatus.promised,
      _ => AppStatus.pending,
    };

Future<void> showPromiseSheet(BuildContext context, String customerId) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PromiseSheet(customerId: customerId),
    );

class _PromiseSheet extends ConsumerStatefulWidget {
  const _PromiseSheet({required this.customerId});
  final String customerId;
  @override
  ConsumerState<_PromiseSheet> createState() => _PromiseSheetState();
}

class _PromiseSheetState extends ConsumerState<_PromiseSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late String _today;
  String? _date;
  bool _busy = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _today = ref.read(clockProvider).businessDate();
    _date = _plus(1);
  }

  String _plus(int days) => businessDateOf(parseBusinessDate(_today).subtract(dhakaOffset).add(Duration(days: days, hours: 12)));

  Future<void> _pick() async {
    final base = parseBusinessDate(_today);
    final picked = await showDatePicker(
      context: context,
      initialDate: parseBusinessDate(_date ?? _today),
      firstDate: base,
      lastDate: base.add(const Duration(days: promiseMaxDaysAhead)),
    );
    if (picked != null) {
      setState(() => _date = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final customer = ref.watch(customerProvider(widget.customerId)).value;
    if (customer != null && !_prefilled) {
      _prefilled = true;
      final suggested = customer.row.installmentPoisha ?? (customer.row.overduePoisha > 0 ? customer.row.overduePoisha : customer.outstanding);
      if (suggested > 0) _amount.text = '${suggested ~/ 100}';
    }
    final poisha = parseMoneyInput(_amount.text) ?? 0;
    final quick = [(l.promiseToday, _plus(0)), (l.promiseTomorrow, _plus(1)), (l.promiseIn3, _plus(3)), (l.promiseIn7, _plus(7))];
    final isQuick = quick.any((q) => q.$2 == _date);
    final hasOpen = customer?.row.openPromiseDate != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(Space.s24, 0, Space.s24, MediaQuery.of(context).viewInsets.bottom + Space.s24),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.promiseTitle, style: t.titleLarge),
          if (customer != null) Text(customer.nameOf(Localizations.localeOf(context).languageCode), style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: Space.s16),
          Text(l.promiseDate, style: t.titleSmall),
          const SizedBox(height: Space.s8),
          Wrap(spacing: Space.s8, runSpacing: Space.s8, children: [
            for (final q in quick)
              ChoiceChip(
                showCheckmark: false,
                selected: _date == q.$2,
                label: Text('${q.$1} · ${f.date(q.$2)}'),
                onSelected: (_) => setState(() => _date = q.$2),
              ),
            ChoiceChip(
              showCheckmark: false,
              avatar: const Icon(Icons.calendar_month_rounded, size: 18),
              selected: !isQuick && _date != null,
              label: Text(!isQuick && _date != null ? f.date(_date!) : l.promisePickDate),
              onSelected: (_) => _pick(),
            ),
          ]),
          const SizedBox(height: Space.s16),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            style: t.headlineSmall,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(prefixText: '৳ ', labelText: l.promiseAmount, helperText: poisha > 0 ? f.words(poisha) : null),
          ),
          const SizedBox(height: Space.s12),
          TextField(controller: _note, maxLength: 500, decoration: InputDecoration(labelText: l.promiseNote)),
          if (hasOpen) ...[
            const SizedBox(height: Space.s4),
            InfoBanner(
              icon: Icons.swap_horiz_rounded,
              tone: BannerTone.warning,
              text: l.promiseReplaces(f.money(customer!.row.openPromisePoisha ?? 0), f.date(customer.row.openPromiseDate!)),
            ),
          ],
          const SizedBox(height: Space.s12),
          Row(children: [
            Icon(Icons.notifications_active_rounded, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: Space.s8),
            Expanded(child: Text(l.promiseReminder, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant))),
          ]),
          const SizedBox(height: Space.s16),
          FilledButton(
            onPressed: poisha <= 0 || _date == null || _busy || customer == null
                ? null
                : () async {
                    setState(() => _busy = true);
                    final name = customer.nameOf(Localizations.localeOf(context).languageCode);
                    final note = _note.text.trim();
                    await recordPromise(
                      ref,
                      customerId: widget.customerId,
                      date: _date!,
                      amountPoisha: poisha,
                      note: note.isEmpty ? null : note,
                      reminderTitle: l.reminderTitle(name),
                      reminderBody: l.reminderBody(f.money(poisha)),
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    showAppSnack(context, l.promiseSaved);
                  },
            child: Text(l.actionSave),
          ),
        ]),
      ),
    );
  }
}

/// Small row used on the customer timeline for a promise.
Widget promiseStatusChip(BuildContext context, PromiseRow p) {
  final l = AppLocalizations.of(context);
  return StatusBadge(promiseStatusTone(p.status), dense: true, label: p.syncState == 'queued' && p.status == 'open' ? l.statusQueued : promiseStatusLabel(l, p.status));
}
