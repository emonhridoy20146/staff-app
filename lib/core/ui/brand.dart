import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';

/// Brand mark: brand.600 rounded square with a white Bangla "হ".
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56, this.inverted = false});
  final double size;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final bg = inverted ? Neutral.c0 : Brand.c600;
    final fg = inverted ? Brand.c600 : Neutral.c0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: inverted ? null : [BoxShadow(color: Brand.c600.withValues(alpha: 0.28), blurRadius: size * 0.35, offset: Offset(0, size * 0.12))],
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'হ',
            style: TextStyle(fontFamily: 'NotoSansBengali', fontWeight: FontWeight.w700, fontSize: size * 0.56, height: 1.1, color: fg),
          ),
          Positioned(
            right: size * 0.16,
            top: size * 0.16,
            child: Container(
              width: size * 0.14,
              height: size * 0.14,
              decoration: BoxDecoration(color: inverted ? Brand.c400 : const Color(0xFF7DD3FC), shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient hero used on auth / onboarding screens.
class BrandHero extends StatelessWidget {
  const BrandHero({super.key, required this.title, this.subtitle, this.height = 260, this.child});
  final String title;
  final String? subtitle;
  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Brand.c700, Brand.c600, Brand.c500]),
      ),
      child: Stack(
        children: [
          Positioned(right: -60, top: -40, child: _Circle(220, Neutral.c0.withValues(alpha: 0.07))),
          Positioned(right: 40, bottom: -70, child: _Circle(160, Neutral.c0.withValues(alpha: 0.06))),
          Positioned(left: -30, bottom: 30, child: _Circle(90, Neutral.c0.withValues(alpha: 0.05))),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Space.s24, Space.s24, Space.s24, Space.s32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const BrandMark(size: 52, inverted: true),
                  const SizedBox(height: Space.s20),
                  Text(title, style: t.headlineMedium!.copyWith(color: Neutral.c0)),
                  if (subtitle != null) ...[
                    const SizedBox(height: Space.s4),
                    Text(subtitle!, style: t.bodyLarge!.copyWith(color: Brand.c100)),
                  ],
                  ?child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle(this.size, this.color);
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}
