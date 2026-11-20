import 'package:go_router/go_router.dart';

import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import 'src/attendance_data.dart';
import 'src/attendance_hub_screen.dart';
import 'src/attendance_widgets.dart';
import 'src/leave_screens.dart';

/// Attendance: work-in/out, breaks, summary, leave requests, holidays and
/// my shift (FR-ATT-001, 002, 005, 007, 008, FR-SET-002/003, FR-M-028).
final attendanceManifest = FeatureManifest(
  name: 'attendance',
  flag: 'module.attendance',
  permissions: const [Perm.attendanceRecord, Perm.leaveRequest],
  routes: [
    GoRoute(path: '/attendance', builder: (_, _) => const AttendanceHubScreen()),
    GoRoute(path: '/attendance/work-in', builder: (_, _) => const WorkInScreen()),
    GoRoute(path: '/attendance/work-out', builder: (_, _) => const WorkOutScreen()),
    GoRoute(path: '/attendance/leave', builder: (_, _) => const LeaveScreen()),
    GoRoute(path: '/attendance/leave/new', builder: (_, _) => const LeaveRequestScreen()),
    GoRoute(path: '/attendance/calendar', builder: (_, _) => const WorkCalendarScreen()),
  ],
  pullHandlers: [AttendanceDayPullHandler()],
  pushHandlers: [AttendancePushHandler()],
  meEntries: [
    MeEntryDef(id: 'attendance', order: 0, permission: Perm.attendanceRecord, builder: (_) => const AttendanceCard()),
    // Leave, holidays and my shift (FR-M-028, contract 1.12.0).
    MeEntryDef(id: 'leave', order: 1, permission: Perm.attendanceRecord, builder: (_) => const LeaveMeEntry()),
  ],
);
