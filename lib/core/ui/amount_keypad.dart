import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../format/digits.dart';
import '../settings/ui_prefs.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// 3×4 amount keypad, 72 dp keys, haptic on press, long-press backspace
/// clears (design guide §6). Emits the raw ASCII digit string (taka only).
class AmountKeypad extends ConsumerWidget {
  const AmountKeypad({super.key, required this.value, required this.onChanged, this.maxDigits = 8});
  final String value;
  final ValueChanged<String> onChanged;
  final int maxDigits;

  void _press(String k) {
    HapticFeedback.lightImpact();
    if (k == '⌫') {
      if (value.isNotEmpty) onChanged(value.substring(0, value.length - 1));
      return;
    }
    if (value.length >= maxDigits) return;
    if (value.isEmpty && (k == '0' || k == '00')) return;
    onChanged(value + k);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final digits = ref.watch(uiPrefsProvider).digits;
    final cs = Theme.of(context).colorScheme;
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '00', '0', '⌫'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: Space.s8,
      crossAxisSpacing: Space.s8,
      childAspectRatio: 1.9,
      children: [
        for (final k in keys)
          Semantics(
            button: true,
            label: k == '⌫' ? l.keypadBackspace : k,
            excludeSemantics: true,
            child: Material(
              color: k == '⌫' ? cs.surfaceContainerHigh : cs.surface,
              shape: RoundedRectangleBorder(borderRadius: Radii.brLg, side: BorderSide(color: cs.outlineVariant)),
              child: InkWell(
                borderRadius: Radii.brLg,
                onTap: () => _press(k),
                onLongPress: k == '⌫'
                    ? () {
                        HapticFeedback.mediumImpact();
                        onChanged('');
                      }
                    : null,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: Sizes.keypadKey - 16),
                  child: Center(
                    child: k == '⌫'
                        ? Icon(Icons.backspace_rounded, color: cs.onSurfaceVariant)
                        : Text(
                            localizeDigits(k, digits),
                            style: AppTheme.tabular(Theme.of(context).textTheme.headlineSmall!),
                          ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Digit-only PIN pad (4 digits) with dots.
class PinPad extends ConsumerWidget {
  const PinPad({super.key, required this.length, required this.onDigit, required this.onBackspace, this.error = false, this.pinLength = 4});
  final int length;
  final int pinLength;
  final bool error;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final digits = ref.watch(uiPrefsProvider).digits;
    Widget key(String k) => Semantics(
          button: true,
          label: k == '⌫' ? l.keypadBackspace : k,
          excludeSemantics: true,
          child: SizedBox(
            width: 80,
            height: 72,
            child: k.isEmpty
                ? null
                : Material(
                    color: k == '⌫' ? Colors.transparent : cs.surfaceContainer,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        k == '⌫' ? onBackspace() : onDigit(k);
                      },
                      child: Center(
                        child: k == '⌫'
                            ? Icon(Icons.backspace_rounded, color: cs.onSurfaceVariant)
                            : Text(localizeDigits(k, digits), style: Theme.of(context).textTheme.headlineMedium),
                      ),
                    ),
                  ),
          ),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < pinLength; i++)
              AnimatedContainer(
                duration: Motion.fast,
                margin: const EdgeInsets.symmetric(horizontal: Space.s8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < length ? (error ? cs.error : cs.primary) : Colors.transparent,
                  border: Border.all(color: error ? cs.error : cs.outline, width: 2),
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.s32),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '⌫'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s12),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (final k in row) Padding(padding: const EdgeInsets.symmetric(horizontal: Space.s12), child: key(k))]),
          ),
      ],
    );
  }
}
