import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';

/// 56 dp button that fills over [duration] while held; fires once on
/// completion, cancels on release (ADR-M07). TalkBack: double-tap activates
/// (semantic onTap) so the flow stays accessible.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({super.key, required this.label, required this.holdingLabel, required this.onConfirmed, this.duration = const Duration(milliseconds: 800), this.enabled = true, this.icon = Icons.lock_rounded});
  final String label;
  final String holdingLabel;
  final VoidCallback onConfirmed;
  final Duration duration;
  final bool enabled;
  final IconData icon;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed && !_fired) {
        _fired = true;
        HapticFeedback.heavyImpact();
        widget.onConfirmed();
      }
    });
  bool _fired = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _down() {
    if (!widget.enabled || _fired) return;
    HapticFeedback.selectionClick();
    _c.forward();
  }

  void _up() {
    if (_fired) return;
    _c.animateBack(0, duration: Motion.base, curve: Motion.standard);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme.labelLarge!;
    final bg = widget.enabled ? cs.primary : cs.surfaceContainerHighest;
    final fg = widget.enabled ? cs.onPrimary : cs.onSurfaceVariant;
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      onTap: widget.enabled && !_fired
          ? () {
              _fired = true;
              widget.onConfirmed();
            }
          : null,
      excludeSemantics: true,
      child: Listener(
        onPointerDown: (_) => _down(),
        onPointerUp: (_) => _up(),
        onPointerCancel: (_) => _up(),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => ClipRRect(
            borderRadius: Radii.brLg,
            child: SizedBox(
              height: Sizes.primaryButton,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: bg),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _c.value,
                    child: ColoredBox(color: Color.lerp(bg, Colors.black, 0.22)!),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_c.value > 0 ? Icons.touch_app_rounded : widget.icon, color: fg, size: 22),
                        const SizedBox(width: Space.s8),
                        Text(_c.value > 0 ? widget.holdingLabel : widget.label, style: t.copyWith(color: fg)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
