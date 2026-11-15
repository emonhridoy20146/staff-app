import 'package:material_ui/material_ui.dart';

import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/settings/ui_prefs.dart';
import '../../l10n/app_localizations.dart';
import 'src/notes.dart';

/// Notes on a customer (FR-NOTE-001).
final notesManifest = FeatureManifest(
  name: 'notes',
  flag: 'module.notes',
  permissions: const [Perm.noteCreate, Perm.noteView],
  pullHandlers: [NotePullHandler()],
  pushHandlers: [NotePushHandler()],
  customerActions: [
    CustomerActionDef(
      id: 'note',
      order: 30,
      permission: Perm.noteCreate,
      icon: Icons.edit_note_rounded,
      label: (c) => AppLocalizations.of(c).actionNote,
      onTap: (c, ref, x) => showNoteSheet(c, x.customerId),
    ),
  ],
  timelineSources: [
    TimelineSourceDef(
      id: 'notes',
      watch: (context, ref, id) {
        final l = AppLocalizations.of(context);
        return watchNotesFor(ref, id).map((rows) {
          final f = ref.read(fmtProvider);
          return [
            for (final n in rows)
              TimelineEntry(
                at: n.createdAt,
                icon: Icons.sticky_note_2_rounded,
                title: n.body,
                subtitle: [noteCategoryLabel(l, n.category), f.dateTime(n.createdAt), if (n.authorName != null) n.authorName!].join(' · '),
              ),
          ];
        });
      },
    ),
  ],
);
