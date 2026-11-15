import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/feature/feature_manifest.dart';
import '../core/providers.dart';
import '../features/auth/auth.dart';
import '../features/customers/customers.dart';
import '../features/map/map.dart';
import '../features/onboarding/onboarding.dart';
import '../features/settings/settings.dart';
import '../features/today/today.dart';
import 'shell.dart';

/// Gate screens chosen by the session stage (never navigated to by hand).
const _gate = {
  SessionStage.loading: '/splash',
  SessionStage.signedOut: '/login',
  SessionStage.mustChangePassword: '/change-password',
  SessionStage.needsPin: '/pin/setup',
  SessionStage.needsConsent: '/consent',
  SessionStage.needsPrimer: '/primer',
  SessionStage.needsBootstrap: '/bootstrap',
  SessionStage.locked: '/pin',
};

/// Pure redirect rule (unit-tested): where should [location] go?
String? redirectFor({required SessionStage stage, required bool upgradeRequired, required String location}) {
  if (upgradeRequired && stage != SessionStage.loading) return location == '/update' ? null : '/update';
  final gate = _gate[stage];
  if (gate != null) return location == gate ? null : gate;
  // Ready: leave gate screens for Today.
  if (_gate.values.contains(location) || location == '/update' || location == '/') return '/today';
  return null;
}

class _RouterRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(sessionProvider.select((s) => s.stage), (_, _) => refresh.ping());
  ref.listen(upgradeRequiredProvider, (_, _) => refresh.ping());
  final manifests = ref.read(featureManifestsProvider);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) => redirectFor(
      stage: ref.read(sessionProvider).stage,
      upgradeRequired: ref.read(upgradeRequiredProvider),
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/change-password', builder: (_, _) => const ChangePasswordScreen()),
      GoRoute(path: '/pin/setup', builder: (_, _) => const PinScreen(setup: true)),
      GoRoute(path: '/pin', builder: (_, _) => const PinScreen(setup: false)),
      GoRoute(path: '/consent', builder: (_, _) => const ConsentScreen()),
      GoRoute(path: '/primer', builder: (_, _) => const PermissionsPrimerScreen()),
      GoRoute(path: '/bootstrap', builder: (_, _) => const BootstrapScreen()),
      GoRoute(path: '/update', builder: (_, _) => const UpdateRequiredScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/today',
              builder: (context, _) => Consumer(
                builder: (context, ref, _) => TodayScreen(onSeeOverdue: () {
                  ref.read(customerFilterProvider.notifier).state = CustomerFilter.overdue;
                  context.go('/customers');
                }),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: '/customers', builder: (_, _) => const CustomerListScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/map', builder: (_, _) => const CustomerMapScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/me', builder: (_, _) => const MeScreen())]),
        ],
      ),
      // Feature routes open full-screen above the tab shell.
      for (final m in manifests) ...m.routes,
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
