import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/media/media.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/chips.dart';
import '../../../core/ui/common.dart';
import '../../../core/ui/money_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../collections/collections.dart';
import 'attendance_data.dart';
import 'attendance_domain.dart';

DutyState dutyStateOf(AttendanceDay d) => switch (d.status) {
  DayStatus.onDuty => DutyState.on,
  DayStatus.onBreak => DutyState.onBreak,
  _ => DutyState.off,
};

/// Records an attendance event; opens the front camera first when the
/// event needs a photo (`attendance.selfieEvents`). Camera only, never the
/// gallery. Returns false when nothing was recorded.
Future<bool> recordAttendance(BuildContext context, WidgetRef ref, AttendanceEventType type) async {
  unawaited(HapticFeedback.mediumImpact());
  final service = ref.read(attendanceServiceProvider);
  final l = AppLocalizations.of(context);

  // Check GPS is on before anything else.
  if (!await Geolocator.isLocationServiceEnabled()) {
    if (context.mounted) showAppSnack(context, l.attendanceNeedsLocation, icon: Icons.location_off_rounded);
    return false;
  }

  if (!context.mounted) return false;
  final fixFuture = ref.read(locationEngineProvider).currentFix(timeout: const Duration(seconds: 10));
  Uint8List? selfie;
  if (service.needsSelfie(type)) {
    selfie = await ref.read(photoCapturerProvider).capture(context, front: true);
    if (selfie == null) {
      if (context.mounted) showAppSnack(context, l.attendanceSelfieNeeded, icon: Icons.photo_camera_front_rounded);
      return false;
    }
  }
  final fix = await fixFuture;
  if (fix == null) {
    if (context.mounted) showAppSnack(context, l.attendanceNeedsLocation, icon: Icons.location_off_rounded);
    return false;
  }
  // Block fake/mock GPS.
  if (fix.mock) {
    if (context.mounted) showAppSnack(context, l.gpsMockWarning, icon: Icons.gps_off_rounded);
    return false;
  }
  try {
    await service.record(type, fix: fix, selfie: selfie);
    return true;
  } on InvalidAttendanceTransition {
    if (context.mounted) showAppSnack(context, l.errorGeneric, icon: Icons.error_rounded);
    return false;
  }
}

/// Duty card on Today (tap → break / work-out).
class DutyCard extends ConsumerStatefulWidget {
  const DutyCard({super.key});

  @override
  ConsumerState<DutyCard> createState() => _DutyCardState();
}

class _DutyCardState extends ConsumerState<DutyCard> with WidgetsBindingObserver {
  bool _gpsOn = true;

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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    ref.watch(minuteTickerProvider);
    final day = ref.watch(todayAttendanceProvider).value;
    if (day == null) return const SizedBox.shrink();
    final now = ref.read(clockProvider).nowUtc();
    final maxBreak = (ref.watch(serverSettingsProvider)['maxBreakMin'] as num?)?.toInt() ?? 60;

    if (day.status == DayStatus.notStarted || day.status == DayStatus.offDuty) {
      return AppCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: cs.surfaceContainerHigh, shape: BoxShape.circle),
              child: Icon(Icons.wb_twilight_rounded, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: Space.s12),
            Expanded(
              child: Text(
                day.status == DayStatus.offDuty && day.lastOut != null ? l.dutyEnded(f.time(day.lastOut!)) : l.dutyNotStarted,
                style: t.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, Sizes.minTarget)),
              onPressed: () => context.push('/attendance/work-in'),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l.dutyStartWork),
            ),
          ],
        ),
      );
    }

    final onBreak = day.status == DayStatus.onBreak;
    final br = day.openBreak;
    final overBreak = onBreak && br != null && day.breakTotal(now).inMinutes > maxBreak;
    final tone = onBreak ? sem.warning : sem.success;
    return Column(
      children: [
        if (!_gpsOn) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s8),
            decoration: BoxDecoration(color: sem.danger.bg, borderRadius: Radii.brLg),
            child: Row(
              children: [
                Icon(Icons.location_off_rounded, size: 18, color: sem.danger.fg),
                const SizedBox(width: Space.s8),
                Expanded(child: Text(l.gpsStatusOff, style: t.bodySmall!.copyWith(color: sem.danger.fg, fontWeight: FontWeight.w600))),
                TextButton(
                  onPressed: () => Geolocator.openLocationSettings(),
                  child: Text(l.gpsTurnOn, style: TextStyle(color: sem.danger.fg)),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.s8),
        ],
        Container(
          decoration: BoxDecoration(color: tone.bg, borderRadius: Radii.brXl),
          padding: const EdgeInsets.fromLTRB(Space.s16, Space.s12, Space.s12, Space.s12),
          child: Row(
            children: [
              _PulseDot(color: tone.fg, animate: !onBreak),
              const SizedBox(width: Space.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      onBreak ? l.dutyBreakSince(f.duration(br!.length(now))) : l.dutyOnSince(f.time(day.firstIn!)),
                      style: t.titleSmall!.copyWith(color: tone.fg),
                    ),
                    Text(
                      overBreak ? l.meBreakTotal(f.duration(day.breakTotal(now))) : (onBreak ? l.dutyOnBreak : l.dutyTracking),
                      style: t.bodySmall!.copyWith(color: tone.fg),
                    ),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: tone.fg),
                onPressed: _gpsOn ? () => recordAttendance(context, ref, onBreak ? AttendanceEventType.breakEnd : AttendanceEventType.breakStart) : null,
                child: Text(onBreak ? l.dutyEndBreak : l.dutyStartBreak),
              ),
              if (!onBreak)
                IconButton(tooltip: l.dutyEndWork, color: tone.fg, onPressed: _gpsOn ? () => context.push('/attendance/work-out') : null, icon: const Icon(Icons.logout_rounded)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color, required this.animate});
  final Color color;
  final bool animate;
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.of(context).disableAnimations;
    if (widget.animate && !reduce && !_c.isAnimating) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 20,
    height: 20,
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 8 + 12 * _c.value,
            height: 8 + 12 * _c.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.35 * (1 - _c.value)),
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
          ),
        ],
      ),
    ),
  );
}

/// Attendance summary card on Me.
class AttendanceCard extends ConsumerWidget {
  const AttendanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    ref.watch(minuteTickerProvider);
    final day = ref.watch(todayAttendanceProvider).value;
    if (day == null) return const SizedBox.shrink();
    final now = ref.read(clockProvider).nowUtc();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_available_rounded, color: cs.primary),
              const SizedBox(width: Space.s8),
              Expanded(child: Text(l.meAttendance, style: t.titleMedium)),
              DutyChip(state: dutyStateOf(day)),
            ],
          ),
          const SizedBox(height: Space.s12),
          Wrap(
            spacing: Space.s16,
            runSpacing: Space.s8,
            children: [
              if (day.firstIn != null) _Fact(icon: Icons.login_rounded, text: l.meInToday(f.time(day.firstIn!))),
              _Fact(icon: Icons.coffee_rounded, text: l.meBreakTotal(f.duration(day.breakTotal(now)))),
              if (day.lateMin > 0) _Fact(icon: Icons.schedule_rounded, text: l.meLate(f.minutes(day.lateMin)), color: context.semanticColors.warning.fg),
            ],
          ),
          const SizedBox(height: Space.s12),
          _Timeline(day: day),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text, this.color});
  final IconData icon;
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: c),
        const SizedBox(width: Space.s4),
        Text(text, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: c)),
      ],
    );
  }
}

/// Horizontal day bar: duty (primary) with break gaps (warning).
class _Timeline extends ConsumerWidget {
  const _Timeline({required this.day});
  final AttendanceDay day;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    if (day.firstIn == null) return const SizedBox.shrink();
    final now = ref.read(clockProvider).nowUtc();
    final start = day.firstIn!;
    final end = day.lastOut ?? now;
    final total = end.difference(start).inSeconds.clamp(1, 1 << 30);
    return SizedBox(
      height: 10,
      child: LayoutBuilder(
        builder: (context, c) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(color: cs.primary, borderRadius: Radii.brXs),
              ),
              for (final b in day.breaks)
                Positioned(
                  left: c.maxWidth * b.start.difference(start).inSeconds / total,
                  width: (c.maxWidth * b.length(end).inSeconds / total).clamp(2, c.maxWidth),
                  top: 0,
                  bottom: 0,
                  child: Container(color: sem.warning.fg),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Live GPS status banner with green/red indicator and turn-on button.
class _GpsStatusBanner extends StatefulWidget {
  const _GpsStatusBanner({required this.onStatusChanged});
  final ValueChanged<bool> onStatusChanged;
  @override
  State<_GpsStatusBanner> createState() => _GpsStatusBannerState();
}

class _GpsStatusBannerState extends State<_GpsStatusBanner> with WidgetsBindingObserver {
  bool _gpsOn = true;
  bool _mockDetected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final on = await Geolocator.isLocationServiceEnabled();
    bool mock = false;
    if (on) {
      try {
        final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(timeLimit: Duration(seconds: 5)));
        mock = pos.isMocked;
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _gpsOn = on;
      _mockDetected = mock;
    });
    widget.onStatusChanged(on && !mock);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sem = context.semanticColors;

    if (_mockDetected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s12),
        decoration: BoxDecoration(color: sem.danger.bg, borderRadius: Radii.brLg),
        child: Row(
          children: [
            Icon(Icons.gps_off_rounded, color: sem.danger.fg),
            const SizedBox(width: Space.s12),
            Expanded(child: Text(l.gpsMockWarning, style: TextStyle(color: sem.danger.fg))),
          ],
        ),
      );
    }

    if (!_gpsOn) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s12),
        decoration: BoxDecoration(color: sem.danger.bg, borderRadius: Radii.brLg),
        child: Row(
          children: [
            Icon(Icons.location_off_rounded, color: sem.danger.fg),
            const SizedBox(width: Space.s12),
            Expanded(child: Text(l.gpsStatusOff, style: TextStyle(color: sem.danger.fg, fontWeight: FontWeight.w600))),
            const SizedBox(width: Space.s8),
            FilledButton.tonal(
              onPressed: () async {
                await Geolocator.openLocationSettings();
              },
              child: Text(l.gpsTurnOn),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s12),
      decoration: BoxDecoration(color: sem.success.bg, borderRadius: Radii.brLg),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded, color: sem.success.fg),
          const SizedBox(width: Space.s12),
          Text(l.gpsStatusOn, style: TextStyle(color: sem.success.fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Work-in: date, GPS status, big button (design guide §5.8).
class WorkInScreen extends ConsumerStatefulWidget {
  const WorkInScreen({super.key});
  @override
  ConsumerState<WorkInScreen> createState() => _WorkInScreenState();
}

class _WorkInScreenState extends ConsumerState<WorkInScreen> {
  bool _busy = false;
  bool _gpsReady = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(serverSettingsProvider);
    final today = ref.read(clockProvider).businessDate();
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.wb_sunny_rounded, size: 64, color: context.semanticColors.warning.fg),
              const SizedBox(height: Space.s16),
              Text(l.workInTitle, style: t.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: Space.s4),
              Text(
                '${f.date(today, withYear: true)} · ${f.num((settings['dutyStart'] as String?) ?? '09:00')}–${f.num((settings['dutyEnd'] as String?) ?? '18:00')}',
                style: t.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Space.s24),
              _GpsStatusBanner(onStatusChanged: (ok) => setState(() => _gpsReady = ok)),
              const SizedBox(height: Space.s12),
              if (ref.read(attendanceServiceProvider).needsSelfie(AttendanceEventType.workIn)) ...[
                InfoBanner(icon: Icons.photo_camera_front_rounded, text: l.attendanceSelfieHint),
                const SizedBox(height: Space.s12),
              ],
              const Spacer(),
              SizedBox(
                height: 64,
                child: FilledButton.icon(
                  onPressed: (_busy || !_gpsReady)
                      ? null
                      : () async {
                          setState(() => _busy = true);
                          final ok = await recordAttendance(context, ref, AttendanceEventType.workIn);
                          if (!context.mounted) return;
                          if (ok) {
                            context.pop();
                          } else {
                            setState(() => _busy = false);
                          }
                        },
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: Text(l.dutyStartWork, style: t.titleMedium!.copyWith(color: cs.onPrimary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Work-out with end-of-day summary and unsynced warning (M-E10).
class WorkOutScreen extends ConsumerStatefulWidget {
  const WorkOutScreen({super.key});
  @override
  ConsumerState<WorkOutScreen> createState() => _WorkOutScreenState();
}

class _WorkOutScreenState extends ConsumerState<WorkOutScreen> {
  bool _busy = false;
  bool _gpsReady = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final totals = ref.watch(todayTotalsProvider).value ?? const DayTotals();
    final cash = ref.watch(cashOnHandProvider).value;
    final pending = ref.watch(pendingCountProvider).value ?? 0;
    final failed = ref.watch(failedCountProvider).value ?? 0;
    return Scaffold(
      appBar: AppBar(title: Text(l.workOutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(Space.screen),
        children: [
          _GpsStatusBanner(onStatusChanged: (ok) => setState(() => _gpsReady = ok)),
          const SizedBox(height: Space.cardGap),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.workOutCollections, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                MoneyText(totals.total, style: t.headlineMedium),
                Text(f.num(totals.count), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: Space.s12),
                const Divider(height: 1),
                KeyValueRow(
                  label: l.workOutCash,
                  value: MoneyText(totals.cash, style: t.bodyLarge),
                ),
                KeyValueRow(
                  label: l.workOutMobile,
                  value: MoneyText(totals.mobile, style: t.bodyLarge),
                ),
                if (cash != null)
                  KeyValueRow(
                    label: l.todayCashOnHand,
                    value: MoneyText(cash.onHand, style: t.bodyLarge),
                  ),
              ],
            ),
          ),
          if (pending + failed > 0) ...[
            const SizedBox(height: Space.cardGap),
            InfoBanner(
              icon: Icons.cloud_upload_rounded,
              text: l.workOutUnsynced(f.num(pending + failed)),
              tone: BannerTone.warning,
              onTap: () => context.push('/sync'),
            ),
          ],
          const SizedBox(height: Space.s24),
          SizedBox(
            height: 64,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: cs.inverseSurface, foregroundColor: cs.onInverseSurface),
              onPressed: (_busy || !_gpsReady)
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      final ok = await recordAttendance(context, ref, AttendanceEventType.workOut);
                      if (!context.mounted) return;
                      if (ok) {
                        context.pop();
                      } else {
                        setState(() => _busy = false);
                      }
                    },
              icon: const Icon(Icons.stop_circle_rounded, size: 28),
              label: Text(l.dutyEndWork),
            ),
          ),
        ],
      ),
    );
  }
}
