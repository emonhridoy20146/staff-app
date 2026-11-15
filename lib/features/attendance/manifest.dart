import 'package:go_router/go_router.dart';

import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import 'src/attendance_data.dart';
import 'src/attendance_widgets.dart';

/// Attendance: work-in/out, breaks, summary (FR-ATT-001, 002, 005, 007, 008).
final attendanceManifest = FeatureManifest(
  name: 'attendance',
  flag: 'module.attendance',
  permissions: const [Perm.attendanceRecord, Perm.leaveRequest],
  routes: [
    GoRoute(path: '/attendance/work-in', builder: (_, _) => const WorkInScreen()),
    GoRoute(path: '/attendance/work-out', builder: (_, _) => const WorkOutScreen()),
  ],
  pullHandlers: [AttendanceDayPullHandler()],
  pushHandlers: [AttendancePushHandler()],
  meEntries: [MeEntryDef(id: 'attendance', order: 0, permission: Perm.attendanceRecord, builder: (_) => const AttendanceCard())],
);
