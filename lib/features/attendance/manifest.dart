import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import '../../core/feature/feature_manifest.dart';
import '../../core/providers.dart' show serverSettingsProvider;
import '../../core/settings/duty_settings.dart';
import '../../core/theme/tag_colors.dart' show ActionTone;
import '../../core/permissions/permission_service.dart';
import 'src/attendance_data.dart';
import 'src/attendance_domain.dart';
import 'src/attendance_hub_screen.dart';
import 'src/attendance_widgets.dart';
import 'src/leave_screens.dart';

/// Attendance: work-in/out, breaks, summary, leave requests, holidays and
/// my shift (FR-ATT-001, 002, 005, 007, 008, FR-SET-002/003, FR-M-028).
bool _required(WidgetRef ref) => ref.watch(attendanceShownProvider);

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
    MeEntryDef(id: 'attendance', order: 0, permission: Perm.attendanceRecord, builder: (_) => const AttendanceCard(), visible: _required),
    // Leave, holidays and my shift (FR-M-028, contract 1.12.0).
    MeEntryDef(id: 'leave', order: 1, permission: Perm.attendanceRecord, builder: (_) => const LeaveMeEntry()),
  ],
  quickActions: [
    QuickActionDef(
      id: 'attendance',
      order: 10,
      icon: Icons.work_history_rounded,
      tone: ActionTone.brand,
      label: (l) => l.attendanceBtn,
      route: '/attendance',
      visible: _required,
      // FR-M-042: whether today's attendance is still to be given.
      state: (ref, l) {
        final day = ref.watch(todayAttendanceProvider).value;
        final given = day != null && day.status != DayStatus.notStarted;
        return QuickActionState(done: given, label: given ? l.attTileDone : l.attTilePending);
      },
    ),
    QuickActionDef(id: 'leave', order: 90, icon: Icons.beach_access_rounded, tone: ActionTone.amber, label: (l) => l.leaveTitle, route: '/attendance/leave', permission: Perm.leaveRequest),
  ],
  settingsRows: [
    // The office's duty hours as the server sent them (FR-M-047), and the way to holidays and my shift.
    SettingsRowDef(
      id: 'calendar',
      section: SettingsSection.work,
      order: 20,
      icon: Icons.calendar_month_rounded,
      tone: ActionTone.amber,
      title: (l) => l.calendarTitle,
      hint: (l) => l.settingsCalendarHint,
      value: (ref, l, f) {
        final d = DutySettings.of(ref.watch(serverSettingsProvider));
        return f.num('${d.start}–${d.end}');
      },
      route: '/attendance/calendar',
      permission: Perm.attendanceRecord,
    ),
  ],
);
