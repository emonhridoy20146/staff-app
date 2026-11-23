import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/location/location_gate.dart';
import '../core/media/media.dart';
import '../core/providers.dart';
import '../core/settings/ui_prefs.dart';
import '../core/sync/sync_engine.dart';
import '../core/theme/app_theme.dart';
import '../features/attendance/attendance.dart';
import '../features/auth/auth.dart';
import '../features/collections/collections.dart';
import '../features/location/location.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'shell.dart';

/// How often to sync on its own while the app is open and signed in. Owner 2026-11-23: customer pages must not
/// reload every few minutes; once every 15 minutes is fine, and only when online. Saved work still goes out at
/// once (each use case kicks a sync), and network-back / app-resume / pull-down still sync immediately.
const foregroundSyncEvery = Duration(minutes: 15);

class FieldApp extends ConsumerStatefulWidget {
  const FieldApp({super.key, this.watchConnectivity = true});

  /// Off in widget tests (no platform channel).
  final bool watchConnectivity;

  @override
  ConsumerState<FieldApp> createState() => _FieldAppState();
}

class _FieldAppState extends ConsumerState<FieldApp> with WidgetsBindingObserver {
  DateTime? _pausedAt;
  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _net;
  StreamSubscription<SyncStatus>? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(foregroundSyncEvery, (_) => unawaited(_timerKick()));
    if (widget.watchConnectivity) {
      _net = Connectivity().onConnectivityChanged.listen(_onNetwork);
      unawaited(Connectivity().checkConnectivity().then(_onNetwork).catchError((Object _) {}));
    }
    // After each successful sync: upload photos (independent of data
    // sync) and purge old confirmed media / done outbox rows.
    _status = ref.read(syncEngineProvider).status.listen((s) {
      if (s.running || s.lastErrorCode != null || s.lastSuccessAt == null) return;
      unawaited(ref.read(mediaServiceProvider).uploadPending().catchError((Object _) {}));
      // FR-M-061: after a reinstall, today's work-in comes back from the server instead of being asked again.
      unawaited(ref.read(attendanceServiceProvider).restoreTodayIfMissing().catchError((Object _) => 0));
    });
  }

  /// Network back → sync now (the dot turns green once the server answers); no network → grey dot at once.
  void _onNetwork(List<ConnectivityResult> r) {
    if (r.any((x) => x != ConnectivityResult.none)) {
      _kick('online');
    } else {
      ref.read(syncEngineProvider).markOffline();
    }
  }

  /// The 15-minute sync runs only when the phone has a network; offline it would only fail.
  Future<void> _timerKick() async {
    if (widget.watchConnectivity) {
      try {
        final r = await Connectivity().checkConnectivity();
        if (!r.any((x) => x != ConnectivityResult.none)) return;
      } catch (_) {}
    }
    if (mounted) _kick('timer');
  }

  void _kick(String reason) {
    if (ref.read(sessionProvider).stage != SessionStage.ready) return;
    unawaited(ref.read(syncEngineProvider).kick(reason: reason));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final clock = ref.read(clockProvider);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _pausedAt ??= clock.nowUtc();
    } else if (state == AppLifecycleState.resumed) {
      final away = _pausedAt == null ? Duration.zero : clock.nowUtc().difference(_pausedAt!);
      _pausedAt = null;
      if (away >= appLockAfter) ref.read(sessionProvider.notifier).lock();
      // Coming back from the camera or a call must not reload the page: sync on resume only when the last good
      // sync is older than [foregroundSyncEvery] or the last one failed (owner 2026-11-23).
      final s = ref.read(syncEngineProvider).current;
      final last = s.lastSuccessAt;
      if (last == null || s.lastErrorCode != null || clock.nowUtc().difference(last) >= foregroundSyncEvery) _kick('resume');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    unawaited(_net?.cancel());
    unawaited(_status?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(uiPrefsProvider);
    final router = ref.watch(routerProvider);
    ref.watch(collectionsBackgroundProvider);
    ref.watch(locationBackgroundProvider);
    return MaterialApp.router(
      onGenerateTitle: (c) => AppLocalizations.of(c).appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: Locale(prefs.language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      theme: AppTheme.light(highContrast: prefs.highContrast),
      darkTheme: AppTheme.dark(highContrast: prefs.highContrast),
      themeMode: prefs.themeMode,
      builder: (context, child) {
        Widget inner = child ?? const SizedBox.shrink();
        // Location gate: block the app when location permission or GPS is off
        // (only once the user is fully signed in and past onboarding).
        final stage = ref.watch(sessionProvider.select((s) => s.stage));
        if (stage == SessionStage.ready) {
          inner = LocationGateScreen(child: inner);
        }
        return DemoRibbon(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3)),
            child: inner,
          ),
        );
      },
    );
  }
}
