import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/media/media.dart';
import '../core/providers.dart';
import '../core/settings/ui_prefs.dart';
import '../core/sync/sync_engine.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/auth.dart';
import '../features/collections/collections.dart';
import '../features/location/location.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'shell.dart';

/// How often to sync while the app is open and signed in.
const foregroundSyncEvery = Duration(minutes: 5);

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
    _timer = Timer.periodic(foregroundSyncEvery, (_) => _kick('timer'));
    if (widget.watchConnectivity) {
      _net = Connectivity().onConnectivityChanged.listen((r) {
        if (r.any((x) => x != ConnectivityResult.none)) _kick('online');
      });
    }
    // After each successful sync: upload photos (independent of data
    // sync) and purge old confirmed media / done outbox rows.
    _status = ref.read(syncEngineProvider).status.listen((s) {
      if (s.running || s.lastErrorCode != null || s.lastSuccessAt == null) return;
      unawaited(ref.read(mediaServiceProvider).uploadPending().catchError((Object _) {}));
    });
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
      _kick('resume');
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
      builder: (context, child) => DemoRibbon(
        child: MediaQuery(
          // Respect the user's font size but cap it so layouts stay usable.
          data: MediaQuery.of(context).copyWith(textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3)),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
