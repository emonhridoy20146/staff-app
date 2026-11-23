import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/colleague_activity.dart';
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
    // A colleague's promise (FR-M-057): kept apart so "my promises" and the reminders stay mine.
    // `ownerId` is the customer's assignee; who made the promise is `createdBy` (contract 1.31.0).
    final owner = d['ownerId'] as String?;
    final maker = (d['createdBy'] as String?) ?? owner;
    final me = await savedUserId(db);
    if (isColleague(me: me, staffId: maker) && isColleague(me: me, staffId: owner)) {
      await upsertColleagueActivity(
        db,
        kind: 'promise',
        serverId: id,
        customerId: d['customerId'] as String,
        staffId: maker!,
        staffName: (d['createdByName'] as String?) ?? (d['ownerName'] as String?) ?? '',
        at: d['createdAt'] == null ? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true) : DateTime.parse(d['createdAt'] as String).toUtc(),
        amountPoisha: (d['promisedAmountPoisha'] as num?)?.toInt(),
        promisedDate: d['promisedDate'] as String?,
        status: (d['status'] as String?) ?? 'open',
        note: d['note'] as String?,
      );
      return;
    }
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
          createdByName: Value(isColleague(me: me, staffId: maker) ? d['createdByName'] as String? : null),
          followUpOf: Value(d['followUpOf'] as String?),
          followUpId: Value(d['followUpId'] as String?),
          attempt: Value(((d['attempt'] as num?) ?? 1).toInt()),
          createdAt: d['createdAt'] == null ? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true) : DateTime.parse(d['createdAt'] as String).toUtc(),
          syncState: const Value('synced'),
        ));
  }

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) async {
    await (db.delete(db.promises)..where((t) => t.serverId.equals(id))).go();
    await deleteColleagueActivity(db, 'promise', id);
  }
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
    ..where(db.promises.createdAt.isBiggerOrEqualValue(start) & db.promises.createdByName.isNull());
  return q.map((r) => r.read(db.promises.clientId.count()) ?? 0).watchSingle();
});

/// The id a follow-up names: the server id once the promise is on the server, else its clientId.
String promiseRefId(PromiseRow p) => p.serverId ?? p.clientId;

/// A broken promise nobody has followed up yet (FR-M-072): the server names no follow-up (`followUpId`, which
/// also covers a colleague's) and no promise on this phone names it in `followUpOf` (one not sent yet).
bool needsFollowUp(PromiseRow p, Iterable<PromiseRow> all) =>
    p.status == 'broken' && p.followUpId == null && !all.any((q) => q.followUpOf != null && (q.followUpOf == p.serverId || q.followUpOf == p.clientId));

/// The customer's latest broken promise without a follow-up, if any: a new promise on this customer follows it up.
Future<PromiseRow?> brokenToFollowUp(AppDatabase db, String customerId) async {
  final all = await (db.select(db.promises)..where((t) => t.customerId.equals(customerId))..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  for (final p in all) {
    if (needsFollowUp(p, all)) return p;
  }
  return null;
}

/// Broken promises without a follow-up, oldest due first (Today card, FR-M-072).
Stream<List<PromiseRow>> watchBrokenWithoutFollowUp(AppDatabase db) =>
    (db.select(db.promises)..orderBy([(t) => OrderingTerm.asc(t.promisedDate)])).watch().map((all) => [for (final p in all) if (needsFollowUp(p, all)) p]);

final brokenWithoutFollowUpProvider = StreamProvider<List<PromiseRow>>((ref) => watchBrokenWithoutFollowUp(ref.watch(databaseProvider)));

/// Records a promise offline-first (FR-PRM-001). A new promise supersedes
/// the open one locally; the server does the same on push.
///
/// Follow-up (contract 1.45.0, FR-M-072): when the customer has a broken promise without a follow-up, the new
/// promise is its follow-up: it carries `followUpOf` (the broken promise's id) and the next `attempt` number.
/// [followUpOf] names the broken promise explicitly (the "New promise (follow-up)" action).
Future<void> recordPromise(
  WidgetRef ref, {
  PromiseRow? followUpOf,
  required String customerId,
  required String date,
  required int amountPoisha,
  String? note,
  String? erpPlanId,
  required String reminderTitle,
  required String reminderBody,
}) =>
    ref.read(promiseServiceProvider).record(
          followUpOf: followUpOf,
          customerId: customerId,
          date: date,
          amountPoisha: amountPoisha,
          note: note,
          erpPlanId: erpPlanId,
          reminderTitle: reminderTitle,
          reminderBody: reminderBody,
        );

/// Saving a promise from anywhere (screens use [recordPromise]; tests use this).
class PromiseService {
  PromiseService(this._ref);
  final Ref _ref;
  Future<void> record({
    PromiseRow? followUpOf,
    required String customerId,
    required String date,
    required int amountPoisha,
    String? note,
    String? erpPlanId,
    required String reminderTitle,
    required String reminderBody,
  }) =>
      _record(_ref,
          followUpOf: followUpOf,
          customerId: customerId,
          date: date,
          amountPoisha: amountPoisha,
          note: note,
          erpPlanId: erpPlanId,
          reminderTitle: reminderTitle,
          reminderBody: reminderBody);
}

final promiseServiceProvider = Provider<PromiseService>(PromiseService.new);

Future<void> _record(
  Ref ref, {
  PromiseRow? followUpOf,
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
  final prev = followUpOf ?? await brokenToFollowUp(db, customerId);
  final attempt = prev == null ? 1 : prev.attempt + 1;
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
          followUpOf: Value(prev == null ? null : promiseRefId(prev)),
          attempt: Value(attempt),
        ));
    await repo.applyLocalPromise(customerId, id: id, date: date, amountPoisha: amountPoisha);
    await ref.read(outboxWriterProvider).enqueue(mutationId: id, entity: 'promise', payload: {
      'clientId': id,
      'customerId': customerId,
      'erpPlanId': ?erpPlanId,
      'promisedDate': date,
      'promisedAmountPoisha': amountPoisha,
      'note': ?note,
      if (prev != null) 'followUpOf': promiseRefId(prev),
    }, dependsOn: prev != null && prev.serverId == null ? [prev.clientId] : const []);
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

Future<void> showPromiseSheet(BuildContext context, String customerId, {PromiseRow? followUpOf}) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PromiseSheet(customerId: customerId, followUpOf: followUpOf),
    );

class _PromiseSheet extends ConsumerStatefulWidget {
  const _PromiseSheet({required this.customerId, this.followUpOf});
  final String customerId;
  final PromiseRow? followUpOf;
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
  PromiseRow? _broken;

  @override
  void initState() {
    super.initState();
    _today = ref.read(clockProvider).businessDate();
    _date = _plus(1);
    _broken = widget.followUpOf;
    if (_broken == null) {
      unawaited(brokenToFollowUp(ref.read(databaseProvider), widget.customerId).then((p) {
        if (mounted && p != null) setState(() => _broken = p);
      }));
    }
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
          Text(_broken == null ? l.promiseTitle : l.promiseFollowUpAction, style: t.titleLarge),
          if (customer != null) Text(customer.nameOf(Localizations.localeOf(context).languageCode), style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
          if (_broken != null) ...[
            const SizedBox(height: Space.s12),
            InfoBanner(
              icon: Icons.replay_rounded,
              tone: BannerTone.warning,
              text: '${l.promiseFollowUpOf(f.money(_broken!.promisedAmountPoisha), f.date(_broken!.promisedDate))} · ${l.promiseAttempt(f.num(_broken!.attempt + 1))}',
            ),
          ],
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
                      followUpOf: _broken,
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

/// "New promise (follow-up)" on a broken promise that has none yet (FR-M-072); 48 dp.
class PromiseFollowUpButton extends StatelessWidget {
  const PromiseFollowUpButton({super.key, required this.promise});
  final PromiseRow promise;
  @override
  Widget build(BuildContext context) => TextButton.icon(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
        onPressed: () => showPromiseSheet(context, promise.customerId, followUpOf: promise),
        icon: const Icon(Icons.replay_rounded),
        label: Text(AppLocalizations.of(context).promiseFollowUpAction),
      );
}

/// Today: broken promises nobody has followed up (FR-M-072), so staff act on them. Nothing when there are none.
class BrokenPromisesCard extends ConsumerWidget {
  const BrokenPromisesCard({super.key});
  static const _max = 5;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(brokenWithoutFollowUpProvider).value ?? const <PromiseRow>[];
    if (rows.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.heart_broken_rounded, color: context.semanticColors.danger.fg),
          const SizedBox(width: Space.s12),
          Expanded(child: Text(l.todayBrokenTitle, style: t.titleMedium)),
          Text(ref.watch(fmtProvider).num(rows.length), style: t.titleMedium!.copyWith(color: cs.error)),
        ]),
        for (final p in rows.take(_max)) _BrokenRow(promise: p),
      ]),
    );
  }
}

class _BrokenRow extends ConsumerWidget {
  const _BrokenRow({required this.promise});
  final PromiseRow promise;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final c = ref.watch(customerProvider(promise.customerId)).value;
    final name = c?.nameOf(Localizations.localeOf(context).languageCode) ?? '';
    // Text on top, the action below at the end: the action's words do not fit beside a name at 360 dp.
    return Padding(
      padding: const EdgeInsets.only(top: Space.s8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        InkWell(
          onTap: () => context.push('/customers/${promise.customerId}'),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(l.todayBrokenRow(f.money(promise.promisedAmountPoisha), f.date(promise.promisedDate)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
            ]),
          ),
        ),
        Align(alignment: AlignmentDirectional.centerEnd, child: PromiseFollowUpButton(promise: promise)),
      ]),
    );
  }
}
