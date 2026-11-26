import 'dart:ui' show Brightness;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Shared design tokens v1.3 (v1.1 added pay-state colours; v1.2 the `shadow.*` elevation tokens; v1.3 the
/// bad-tag kinds `status.tag.*` and the quick-action tones `action.*`, both in `tag_colors.dart`).
///
/// Canonical source: admin-web/docs/03-design-guide.md §2 and
/// docs/design-tokens.json. Values here MUST stay identical; the token test
/// (`test/core/theme/tokens_test.dart`) compares them with the JSON file.
abstract final class Brand {
  static const c50 = Color(0xFFEEF3FF);
  static const c100 = Color(0xFFDCE5FF);
  static const c200 = Color(0xFFBACBFF);
  static const c300 = Color(0xFF8EA8FF);
  static const c400 = Color(0xFF5F7DF7);
  static const c500 = Color(0xFF3D5AE8);
  static const c600 = Color(0xFF2C44CC);
  static const c700 = Color(0xFF2437A6);
  static const c800 = Color(0xFF1F3085);
  static const c900 = Color(0xFF1C2B6B);
  static const c950 = Color(0xFF121A42);
}

abstract final class Neutral {
  static const c0 = Color(0xFFFFFFFF);
  static const c25 = Color(0xFFFBFCFD);
  static const c50 = Color(0xFFF6F7F9);
  static const c100 = Color(0xFFEDEFF3);
  static const c200 = Color(0xFFDDE1E8);
  static const c300 = Color(0xFFC4CAD4);
  static const c400 = Color(0xFF98A1B0);
  static const c500 = Color(0xFF6B7587);
  static const c600 = Color(0xFF4D5666);
  static const c700 = Color(0xFF374050);
  static const c800 = Color(0xFF232A36);
  static const c900 = Color(0xFF151A23);
  static const c950 = Color(0xFF0B0E14);
}

/// Dark-mode surface tokens (`color.dark`).
abstract final class DarkTokens {
  static const background = Color(0xFF0B0E14);
  static const surface = Color(0xFF121722);
  static const raised = Color(0xFF1A2030);
  static const border = Color(0xFF262E3F);
  static const text = Color(0xFFE7EAF0);
  static const textSecondary = Color(0xFFA9B1BF);
  static const primary = Color(0xFF7C93FA);
}

/// Payment method accent colours (`color.paymentMethod`). Brand-neutral
/// glyphs only — no third-party logos.
abstract final class MethodColors {
  static const cash = Color(0xFF2C44CC);
  static const bkash = Color(0xFFDB2777);
  static const nagad = Color(0xFFEA580C);
  static const rocket = Color(0xFF7C3AED);
  static const bankTransfer = Color(0xFF0EA5A4);
  static const otherMobile = Color(0xFF64748B);
}

/// 4-pt spacing scale.
abstract final class Space {
  static const s0 = 0.0;
  static const s2 = 2.0;
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s40 = 40.0;
  static const s48 = 48.0;
  static const s64 = 64.0;

  /// Screen side margin.
  static const screen = s16;

  /// Gap between cards.
  static const cardGap = s12;
}

abstract final class Radii {
  static const xs = 4.0;
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const xxl = 28.0;
  static const full = 9999.0;

  static const brXs = BorderRadius.all(Radius.circular(xs));
  static const brSm = BorderRadius.all(Radius.circular(sm));
  static const brMd = BorderRadius.all(Radius.circular(md));
  static const brLg = BorderRadius.all(Radius.circular(lg));
  static const brXl = BorderRadius.all(Radius.circular(xl));
  static const brXxl = BorderRadius.all(Radius.circular(xxl));
}

/// Elevation shadows (`shadow.*`, tokens v1.2): soft, cool-grey ink
/// `rgb(16 24 40)`. Light theme only — in dark mode depth comes from the
/// surface steps and the 1 px border, so [of] returns no shadow there.
abstract final class Shadows {
  static const sm = [
    BoxShadow(color: Color(0x0F101828), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x14101828), offset: Offset(0, 1), blurRadius: 3),
  ];
  static const md = [
    BoxShadow(color: Color(0x14101828), offset: Offset(0, 4), blurRadius: 12, spreadRadius: -2),
    BoxShadow(color: Color(0x0A101828), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -2),
  ];
  static const none = <BoxShadow>[];

  /// The shadow for [brightness]: [level] in light mode, none in dark mode.
  static List<BoxShadow> of(Brightness brightness, List<BoxShadow> level) => brightness == Brightness.dark ? none : level;
}

abstract final class Motion {
  static const fast = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 300);
  static const standard = Cubic(0.2, 0, 0, 1);
  static const emphasized = Cubic(0.3, 0, 0, 1);
}

abstract final class Sizes {
  /// Minimum touch target (dp).
  static const minTarget = 48.0;

  /// Primary flow buttons and extended FAB height.
  static const primaryButton = 56.0;

  /// Two-line list row.
  static const row2 = 72.0;

  /// Three-line list row with badges (customer tile).
  static const row3 = 88.0;

  /// Keypad key height.
  static const keypadKey = 72.0;

  /// Camera shutter.
  static const shutter = 72.0;
}
