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

class NotePullHandler implements PullHandler {
  @override
  String get entity => 'note';
  @override
  Future<void> upsert(AppDatabase db, String id, Json d) async {
    final clientId = (d['clientId'] as String?) ?? id;
    final author = (d['author'] as Json?) ?? const {};
    await db.into(db.notes).insertOnConflictUpdate(NotesCompanion.insert(
          clientId: clientId,
          serverId: Value(id),
          customerId: d['customerId'] as String,
          authorId: Value(author['id'] as String?),
          authorName: Value(author['name'] as String?),
          category: Value((d['category'] as String?) ?? 'general'),
          body: (d['text'] as String?) ?? '',
          createdAt: DateTime.parse(d['createdAt'] as String).toUtc(),
          editableUntil: Value(d['editableUntil'] == null ? null : DateTime.parse(d['editableUntil'] as String).toUtc()),
          syncState: const Value('synced'),
        ));
  }

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) => (db.delete(db.notes)..where((t) => t.serverId.equals(id))).go();
}

class NotePushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'note'};
  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) => (db.update(db.notes)..where((t) => t.clientId.equals(m.mutationId))).write(
        NotesCompanion(serverId: Value(r.entityId), syncState: Value(r.result == 'rejected' ? 'failed' : 'synced')),
      );
}

Stream<List<NoteRow>> watchNotesFor(WidgetRef ref, String customerId) {
  final db = ref.read(databaseProvider);
  return (db.select(db.notes)..where((t) => t.customerId.equals(customerId))..orderBy([(t) => OrderingTerm.desc(t.createdAt)])..limit(20)).watch();
}

Future<void> addNote(WidgetRef ref, {required String customerId, required String text, required String category}) async {
  final db = ref.read(databaseProvider);
  final id = const Uuid().v7();
  final at = ref.read(clockProvider).nowUtc();
  await db.transaction(() async {
    await db.into(db.notes).insert(NotesCompanion.insert(clientId: id, customerId: customerId, body: text, category: Value(category), createdAt: at));
    await ref.read(outboxWriterProvider).enqueue(mutationId: id, entity: 'note', payload: {'clientId': id, 'customerId': customerId, 'text': text, 'category': category});
  });
  unawaited(ref.read(syncEngineProvider).kick(reason: 'note'));
}

const noteCategories = ['general', 'payment', 'address', 'family'];

String noteCategoryLabel(AppLocalizations l, String c) => switch (c) {
      'payment' => l.noteCatPayment,
      'address' => l.noteCatAddress,
      'family' => l.noteCatFamily,
      _ => l.noteCatGeneral,
    };

Future<void> showNoteSheet(BuildContext context, String customerId) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _NoteSheet(customerId: customerId),
    );

class _NoteSheet extends ConsumerStatefulWidget {
  const _NoteSheet({required this.customerId});
  final String customerId;
  @override
  ConsumerState<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends ConsumerState<_NoteSheet> {
  final _text = TextEditingController();
  String _cat = 'general';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(Space.s24, 0, Space.s24, MediaQuery.of(context).viewInsets.bottom + Space.s24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.noteTitle, style: t.titleLarge),
        const SizedBox(height: Space.s12),
        Wrap(spacing: Space.s8, children: [
          for (final c in noteCategories)
            ChoiceChip(selected: _cat == c, showCheckmark: false, label: Text(noteCategoryLabel(l, c)), onSelected: (_) => setState(() => _cat = c)),
        ]),
        const SizedBox(height: Space.s12),
        TextField(controller: _text, autofocus: true, maxLines: 4, maxLength: 2000, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: l.noteHint)),
        const SizedBox(height: Space.s12),
        FilledButton(
          onPressed: _text.text.trim().isEmpty
              ? null
              : () async {
                  await addNote(ref, customerId: widget.customerId, text: _text.text.trim(), category: _cat);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  showAppSnack(context, l.noteSaved);
                },
          child: Text(l.actionSave),
        ),
      ]),
    );
  }
}
