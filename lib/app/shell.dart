import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/feature/feature_manifest.dart';
import '../core/location/gps_status.dart';
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
    final problems = (ref.watch(failedCountProvider).value ?? 0) + (ref.watch(openConflictCountProvider).value ?? 0);
    final handovers = ref.watch(pendingHandoversProvider).length;
    final meBadge = problems + handovers;
    final branches = ref.watch(branchListProvider);
    // A branch that is no longer on the phone (access changed) falls back to all.
    final picked = ref.watch(selectedBranchIdProvider);
    final selectedBranch = branches.containsKey(picked) ? picked : null;
    final showBranchBar = branches.length > 1;
    // FR-M-044: what waits for me, counted on the bell (shown also with one branch).
    final alertCount = ref.watch(alertsProvider).length;

    final scaffold = Scaffold(
      body: Column(
        children: [
          _BranchBar(
            branches: branches,
            selectedBranch: selectedBranch,
            pickBranch: showBranchBar,
            notificationCount: alertCount,
            countLabel: f.num(alertCount),
            onBranchChanged: (v) => ref.read(selectedBranchIdProvider.notifier).state = v,
            onBellTap: () => context.push('/alerts'),
          ),
          // The bar above already sits below the status bar; without this the
          // screens' own app bars would leave that gap a second time.
          // The Builder reads the MediaQuery *inside* this Scaffold's body, which
          // has the keyboard inset already taken off. Reading the shell's own
          // context put the full inset back, so each tab's Scaffold shrank for
          // the keyboard a second time and left a blank band over the list.
          Expanded(child: Builder(builder: (context) => MediaQuery.removePadding(context: context, removeTop: true, child: shell))),
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

/// Colored branch selector bar shown when the user has access to > 1 branch.
/// Layout: store icon + 2/3-width dropdown | spacer | bell with badge.
class _BranchBar extends StatelessWidget {
  const _BranchBar({
    required this.branches,
    required this.selectedBranch,
    required this.pickBranch,
    required this.notificationCount,
    required this.countLabel,
    required this.onBranchChanged,
    required this.onBellTap,
  });

  final Map<String, String> branches;
  final String? selectedBranch;

  /// More than one branch: the name is a dropdown. One branch: plain text.
  final bool pickBranch;
  final int notificationCount;

  /// The count in the user's digits.
  final String countLabel;
  final ValueChanged<String?> onBranchChanged;
  final VoidCallback onBellTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Material(
      color: cs.primaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s4),
          child: Row(children: [
            Icon(Icons.store_rounded, size: 20, color: cs.onPrimaryContainer),
            const SizedBox(width: Space.s8),
            // 2/3 of remaining width
            Expanded(
              flex: 2,
              child: pickBranch
                  ? DropdownButton<String?>(
                      value: selectedBranch,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      dropdownColor: cs.primaryContainer,
                      // labelMedium: branch names were too big at titleSmall (owner, 2026-11-22).
                      // Rows keep the 48 dp default item height; long names end in "…".
                      style: t.labelMedium!.copyWith(color: cs.onPrimaryContainer),
                      itemHeight: Sizes.minTarget,
                      iconEnabledColor: cs.onPrimaryContainer,
                      items: [
                        DropdownMenuItem<String?>(value: null, child: _BranchName(l.filterAllBranches)),
                        for (final e in branches.entries) DropdownMenuItem<String?>(value: e.key, child: _BranchName(e.value)),
                      ],
                      onChanged: onBranchChanged,
                    )
                  : Text(
                      branches.values.firstOrNull ?? '',
                      style: t.labelMedium!.copyWith(color: cs.onPrimaryContainer),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            const Spacer(),
            const GpsStatusIcon(),
            IconButton(
              icon: Badge(
                isLabelVisible: notificationCount > 0,
                label: Text(countLabel),
                child: const Icon(Icons.notifications_rounded),
              ),
              color: cs.onPrimaryContainer,
              onPressed: onBellTap,
              tooltip: l.alertsTitle,
            ),
          ]),
        ),
      ),
    );
  }
}

/// One branch name in the picker: one line, "…" when it does not fit.
class _BranchName extends StatelessWidget {
  const _BranchName(this.name);
  final String name;

  @override
  Widget build(BuildContext context) => Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false);
}
