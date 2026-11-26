import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/permissions/permission_service.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/time/clock.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/auth.dart';
import 'leave_data.dart';

String leaveTypeLabel(AppLocalizations l, LeaveType t) => switch (t) {
      LeaveType.casual => l.leaveTypeCasual,
      LeaveType.sick => l.leaveTypeSick,
      LeaveType.other => l.leaveTypeOther,
    };

String weekdayName(AppLocalizations l, int serverWeekday) => switch (serverWeekday) {
      0 => l.weekdaySun,
      1 => l.weekdayMon,
      2 => l.weekdayTue,
      3 => l.weekdayWed,
      4 => l.weekdayThu,
      5 => l.weekdayFri,
      _ => l.weekdaySat,
    };

String leaveErrorText(AppLocalizations l, LeaveError e) => switch (e) {
      LeaveError.offline => l.leaveNeedsInternet,
      LeaveError.overlaps => l.leaveErrOverlaps,
      LeaveError.tooLong => l.leaveErrTooLong,
      LeaveError.alreadyDecided => l.leaveErrDecided,
      LeaveError.failed => l.errorGeneric,
    };

/// Status as colour + icon + label.
class LeaveStatusChip extends StatelessWidget {
  const LeaveStatusChip({super.key, required this.status});
  final LeaveStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = context.semanticColors;
    final cs = Theme.of(context).colorScheme;
    final (fg, bg, icon, label) = switch (status) {
      LeaveStatus.pending => (s.warning.fg, s.warning.bg, Icons.hourglass_top_rounded, l.leavePending),
      LeaveStatus.approved => (s.success.fg, s.success.bg, Icons.check_circle_rounded, l.leaveApproved),
      LeaveStatus.rejected => (s.danger.fg, s.danger.bg, Icons.cancel_rounded, l.leaveRejected),
      LeaveStatus.cancelled => (cs.onSurfaceVariant, cs.surfaceContainerHigh, Icons.block_rounded, l.leaveCancelled),
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

/// My requests (online, cached for offline reading).
final myLeaveProvider = FutureProvider.autoDispose<Cached<List<LeaveRequest>>>((ref) => ref.read(leaveServiceProvider).mine());

/// `/attendance/leave`: my requests and the button to ask.
class LeaveScreen extends ConsumerWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final res = ref.watch(myLeaveProvider);
    final data = res.value;
    final items = data?.value ?? const <LeaveRequest>[];
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(title: Text(l.leaveTitle), backgroundColor: cs.surfaceContainer),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'leave-new',
        onPressed: () async {
          final sent = await context.push<bool>('/attendance/leave/new');
          if (sent == true) ref.invalidate(myLeaveProvider);
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(l.leaveNew),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(myLeaveProvider.future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, 120),
          children: [
            if (res.isLoading && data == null) const Padding(padding: EdgeInsets.all(Space.s32), child: Center(child: CircularProgressIndicator())),
            if (data?.error != null) ...[
              InfoBanner(
                icon: Icons.cloud_off_rounded,
                tone: BannerTone.warning,
                text: data!.fetchedAt != null ? l.leaveCachedAt(f.dateTime(data.fetchedAt!)) : leaveErrorText(l, data.error!),
              ),
              const SizedBox(height: Space.cardGap),
            ],
            if (data != null && items.isEmpty && data.error == null)
              EmptyState(icon: Icons.beach_access_rounded, title: l.leaveEmpty, body: l.leaveEmptyBody),
            for (final r in items) ...[_LeaveCard(request: r), const SizedBox(height: Space.cardGap)],
          ],
        ),
      ),
    );
  }
}

class _LeaveCard extends ConsumerWidget {
  const _LeaveCard({required this.request});
  final LeaveRequest request;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final f = ref.read(fmtProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.leaveCancelTitle),
        content: Text(l.leaveCancelBody(f.date(request.from), f.date(request.to))),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(l.actionBack)),
          FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(l.leaveCancelConfirm)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final err = await ref.read(leaveServiceProvider).cancel(request.id);
    if (!context.mounted) return;
    ref.invalidate(myLeaveProvider);
    showAppSnack(context, err == null ? l.leaveCancelDone : leaveErrorText(l, err), icon: err == null ? Icons.check_circle_rounded : Icons.error_rounded);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final range = request.from == request.to ? f.date(request.from, withYear: true) : '${f.date(request.from)} – ${f.date(request.to, withYear: true)}';
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('${leaveTypeLabel(l, request.type)} · ${l.leaveDays(f.num(request.days))}', style: t.titleMedium)),
          LeaveStatusChip(status: request.status),
        ]),
        const SizedBox(height: Space.s4),
        Text(range, style: t.bodyLarge),
        if (request.reason.isNotEmpty) ...[
          const SizedBox(height: Space.s4),
          Text(request.reason, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
        ],
        if (request.status == LeaveStatus.rejected && (request.decisionReason?.isNotEmpty ?? false)) ...[
          const SizedBox(height: Space.s8),
          Text(l.leaveManagerSaid(request.decisionReason!), style: t.bodyMedium!.copyWith(color: context.semanticColors.danger.fg)),
        ],
        const SizedBox(height: Space.s4),
        Row(children: [
          Expanded(child: Text(l.leaveAskedAt(f.dateTime(request.createdAt)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant))),
          if (request.cancellable)
            TextButton.icon(
              style: TextButton.styleFrom(minimumSize: const Size(Sizes.minTarget, Sizes.minTarget)),
              onPressed: () => _cancel(context, ref),
              icon: const Icon(Icons.undo_rounded),
              label: Text(l.leaveCancelAction),
            ),
        ]),
      ]),
    );
  }
}

/// `/attendance/leave/new`: type, dates and reason; sent online.
class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});
  @override
  ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  LeaveType _type = LeaveType.casual;
  late String _today;
  late String _from;
  late String _to;
  final _reason = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _today = ref.read(clockProvider).businessDate();
    _from = addDaysYmd(_today, 1);
    _to = _from;
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<String?> _pick(String initial, String first) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: parseBusinessDate(initial),
      firstDate: parseBusinessDate(first),
      lastDate: parseBusinessDate(addDaysYmd(_today, 365)),
    );
    return picked == null ? null : ymdOf(picked);
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    final mine = (await ref.read(leaveServiceProvider).mine()).value;
    final check = checkLeaveForm(from: _from, to: _to, mine: mine);
    if (check != null) {
      setState(() => _error = switch (check) {
            LeaveFormError.toBeforeFrom => l.leaveErrToBeforeFrom,
            LeaveFormError.tooLong => l.leaveErrTooLong,
            LeaveFormError.overlaps => l.leaveErrOverlaps,
          });
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final (r, err) = await ref.read(leaveServiceProvider).request(type: _type, from: _from, to: _to, reason: _reason.text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (r != null) {
      showAppSnack(context, l.leaveSent);
      context.pop(true);
    } else {
      setState(() => _error = leaveErrorText(l, err!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final days = leaveDays(_from, _to);
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(title: Text(l.leaveNew), backgroundColor: cs.surfaceContainer),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
        children: [
          Text(l.leaveType, style: t.titleSmall),
          const SizedBox(height: Space.s8),
          Wrap(spacing: Space.s8, runSpacing: Space.s8, children: [
            for (final type in LeaveType.values)
              ChoiceChip(showCheckmark: false, selected: _type == type, label: Text(leaveTypeLabel(l, type)), onSelected: (_) => setState(() => _type = type)),
          ]),
          const SizedBox(height: Space.s20),
          Row(children: [
            Expanded(
              child: _DateField(
                label: l.leaveFrom,
                value: '${f.date(_from, withYear: true)} · ${weekdayName(l, weekdayOf(_from))}',
                onTap: () async {
                  // Sick leave is often asked for afterwards; the server takes past days.
                  final d = await _pick(_from, addDaysYmd(_today, -30));
                  if (d == null) return;
                  setState(() {
                    _from = d;
                    if (_to.compareTo(d) < 0) _to = d;
                    _error = null;
                  });
                },
              ),
            ),
            const SizedBox(width: Space.s12),
            Expanded(
              child: _DateField(
                label: l.leaveTo,
                value: '${f.date(_to, withYear: true)} · ${weekdayName(l, weekdayOf(_to))}',
                onTap: () async {
                  final d = await _pick(_to, _from);
                  if (d == null) return;
                  setState(() {
                    _to = d;
                    _error = null;
                  });
                },
              ),
            ),
          ]),
          const SizedBox(height: Space.s8),
          Text(days > 0 ? l.leaveTotalDays(f.num(days)) : l.leaveErrToBeforeFrom, style: t.titleMedium!.copyWith(color: days > 0 ? cs.primary : context.semanticColors.danger.fg)),
          const SizedBox(height: Space.s20),
          TextField(
            controller: _reason,
            maxLength: 500,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(labelText: l.leaveReason, hintText: l.leaveReasonHint, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: Space.s8),
          InfoBanner(icon: Icons.wifi_rounded, text: l.leaveOnlineNote),
          if (_error != null) ...[
            const SizedBox(height: Space.s12),
            InfoBanner(icon: Icons.error_rounded, tone: BannerTone.danger, text: _error!),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.screen, Space.s12, Space.screen, Space.s12),
          child: SizedBox(
            height: Sizes.primaryButton,
            child: FilledButton.icon(
              onPressed: _sending || days == 0 ? null : _send,
              icon: _sending ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded),
              label: Text(l.leaveSend),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: Radii.brMd, side: BorderSide(color: cs.outline)),
      child: InkWell(
        borderRadius: Radii.brMd,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Sizes.row2),
          child: Padding(
            padding: const EdgeInsets.all(Space.s12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(children: [
                Icon(Icons.calendar_month_rounded, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: Space.s4),
                Text(label, style: t.labelMedium!.copyWith(color: cs.onSurfaceVariant)),
              ]),
              const SizedBox(height: Space.s4),
              Text(value, style: t.bodyLarge),
            ]),
          ),
        ),
      ),
    );
  }
}

class _CalendarData {
  const _CalendarData(this.shift, this.holidays, this.leave);
  final Cached<MyShift?> shift;
  final Cached<List<Holiday>> holidays;
  final Cached<List<LeaveRequest>> leave;
}

final _calendarProvider = FutureProvider.autoDispose.family<_CalendarData, int>((ref, year) async {
  final svc = ref.read(leaveServiceProvider);
  final branchId = ref.read(sessionProvider).user?.branchIds.firstOrNull;
  final r = await Future.wait([svc.myShift(), svc.holidays(year, branchId: branchId), svc.mine()]);
  return _CalendarData(r[0] as Cached<MyShift?>, r[1] as Cached<List<Holiday>>, r[2] as Cached<List<LeaveRequest>>);
});

/// `/attendance/calendar`: my shift, this year's holidays and my approved leave.
class WorkCalendarScreen extends ConsumerStatefulWidget {
  const WorkCalendarScreen({super.key});
  @override
  ConsumerState<WorkCalendarScreen> createState() => _WorkCalendarScreenState();
}

class _WorkCalendarScreenState extends ConsumerState<WorkCalendarScreen> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = int.parse(ref.read(clockProvider).businessDate().substring(0, 4));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final today = ref.watch(clockProvider).businessDate();
    final thisYear = int.parse(today.substring(0, 4));
    final res = ref.watch(_calendarProvider(_year));
    final data = res.value;
    final shift = data?.shift.value;
    final cachedAt = [data?.shift.fetchedAt, data?.holidays.fetchedAt].whereType<DateTime>().firstOrNull;
    final offline = data != null && (data.shift.error ?? data.holidays.error) != null;
    final approved = [
      for (final r in data?.leave.value ?? const <LeaveRequest>[])
        if (r.status == LeaveStatus.approved && r.to.compareTo(today) >= 0) r,
    ]..sort((a, b) => a.from.compareTo(b.from));

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(title: Text(l.calendarTitle), backgroundColor: cs.surfaceContainer),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(_calendarProvider(_year).future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
          children: [
            if (offline) ...[
              InfoBanner(icon: Icons.cloud_off_rounded, tone: BannerTone.warning, text: cachedAt != null ? l.leaveCachedAt(f.dateTime(cachedAt)) : l.leaveNeedsInternet),
              const SizedBox(height: Space.cardGap),
            ],
            if (res.isLoading && data == null) const Padding(padding: EdgeInsets.all(Space.s32), child: Center(child: CircularProgressIndicator())),
            if (shift != null)
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.schedule_rounded, color: cs.primary),
                    const SizedBox(width: Space.s8),
                    Expanded(child: Text(l.calendarMyShift, style: t.titleMedium)),
                  ]),
                  const SizedBox(height: Space.s8),
                  Text(shift.isDefault || shift.name.isEmpty ? l.calendarDefaultShift : shift.name, style: t.bodyLarge!.copyWith(fontWeight: FontWeight.w600)),
                  Text(l.calendarShiftHours(f.num(shift.start), f.num(shift.end)), style: t.headlineSmall),
                  const SizedBox(height: Space.s4),
                  Text(
                    shift.weeklyOff.isEmpty ? l.calendarNoWeeklyOff : l.calendarWeeklyOff(shift.weeklyOff.map((d) => weekdayName(l, d)).join(', ')),
                    style: t.bodyMedium,
                  ),
                  Text(l.calendarLateGrace(f.minutes(shift.lateGraceMin), f.minutes(shift.maxBreakMin)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                ]),
              ),
            if (approved.isNotEmpty) ...[
              SectionHeader(l.calendarMyLeave, count: f.num(approved.length)),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(children: [
                  for (final r in approved)
                    ListTile(
                      minTileHeight: Sizes.minTarget + 8,
                      leading: Icon(Icons.beach_access_rounded, color: context.semanticColors.success.fg),
                      title: Text(r.from == r.to ? f.date(r.from, withYear: true) : '${f.date(r.from)} – ${f.date(r.to, withYear: true)}'),
                      subtitle: Text('${leaveTypeLabel(l, r.type)} · ${l.leaveDays(f.num(r.days))}'),
                    ),
                ]),
              ),
            ],
            SectionHeader(
              l.calendarHolidays,
              count: data == null ? null : f.num(data.holidays.value.length),
              trailing: SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [for (final y in [thisYear, thisYear + 1]) ButtonSegment(value: y, label: Text(f.num(y)))],
                selected: {_year},
                onSelectionChanged: (s) => setState(() => _year = s.first),
              ),
            ),
            if (data != null && data.holidays.value.isEmpty)
              EmptyState(icon: Icons.event_busy_rounded, title: l.calendarNoHolidays, body: l.calendarNoHolidaysBody)
            else if (data != null)
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(children: [
                  for (final h in data.holidays.value)
                    Opacity(
                      opacity: h.date.compareTo(today) < 0 ? 0.6 : 1,
                      child: ListTile(
                        minTileHeight: Sizes.minTarget + 8,
                        leading: Icon(h.date == today ? Icons.today_rounded : Icons.event_rounded, color: h.date == today ? cs.primary : cs.onSurfaceVariant),
                        title: Text(h.name.of(lang)),
                        subtitle: Text('${f.date(h.date, withYear: true)} · ${weekdayName(l, weekdayOf(h.date))}'),
                        trailing: Text(h.national ? l.calendarNational : l.calendarBranch, style: t.labelMedium!.copyWith(color: cs.onSurfaceVariant)),
                      ),
                    ),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

/// Me: leave and the work calendar.
class LeaveMeEntry extends ConsumerWidget {
  const LeaveMeEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final canLeave = ref.watch(accessProvider).can(Perm.leaveRequest);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        if (canLeave) ...[
          ListTile(
            minTileHeight: 64,
            leading: const Icon(Icons.beach_access_rounded),
            title: Text(l.leaveTitle),
            subtitle: Text(l.leaveMeSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/attendance/leave'),
          ),
          const Divider(height: 1, indent: Space.s16, endIndent: Space.s16),
        ],
        ListTile(
          minTileHeight: 64,
          leading: const Icon(Icons.calendar_month_rounded),
          title: Text(l.calendarTitle),
          subtitle: Text(l.calendarMeSubtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push('/attendance/calendar'),
        ),
      ]),
    );
  }
}
