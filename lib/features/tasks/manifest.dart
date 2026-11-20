import 'package:go_router/go_router.dart';

import '../../core/feature/feature_manifest.dart';
import 'src/tasks_data.dart';
import 'src/tasks_screens.dart';
import 'src/work_log.dart';

/// Tasks from the office (master FR-TASK-001..005, contract 1.20.0): a free-form job
/// with a note, not tied to a customer. The staff member says "done" (works offline,
/// the `task_resolve_request` mutation), and only the office makes it resolved.
final tasksManifest = FeatureManifest(
  name: 'tasks',
  flag: 'module.tasks',
  permissions: const ['task.work'],
  routes: [
    GoRoute(path: '/tasks', builder: (_, _) => const TasksScreen()),
    GoRoute(path: '/tasks/:id', builder: (_, s) => TaskDetailScreen(id: s.pathParameters['id']!)),
  ],
  pullHandlers: [TaskPullHandler()],
  pushHandlers: [TaskResolvePushHandler()],
  workLogSources: const [WorkLogSourceDef(id: 'tasks', watch: watchTaskWorkLog)],
  todayCards: [TodayCardDef(id: 'tasks', order: 1, permission: 'task.work', builder: (_) => const TasksTodayCard())],
  meEntries: [MeEntryDef(id: 'tasks', order: 5, permission: 'task.work', builder: (_) => const TasksMeEntry())],
);
