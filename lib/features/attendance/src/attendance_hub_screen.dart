import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/time/clock.dart';
import '../../../core/settings/duty_settings.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import 'attendance_data.dart';
import 'attendance_domain.dart';
import 'attendance_widgets.dart' show recordAttendance;

/// Attendance hub: today's duty header with action buttons, plus full history
/// of past days. Navigates to WorkInScreen / WorkOutScreen for the actual
/// selfie + GPS step (the existing flow is unchanged).
class AttendanceHubScreen extends ConsumerStatefulWidget {
  const AttendanceHubScreen({super.key});
  @override
  ConsumerState<AttendanceHubScreen> createState() => _AttendanceHubState();
}

class _AttendanceHubState extends ConsumerState<AttendanceHubScreen> with WidgetsBindingObserver {
  bool _gpsOn = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkGps();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkGps();
  }

  Future<void> _checkGps() async {
    final on = await Geolocator.isLocationServiceEnabled();
    if (mounted && on != _gpsOn) setState(() => _gpsOn = on);
  }

  Future<void> _doBreak(AttendanceEventType type) async {
    setState(() => _busy = true);
    await recordAttendance(context, ref, type);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    ref.watch(minuteTickerProvider);
    final day = ref.watch(todayAttendanceProvider).value;
    final history = ref.watch(recentAttendanceDaysProvider).value ?? const <AttendanceDayRow>[];
    final now = ref.read(clockProvider).nowUtc();
    final settings = ref.watch(serverSettingsProvider);
    final duty = DutySettings.of(settings);
    final businessDate = ref.watch(clockProvider).businessDate();

    final onDuty = day?.status == DayStatus.onDuty;
    final onBreak = day?.status == DayStatus.onBreak;
    final notStarted = day == null || day.status == DayStatus.notStarted;
    final ended = day?.status == DayStatus.offDuty;
    final isLate = (day?.lateMin ?? 0) > 0;
    // Break time inside the day's window (the Friday break) is not held against the limit.
    final overBreak = onBreak &&
        day != null &&
        duty.overBreakMin([for (final b in day.breaks) (start: b.start, end: b.end)], businessDate: businessDate, dhakaMidnightUtc: businessDayStartUtc(businessDate), now: now) > 0;

    // Late days per month and the absent days they count as (two late days = one absent day).
    final lateRows = [for (final r in history) (date: r.businessDate, lateMin: r.lateMin)];
    final months = {for (final r in history) r.businessDate.substring(0, 7)};
    final perAbsence = lateDaysPerAbsentOf(settings);
    final absenceDates = {for (final m in months) ...lateTally(lateRows, month: m, latePerAbsence: perAbsence).absenceDates};
    final thisMonth = lateTally(lateRows, month: businessDate.substring(0, 7), latePerAbsence: perAbsence);
    final f = ref.watch(fmtProvider);

    final bgColor = onDuty ? sem.success.bg : (onBreak ? sem.warning.bg : cs.surfaceContainer);
    final fgColor = onDuty ? sem.success.fg : (onBreak ? sem.warning.fg : cs.onSurface);

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: onBreak ? 270 : 230,
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            title: Text(l.attHubTitle, style: t.titleMedium),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _HubHeader(
                day: day,
                now: now,
                gpsOn: _gpsOn,
                busy: _busy,
                onBreak: onBreak,
                onDuty: onDuty,
                notStarted: notStarted,
                ended: ended,
                overBreak: overBreak,
                isLate: isLate,
                onDoBreak: _doBreak,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
            sliver: SliverList.list(children: [
              Text(l.attHubHistory, style: t.titleSmall),
              const SizedBox(height: Space.s8),
              if (thisMonth.lateDays > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s8),
                  decoration: BoxDecoration(color: thisMonth.absences > 0 ? sem.danger.bg : sem.warning.bg, borderRadius: Radii.brMd),
                  child: Row(children: [
                    Icon(Icons.warning_amber_rounded, size: 20, color: thisMonth.absences > 0 ? sem.danger.fg : sem.warning.fg),
                    const SizedBox(width: Space.s8),
                    Expanded(
                      child: Text(
                        l.attHubLateMonth(f.num(thisMonth.lateDays), f.num(thisMonth.absences)),
                        style: t.bodyMedium!.copyWith(color: thisMonth.absences > 0 ? sem.danger.fg : sem.warning.fg, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: Space.s8),
              ],
              if (history.isEmpty)
                EmptyState(icon: Icons.event_busy_rounded, title: l.attHubNoHistory, body: '')
              else
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(children: [
                    for (var i = 0; i < history.length; i++) ...[
                      if (i > 0) const Divider(height: 1, indent: Space.s16, endIndent: Space.s16),
                      _AttendanceDayTile(
                        row: history[i],
                        // Every second late day of a month counts as one absent day (owner rule).
                        absenceStreak: absenceDates.contains(history[i].businessDate),
                      ),
                    ],
                  ]),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _HubHeader extends ConsumerWidget {
  const _HubHeader({
    required this.day,
    required this.now,
    required this.gpsOn,
    required this.busy,
    required this.onBreak,
    required this.onDuty,
    required this.notStarted,
    required this.ended,
    required this.overBreak,
    required this.isLate,
    required this.onDoBreak,
  });
  final AttendanceDay? day;
  final DateTime now;
  final bool gpsOn, busy, onBreak, onDuty, notStarted, ended, overBreak, isLate;
  final Future<void> Function(AttendanceEventType) onDoBreak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    final fgColor = onDuty ? sem.success.fg : (onBreak ? sem.warning.fg : cs.onSurfaceVariant);

    return Container(
      color: onDuty ? sem.success.bg : (onBreak ? sem.warning.bg : cs.surfaceContainer),
      padding: const EdgeInsets.fromLTRB(Space.screen, 72, Space.screen, Space.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status line
          Row(children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: fgColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: Space.s8),
            Text(
              notStarted
                  ? l.attHubStatusNotStarted
                  : (ended
                      ? l.attHubStatusOffDuty
                      : (onBreak ? l.attHubStatusOnBreak : l.attHubStatusOnDuty)),
              style: t.titleSmall!.copyWith(color: fgColor),
            ),
          ]),
          const SizedBox(height: Space.s8),
          if (day?.firstIn != null) ...[
            Row(children: [
              Icon(Icons.login_rounded, size: 18, color: fgColor),
              const SizedBox(width: Space.s4),
              Text(l.meInToday(f.time(day!.firstIn!)), style: t.bodyMedium!.copyWith(color: fgColor)),
              if (day!.lastOut != null) ...[
                const SizedBox(width: Space.s12),
                Icon(Icons.logout_rounded, size: 18, color: fgColor),
                const SizedBox(width: Space.s4),
                Text(l.attHubOut(f.time(day!.lastOut!)), style: t.bodyMedium!.copyWith(color: fgColor)),
              ],
            ]),
            const SizedBox(height: Space.s4),
            Row(children: [
              Icon(Icons.work_rounded, size: 18, color: fgColor),
              const SizedBox(width: Space.s4),
              Text('${l.attHubWorkTime}: ${f.duration(day!.dutyTotal(now))}', style: t.bodyMedium!.copyWith(color: fgColor)),
              if (day!.breaks.isNotEmpty) ...[
                const SizedBox(width: Space.s12),
                Icon(Icons.coffee_rounded, size: 18, color: fgColor),
                const SizedBox(width: Space.s4),
                Text(l.meBreakTotal(f.duration(day!.breakTotal(now))), style: t.bodyMedium!.copyWith(color: fgColor)),
              ],
            ]),
          ],
          if (isLate) ...[
            const SizedBox(height: Space.s4),
            Row(children: [
              Icon(Icons.schedule_rounded, size: 18, color: sem.warning.fg),
              const SizedBox(width: Space.s4),
              Text(l.attHubLateWarning(f.minutes(day!.lateMin)), style: t.bodySmall!.copyWith(color: sem.warning.fg, fontWeight: FontWeight.w600)),
            ]),
          ],
          if (overBreak) ...[
            const SizedBox(height: Space.s4),
            Row(children: [
              Icon(Icons.timer_off_rounded, size: 18, color: sem.warning.fg),
              const SizedBox(width: Space.s4),
              Text(l.meBreakTotal(f.duration(day!.breakTotal(now))), style: t.bodySmall!.copyWith(color: sem.warning.fg, fontWeight: FontWeight.w600)),
            ]),
          ],
          const SizedBox(height: Space.s12),
          // GPS warning
          if (!gpsOn)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s8),
                decoration: BoxDecoration(color: sem.danger.bg, borderRadius: Radii.brMd),
                child: Row(children: [
                  Icon(Icons.location_off_rounded, size: 16, color: sem.danger.fg),
                  const SizedBox(width: Space.s4),
                  Expanded(child: Text(l.gpsStatusOff, style: t.labelSmall!.copyWith(color: sem.danger.fg))),
                  GestureDetector(
                    onTap: Geolocator.openLocationSettings,
                    child: Text(l.gpsTurnOn, style: t.labelSmall!.copyWith(color: sem.danger.fg, decoration: TextDecoration.underline)),
                  ),
                ]),
              ),
            ),
          // Action buttons
          Row(children: [
            if (notStarted || ended)
              Expanded(
                child: FilledButton.icon(
                  onPressed: gpsOn && !busy ? () => context.push('/attendance/work-in') : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l.dutyStartWork),
                ),
              ),
            if (onDuty || onBreak) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (gpsOn && !busy) ? () => onDoBreak(onBreak ? AttendanceEventType.breakEnd : AttendanceEventType.breakStart) : null,
                  icon: Icon(onBreak ? Icons.play_circle_rounded : Icons.coffee_rounded),
                  label: Text(onBreak ? l.dutyEndBreak : l.dutyStartBreak),
                ),
              ),
              const SizedBox(width: Space.s8),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
                  onPressed: (gpsOn && !busy && onDuty) ? () => context.push('/attendance/work-out') : null,
                  icon: const Icon(Icons.stop_rounded),
                  label: Text(l.dutyEndWork),
                ),
              ),
            ],
          ]),
          if (onBreak) ...[
            const SizedBox(height: Space.s8),
            Row(children: [
              Icon(Icons.info_outline_rounded, size: 18, color: sem.warning.fg),
              const SizedBox(width: Space.s4),
              Expanded(child: Text(l.dutyEndBreakFirst, style: t.bodySmall!.copyWith(color: sem.warning.fg, fontWeight: FontWeight.w600))),
            ]),
          ],
        ],
      ),
    );
  }
}

class _AttendanceDayTile extends ConsumerWidget {
  const _AttendanceDayTile({required this.row, this.absenceStreak = false});
  final AttendanceDayRow row;
  final bool absenceStreak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    final l = AppLocalizations.of(context);
    final notStarted = row.status == 'not_started';
    final ended = row.status == 'off_duty';
    final late = row.lateMin > 0;
    // FR-M-051: the server's marks of the day (contract 1.25.0). On a weekly off day or holiday every
    // worked minute is overtime, so that day says "worked on a day off" instead.
    final offDay = row.status == 'weekly_off' || row.status == 'holiday';
    final overtime = row.overtimeMin > 0;
    final overBreak = row.overBreakMin > 0;
    final worked = (row.firstIn != null && row.lastOut != null)
        ? row.lastOut!.difference(row.firstIn!) - Duration(minutes: row.breakMin)
        : null;

    // A late day that completes a pair in its month counts as an absent day (red); other late days are amber.
    final badgeBg = absenceStreak ? sem.danger.bg : sem.warning.bg;
    final badgeFg = absenceStreak ? sem.danger.fg : sem.warning.fg;

    return ListTile(
      minTileHeight: Sizes.minTarget + 8,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: absenceStreak
              ? sem.danger.bg
              : (notStarted ? cs.surfaceContainerHigh : (ended ? cs.primaryContainer : sem.success.bg)),
          borderRadius: Radii.brMd,
        ),
        child: Icon(
          absenceStreak
              ? Icons.warning_amber_rounded
              : (notStarted ? Icons.event_busy_rounded : Icons.event_available_rounded),
          size: 20,
          color: absenceStreak
              ? sem.danger.fg
              : (notStarted ? cs.onSurfaceVariant : (ended ? cs.onPrimaryContainer : sem.success.fg)),
        ),
      ),
      title: Text(f.date(row.businessDate, withYear: true), style: t.bodyLarge),
      subtitle: notStarted
          ? Text(l.attHubStatusNotStarted, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    if (row.firstIn != null) l.meInToday(f.time(row.firstIn!)),
                    if (row.lastOut != null) l.attHubOut(f.time(row.lastOut!)),
                  ].join(' · '),
                  style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                ),
                if (worked != null)
                  Text(
                    '${l.attHubWorkTime}: ${f.duration(worked)} · ${l.meBreakTotal(f.duration(Duration(minutes: row.breakMin)))}',
                    style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                if (absenceStreak)
                  Text(l.attHubAbsenceStreak, style: t.labelSmall!.copyWith(color: sem.danger.fg, fontWeight: FontWeight.w600)),
                if (late || overtime || overBreak)
                  Padding(
                    padding: const EdgeInsets.only(top: Space.s4),
                    child: Wrap(
                      spacing: Space.s4,
                      runSpacing: Space.s4,
                      children: [
                        if (late) _DayMark(text: l.attHubLateWarning(f.minutes(row.lateMin)), bg: badgeBg, fg: badgeFg, semantics: 'late'),
                        if (overBreak)
                          _DayMark(text: l.attHubOverBreak(f.minutes(row.overBreakMin)), bg: sem.warning.bg, fg: sem.warning.fg, semantics: 'over_break'),
                        if (overtime)
                          _DayMark(
                            text: offDay ? l.attHubOffDayWork(f.minutes(row.overtimeMin)) : l.attHubOvertime(f.minutes(row.overtimeMin)),
                            bg: sem.success.bg,
                            fg: sem.success.fg,
                            semantics: 'overtime',
                          ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

/// One small mark on a day row: late, break over the limit, overtime (FR-M-051). Words, not only colour.
class _DayMark extends StatelessWidget {
  const _DayMark({required this.text, required this.bg, required this.fg, required this.semantics});
  final String text;
  final Color bg;
  final Color fg;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      key: Key('day-mark-$semantics'),
      padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: Space.s4),
      decoration: BoxDecoration(color: bg, borderRadius: Radii.brSm),
      child: Text(text, style: t.labelSmall!.copyWith(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
