import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import 'tasks_data.dart';

/// Status as colour + icon + label (design guide §3: never colour alone).
class TaskStatusChip extends ConsumerWidget {
  const TaskStatusChip({super.key, required this.task});
  final StaffTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = context.semanticColors;
    final cs = Theme.of(context).colorScheme;
    final today = ref.watch(clockProvider).businessDate();
    final (fg, bg, icon, label) = switch (task.shownStatus) {
      'resolved' => (s.success.fg, s.success.bg, Icons.check_circle_rounded, l.taskStatusResolved),
      'cancelled' => (cs.onSurfaceVariant, cs.surfaceContainerHigh, Icons.block_rounded, l.taskStatusCancelled),
      'resolve_requested' => task.resolveQueued
          ? (s.info.fg, s.info.bg, Icons.cloud_upload_rounded, l.taskStatusQueued)
          : (s.warning.fg, s.warning.bg, Icons.hourglass_top_rounded, l.taskStatusWaiting),
      _ => task.isOverdue(today)
          ? (s.danger.fg, s.danger.bg, Icons.error_rounded, l.taskStatusOverdue)
          : (s.info.fg, s.info.bg, Icons.radio_button_unchecked_rounded, l.taskStatusOpen),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: Space.s2),
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.all(Radius.circular(Radii.full))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: fg),
        const SizedBox(width: Space.s4),
        Text(label, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: fg, height: 1.2)),
      ]),
    );
  }
}

/// `/tasks`: my tasks. What needs me first, then what the office is checking, then what is finished.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tasks = ref.watch(tasksProvider).value ?? const <StaffTask>[];
    final active = [for (final t in tasks) if (t.isOpen) t];
    final waiting = [for (final t in tasks) if (t.isWaiting) t];
    final closed = [for (final t in tasks) if (t.isClosed) t];
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(title: Text(l.tasksTitle), backgroundColor: cs.surfaceContainer),
      body: tasks.isEmpty
          ? Center(child: EmptyState(icon: Icons.task_alt_rounded, title: l.tasksEmpty, body: l.tasksEmptyBody))
          : ListView(
              padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
              children: [
                for (final (label, list) in [(l.tasksSectionActive, active), (l.tasksSectionWaiting, waiting), (l.tasksSectionClosed, closed)])
                  if (list.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: Space.s8, bottom: Space.s8),
                      child: Text(label, style: Theme.of(context).textTheme.titleSmall!.copyWith(color: cs.onSurfaceVariant)),
                    ),
                    for (final t in list) ...[
                      _TaskTile(task: t),
                      const SizedBox(height: Space.cardGap),
                    ],
                  ],
              ],
            ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});
  final StaffTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final s = context.semanticColors;
    final f = ref.watch(fmtProvider);
    final today = ref.watch(clockProvider).businessDate();
    final overdue = task.isOverdue(today);
    final due = task.row.dueDate;
    return AppCard(
      onTap: () => context.push('/tasks/${task.id}'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Text(
              task.row.title,
              style: t.titleMedium!.copyWith(fontWeight: task.isNew ? FontWeight.w700 : FontWeight.w500),
            ),
          ),
          const SizedBox(width: Space.s8),
          TaskStatusChip(task: task),
        ]),
        if (task.row.note?.isNotEmpty == true) ...[
          const SizedBox(height: Space.s4),
          Text(task.row.note!, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.bodyMedium),
        ],
        const SizedBox(height: Space.s8),
        Wrap(spacing: Space.s12, runSpacing: Space.s4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          if (task.isNew)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.fiber_new_rounded, size: 18, color: s.info.fg),
              const SizedBox(width: Space.s4),
              Text(l.taskNew, style: t.bodySmall!.copyWith(color: s.info.fg, fontWeight: FontWeight.w700)),
            ]),
          Text(
            due == null ? l.taskNoDue : l.taskDue(f.date(due)),
            style: t.bodySmall!.copyWith(color: overdue ? s.danger.fg : cs.onSurfaceVariant, fontWeight: overdue ? FontWeight.w700 : FontWeight.w400),
          ),
          if (task.row.createdByName?.isNotEmpty == true) Text(l.taskFrom(task.row.createdByName!), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        ]),
      ]),
    );
  }
}

/// Asks for an optional note, then saves the "done" request. Returns true when it was saved.
Future<bool> askAndRequestResolve(BuildContext context, WidgetRef ref, String taskId) async {
  final note = await showDialog<String>(context: context, builder: (_) => const _ResolveDialog());
  if (note == null) return false;
  await ref.read(taskServiceProvider).requestResolve(taskId, note: note);
  return true;
}

/// The "tell the office it is done" dialog. It owns its text controller, so the controller lives
/// exactly as long as the dialog, closing animation included.
class _ResolveDialog extends StatefulWidget {
  const _ResolveDialog();

  @override
  State<_ResolveDialog> createState() => _ResolveDialogState();
}

class _ResolveDialogState extends State<_ResolveDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.taskDoneTitle),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.taskDoneBody),
          const SizedBox(height: Space.s12),
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 1000,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(hintText: l.taskDoneNoteHint),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.actionCancel)),
        FilledButton(onPressed: () => Navigator.of(context).pop(_controller.text), child: Text(l.taskDoneSend)),
      ],
    );
  }
}

/// `/tasks/:id`: the whole task, the office's words, my note, history and the "done" button.
class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Opening it clears the "new" marker (after the first frame: it writes to the database).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(taskServiceProvider).markSeen(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final task = ref.watch(taskProvider(widget.id)).value;
    if (task == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.tasksEmpty)));
    }
    final s = context.semanticColors;
    final today = ref.watch(clockProvider).businessDate();
    final overdue = task.isOverdue(today);
    final due = task.row.dueDate;
    final events = task.events;
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(title: Text(l.taskTitle), backgroundColor: cs.surfaceContainer),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
        children: [
          Align(alignment: AlignmentDirectional.centerStart, child: TaskStatusChip(task: task)),
          const SizedBox(height: Space.s12),
          Text(task.row.title, style: t.headlineSmall),
          const SizedBox(height: Space.s4),
          Text(
            [
              if (task.row.createdByName?.isNotEmpty == true) l.taskFrom(task.row.createdByName!),
              f.dateTime(task.row.createdAt),
            ].join(' · '),
            style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: Space.s8),
          Row(children: [
            Icon(Icons.event_rounded, size: 18, color: overdue ? s.danger.fg : cs.onSurfaceVariant),
            const SizedBox(width: Space.s8),
            Expanded(
              child: Text(
                due == null ? l.taskNoDue : l.taskDue(f.date(due, withYear: true)),
                style: t.bodyMedium!.copyWith(color: overdue ? s.danger.fg : cs.onSurfaceVariant, fontWeight: overdue ? FontWeight.w700 : FontWeight.w400),
              ),
            ),
          ]),
          const SizedBox(height: Space.s16),
          if (task.wasRejected) ...[
            InfoBanner(icon: Icons.undo_rounded, tone: BannerTone.warning, text: l.taskRejectedBanner(task.row.decisionNote!)),
            const SizedBox(height: Space.s12),
          ],
          if (task.resolveFailed) ...[
            InfoBanner(icon: Icons.error_outline_rounded, tone: BannerTone.danger, text: l.taskFailedBanner),
            const SizedBox(height: Space.s12),
          ],
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.taskDetails, style: t.titleSmall!.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: Space.s8),
              SelectableText(
                task.row.note?.isNotEmpty == true ? task.row.note! : l.taskNoteNone,
                style: t.bodyLarge!.copyWith(color: task.row.note?.isNotEmpty == true ? null : cs.onSurfaceVariant),
              ),
            ]),
          ),
          if (task.resolveQueued) ...[
            const SizedBox(height: Space.s16),
            InfoBanner(icon: Icons.cloud_upload_rounded, tone: BannerTone.info, text: l.taskQueuedBanner(f.time(task.row.resolveRequestedAt ?? task.row.createdAt))),
          ] else if (task.isWaiting) ...[
            const SizedBox(height: Space.s16),
            InfoBanner(icon: Icons.hourglass_top_rounded, tone: BannerTone.warning, text: l.taskWaitingBanner(f.dateTime(task.row.resolveRequestedAt ?? task.row.updatedAt ?? task.row.createdAt))),
          ] else if (task.isResolved) ...[
            const SizedBox(height: Space.s16),
            InfoBanner(icon: Icons.check_circle_rounded, tone: BannerTone.success, text: l.taskResolvedBanner(f.dateTime(task.row.decidedAt ?? task.row.updatedAt ?? task.row.createdAt))),
          ] else if (task.isCancelled) ...[
            const SizedBox(height: Space.s16),
            InfoBanner(icon: Icons.block_rounded, tone: BannerTone.warning, text: l.taskCancelledBanner),
          ],
          if (task.row.resolveNote?.isNotEmpty == true && !task.isOpen) ...[
            const SizedBox(height: Space.s12),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.taskMyNote, style: t.titleSmall!.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: Space.s8),
                SelectableText(task.row.resolveNote!, style: t.bodyLarge),
              ]),
            ),
          ],
          if ((task.isResolved || task.isCancelled) && task.row.decisionNote?.isNotEmpty == true) ...[
            const SizedBox(height: Space.s12),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.taskOfficeNote, style: t.titleSmall!.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: Space.s8),
                SelectableText(task.row.decisionNote!, style: t.bodyLarge),
              ]),
            ),
          ],
          if (events.isNotEmpty) ...[
            const SizedBox(height: Space.s24),
            Text(l.taskHistory, style: t.titleSmall!.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: Space.s8),
            for (final e in events.reversed)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.s8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(_eventIcon(e.type), size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: Space.s8),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${_eventLabel(l, e.type)} · ${e.by}', style: t.bodyMedium),
                      Text(f.dateTime(e.at), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                      if (e.note?.isNotEmpty == true) Text(e.note!, style: t.bodySmall),
                    ]),
                  ),
                ]),
              ),
          ],
        ],
      ),
      bottomNavigationBar: task.canRequestResolve
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Space.screen, Space.s12, Space.screen, Space.s12),
                child: SizedBox(
                  height: Sizes.primaryButton,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final saved = await askAndRequestResolve(context, ref, task.id);
                      if (saved && context.mounted) showAppSnack(context, l.taskDoneSent);
                    },
                    icon: const Icon(Icons.task_alt_rounded),
                    label: Text(l.taskMarkDone),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

IconData _eventIcon(String type) => switch (type) {
      'created' => Icons.assignment_add,
      'edited' => Icons.edit_rounded,
      'resolve_requested' => Icons.hourglass_top_rounded,
      'verified' => Icons.check_circle_rounded,
      'rejected' => Icons.undo_rounded,
      'cancelled' => Icons.block_rounded,
      _ => Icons.circle_outlined,
    };

String _eventLabel(AppLocalizations l, String type) => switch (type) {
      'created' => l.taskEventCreated,
      'edited' => l.taskEventEdited,
      'resolve_requested' => l.taskEventResolveRequested,
      'verified' => l.taskEventVerified,
      'rejected' => l.taskEventRejected,
      'cancelled' => l.taskEventCancelled,
      _ => type,
    };

/// Today: tasks that need me (overdue first, then new, then to do). Hidden when there is nothing.
class TasksTodayCard extends ConsumerWidget {
  const TasksTodayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final today = ref.watch(clockProvider).businessDate();
    final open = ref.watch(openTasksProvider);
    if (open.isEmpty) return const SizedBox.shrink();
    final overdue = [for (final t in open) if (t.isOverdue(today)) t].length;
    final fresh = ref.watch(newTasksProvider).length;
    final (tone, icon, text) = overdue > 0
        ? (BannerTone.danger, Icons.assignment_late_rounded, l.todayTasksOverdue(f.num(overdue)))
        : fresh > 0
            ? (BannerTone.info, Icons.assignment_add, l.todayTasksNew(f.num(fresh)))
            : (BannerTone.info, Icons.assignment_rounded, l.todayTasksOpen(f.num(open.length)));
    return InfoBanner(
      icon: icon,
      tone: tone,
      text: text,
      onTap: () => context.push(open.length == 1 ? '/tasks/${open.first.id}' : '/tasks'),
    );
  }
}

/// Me: my tasks with the number still to do.
class TasksMeEntry extends ConsumerWidget {
  const TasksMeEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final n = ref.watch(openTasksProvider).length;
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/tasks'),
      child: ListTile(
        minTileHeight: 64,
        leading: const Icon(Icons.assignment_rounded),
        title: Text(l.tasksTitle),
        subtitle: Text(n > 0 ? l.tasksOpenCount(f.num(n)) : l.tasksNothingOpen),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (n > 0) Badge(label: Text(f.num(n))),
          const Icon(Icons.chevron_right_rounded),
        ]),
      ),
    );
  }
}
