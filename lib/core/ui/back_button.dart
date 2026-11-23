import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';

/// A large back button for screen headers (owner request 2026-11-23, design guide §6): a 48 dp target with a
/// 28 dp arrow on a light tonal circle (`secondaryContainer`), and the standard ink ripple on press.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed});

  /// Defaults to popping the current route.
  final VoidCallback? onPressed;

  static const iconSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: Space.s12),
      child: Center(
        child: IconButton.filledTonal(
          key: const Key('app-back-button'),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          iconSize: iconSize,
          style: IconButton.styleFrom(
            minimumSize: const Size.square(Sizes.minTarget),
            fixedSize: const Size.square(Sizes.minTarget),
            backgroundColor: cs.secondaryContainer,
            foregroundColor: cs.onSecondaryContainer,
            // A ripple that shows on the tonal circle, not only the faint default overlay.
            overlayColor: cs.onSecondaryContainer,
            splashFactory: InkRipple.splashFactory,
          ),
          onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
          icon: const BackButtonIcon(),
        ),
      ),
    );
  }
}
