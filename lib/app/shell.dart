import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/providers.dart';
import '../core/settings/ui_prefs.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/tokens.dart';
import '../core/ui/brand.dart';
import '../core/ui/chips.dart';
import '../core/ui/exit_confirm.dart';
import '../features/customers/customers.dart';
import '../features/handovers/handovers.dart';
import '../l10n/app_localizations.dart';

/// Bottom navigation: Today · Customers · Map · Me (FR-M-003).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final cs = Theme.of(context).colorScheme;
    final problems = (ref.watch(failedCountProvider).value ?? 0) + (ref.watch(openConflictCountProvider).value ?? 0);
    final handovers = ref.watch(pendingHandoversProvider).length;
    final meBadge = problems + handovers;
    final branches = ref.watch(branchListProvider);
    final selectedBranch = ref.watch(selectedBranchIdProvider);
    final showBranchBar = branches.length > 1;

    final scaffold = Scaffold(
      body: Column(
        children: [
          if (showBranchBar)
            Material(
              elevation: 1,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s8),
                  child: Row(
                    children: [
                      Icon(Icons.store_rounded, size: 20, color: cs.primary),
                      const SizedBox(width: Space.s8),
                      Expanded(
                        child: DropdownButton<String?>(
                          value: selectedBranch,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(color: cs.onSurface),
                          items: [
                            DropdownMenuItem<String?>(value: null, child: Text(l.filterAll)),
                            for (final e in branches.entries)
                              DropdownMenuItem<String?>(value: e.key, child: Text(e.value)),
                          ],
                          onChanged: (v) => ref.read(selectedBranchIdProvider.notifier).state = v,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(child: shell),
        ],
      ),
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        const OnlineStrip(),
        NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.today_outlined), selectedIcon: const Icon(Icons.today_rounded), label: l.navToday),
            NavigationDestination(icon: const Icon(Icons.people_alt_outlined), selectedIcon: const Icon(Icons.people_alt_rounded), label: l.navCustomers),
            NavigationDestination(icon: const Icon(Icons.map_outlined), selectedIcon: const Icon(Icons.map_rounded), label: l.navMap),
            NavigationDestination(
              icon: Badge(isLabelVisible: meBadge > 0, label: Text(f.num(meBadge)), child: const Icon(Icons.person_outline_rounded)),
              selectedIcon: Badge(isLabelVisible: meBadge > 0, label: Text(f.num(meBadge)), child: const Icon(Icons.person_rounded)),
              label: l.navMe,
            ),
          ],
        ),
      ]),
    );
    // Back from the root of the signed-in app asks before closing it.
    return ExitConfirmScope(child: scaffold);
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primary,
      body: const Center(child: BrandMark(size: 88, inverted: true)),
    );
  }
}

/// Thin ribbon on every screen in demo mode so nobody mistakes sample data
/// for real money.
class DemoRibbon extends ConsumerWidget {
  const DemoRibbon({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(envProvider).isDemo) return child;
    final l = AppLocalizations.of(context);
    return Banner(
      message: l.demoBanner.split(' ').first,
      location: BannerLocation.topEnd,
      color: const Color(0xFFB45309),
      textStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontFamilyFallback: AppTheme.fontFallback, fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
      child: child,
    );
  }
}
