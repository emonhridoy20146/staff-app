import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../providers.dart';

/// Pull down to refresh (audit: docs/pull-to-refresh-audit.md).
///
/// Wraps a scroll view in a [RefreshIndicator]. Without [onRefresh] it runs the
/// same sync as "Sync now" (push the outbox, then pull), which is what every
/// screen that reads from the phone's database needs: the screen's streams
/// update by themselves once the pull is stored. Screens that fetch online
/// pass their own fetch as [onRefresh].
///
/// The scroll view inside must use `physics: const AlwaysScrollableScrollPhysics()`
/// so a short or empty screen can still be pulled; for a body that is not a
/// list (an empty state, a message) use [PullableFill].
class PullToRefresh extends ConsumerWidget {
  const PullToRefresh({super.key, required this.child, this.onRefresh});

  final Widget child;

  /// Defaults to [syncNowFromPull].
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) => RefreshIndicator(
        onRefresh: onRefresh ?? () => syncNowFromPull(ref),
        child: child,
      );
}

/// The refresh a pull runs on a local-database screen: "Sync now".
Future<void> syncNowFromPull(WidgetRef ref) => ref.read(syncEngineProvider).syncNow();

/// A body that is not a list (empty state, message) but can still be pulled
/// down: fills the viewport and places [child] like a `Center` would.
class PullableFill extends StatelessWidget {
  const PullableFill({super.key, required this.child, this.alignment = Alignment.center});

  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: Align(alignment: alignment, child: child),
            ),
          ],
        ),
      );
}
