import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/sync/sync_handlers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import 'presentation/customer_detail_screen.dart' show launchCall;

/// Call outcomes (`ContactAttemptCreate.outcome`, contract 1.2.0).
const callOutcomes = ['connected', 'no_answer', 'busy', 'switched_off', 'wrong_number'];

String callOutcomeLabel(AppLocalizations l, String o) => switch (o) {
      'connected' => l.callConnected,
      'no_answer' => l.callNoAnswer,
      'busy' => l.callBusy,
      'switched_off' => l.callSwitchedOff,
      'wrong_number' => l.callWrongNumber,
      _ => l.callUnknown,
    };

IconData callOutcomeIcon(String? o) => switch (o) {
      'connected' => Icons.call_rounded,
      'no_answer' => Icons.phone_missed_rounded,
      'busy' => Icons.phone_locked_rounded,
      'switched_off' => Icons.phone_disabled_rounded,
      'wrong_number' => Icons.wrong_location_rounded,
      _ => Icons.call_made_rounded,
    };

class ContactAttemptPullHandler implements PullHandler {
  @override
  String get entity => 'contact_attempt';
  @override
  Future<void> upsert(AppDatabase db, String id, Json d) => db.into(db.contactAttempts).insertOnConflictUpdate(ContactAttemptsCompanion.insert(
        clientId: (d['clientId'] as String?) ?? id,
        serverId: Value(id),
        customerId: d['customerId'] as String,
        channel: (d['channel'] as String?) ?? 'call',
        phoneIndex: Value((d['phoneIndex'] as num?)?.toInt()),
        at: DateTime.parse(d['at'] as String).toUtc(),
        outcome: Value(d['outcome'] as String?),
        note: Value(d['note'] as String?),
        syncState: const Value('synced'),
      ));

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) =>
      (db.delete(db.contactAttempts)..where((t) => t.serverId.equals(id))).go();
}

class ContactAttemptPushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'contact_attempt'};
  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) =>
      (db.update(db.contactAttempts)..where((t) => t.clientId.equals(m.mutationId))).write(
        ContactAttemptsCompanion(serverId: Value(r.entityId), syncState: Value(r.result == 'rejected' ? 'failed' : 'synced')),
      );
}

/// Records a call attempt offline-first (FR-M-014). Only the phone's index
/// is stored and sent — never the number.
Future<void> recordContactAttempt(Ref ref, {required String customerId, required int phoneIndex, required DateTime at, String? outcome}) async {
  final db = ref.read(databaseProvider);
  final id = const Uuid().v7();
  await db.transaction(() async {
    await db.into(db.contactAttempts).insert(ContactAttemptsCompanion.insert(
          clientId: id,
          customerId: customerId,
          channel: 'call',
          phoneIndex: Value(phoneIndex),
          at: at,
          outcome: Value(outcome),
        ));
    await ref.read(outboxWriterProvider).enqueue(mutationId: id, entity: 'contact_attempt', payload: {
      'clientId': id,
      'customerId': customerId,
      'channel': 'call',
      'phoneIndex': phoneIndex,
      'at': at.toIso8601String(),
      'outcome': ?outcome,
    });
  });
  unawaited(ref.read(syncEngineProvider).kick(reason: 'contact'));
}

final contactAttemptServiceProvider = Provider<ContactAttemptService>(ContactAttemptService.new);

class ContactAttemptService {
  ContactAttemptService(this._ref);
  final Ref _ref;
  Future<void> record({required String customerId, required int phoneIndex, required DateTime at, String? outcome}) =>
      recordContactAttempt(_ref, customerId: customerId, phoneIndex: phoneIndex, at: at, outcome: outcome);
}

Stream<List<ContactAttemptRow>> watchContactAttempts(AppDatabase db, String customerId) =>
    (db.select(db.contactAttempts)..where((t) => t.customerId.equals(customerId))..orderBy([(t) => OrderingTerm.desc(t.at)])..limit(10)).watch();

/// Dials, then asks how the call went. If the sheet is dismissed the
/// attempt is still logged without an outcome.
Future<void> callAndLog(BuildContext context, WidgetRef ref, {required String customerId, required List<String> phones, int index = 0}) async {
  final at = ref.read(clockProvider).nowUtc();
  await launchCall(phones[index]);
  if (!context.mounted) return;
  final outcome = await showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    builder: (_) => const _OutcomeSheet(),
  );
  await ref.read(contactAttemptServiceProvider).record(customerId: customerId, phoneIndex: index, at: at, outcome: outcome);
  if (context.mounted && outcome != null) showAppSnack(context, AppLocalizations.of(context).callSaved);
}

class _OutcomeSheet extends StatelessWidget {
  const _OutcomeSheet();
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.s24, 0, Space.s24, Space.s24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.callHowWasIt, style: t.titleLarge),
        const SizedBox(height: Space.s12),
        for (final o in callOutcomes)
          ListTile(
            minTileHeight: 56,
            leading: Icon(callOutcomeIcon(o)),
            title: Text(callOutcomeLabel(l, o)),
            onTap: () => Navigator.of(context).pop(o),
          ),
      ]),
    );
  }
}
