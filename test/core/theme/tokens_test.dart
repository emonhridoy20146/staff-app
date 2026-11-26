import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/core/theme/app_theme.dart';
import 'package:staff_app/core/theme/status_colors.dart';
import 'package:staff_app/core/theme/tag_colors.dart';
import 'package:staff_app/core/theme/tokens.dart';

/// The Dart tokens are the same as `docs/design-tokens.json` (shared with admin-web, CLAUDE.md §2.10), and
/// the v1.3 colours are readable: AA for text and icons, 3 : 1 for frames, light and dark.
void main() {
  final json = jsonDecode(File('docs/design-tokens.json').readAsStringSync()) as Map<String, dynamic>;
  final color = json['color'] as Map<String, dynamic>;

  String hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  Map<String, dynamic> group(String key, [Map<String, dynamic>? from]) => (from ?? color)[key] as Map<String, dynamic>;

  double luminance(Color c) {
    double ch(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
  }

  double contrast(Color a, Color b) {
    final la = luminance(a), lb = luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  void expectStyle(StatusStyle light, StatusStyle dark, Map<String, dynamic> j, String name) {
    expect(hex(light.fg), j['fg'], reason: '$name fg');
    expect(hex(light.bg), j['bg'], reason: '$name bg');
    expect(hex(dark.fg), j['fgDark'], reason: '$name fgDark');
    expect(hex(dark.bg), j['bgDark'], reason: '$name bgDark');
  }

  test('tokens are v1.3', () => expect(json['version'], '1.3.0'));

  test('brand, neutral, dark and payment method colours equal the JSON', () {
    const brand = {50: Brand.c50, 100: Brand.c100, 200: Brand.c200, 300: Brand.c300, 400: Brand.c400, 500: Brand.c500, 600: Brand.c600, 700: Brand.c700, 800: Brand.c800, 900: Brand.c900, 950: Brand.c950};
    const neutral = {0: Neutral.c0, 25: Neutral.c25, 50: Neutral.c50, 100: Neutral.c100, 200: Neutral.c200, 300: Neutral.c300, 400: Neutral.c400, 500: Neutral.c500, 600: Neutral.c600, 700: Neutral.c700, 800: Neutral.c800, 900: Neutral.c900, 950: Neutral.c950};
    expect({for (final e in brand.entries) '${e.key}': hex(e.value)}, group('brand'));
    expect({for (final e in neutral.entries) '${e.key}': hex(e.value)}, group('neutral'));
    expect(
      {'background': hex(DarkTokens.background), 'surface': hex(DarkTokens.surface), 'raised': hex(DarkTokens.raised), 'border': hex(DarkTokens.border), 'text': hex(DarkTokens.text), 'textSecondary': hex(DarkTokens.textSecondary), 'primary': hex(DarkTokens.primary)},
      group('dark'),
    );
    expect(
      {'cash': hex(MethodColors.cash), 'bkash': hex(MethodColors.bkash), 'nagad': hex(MethodColors.nagad), 'rocket': hex(MethodColors.rocket), 'bank_transfer': hex(MethodColors.bankTransfer), 'other_mobile': hex(MethodColors.otherMobile)},
      group('paymentMethod'),
    );
  });

  test('semantic and status colours equal the JSON', () {
    final semantic = group('semantic');
    expectStyle(SemanticColors.light.success, SemanticColors.dark.success, group('success', semantic), 'success');
    expectStyle(SemanticColors.light.warning, SemanticColors.dark.warning, group('warning', semantic), 'warning');
    expectStyle(SemanticColors.light.danger, SemanticColors.dark.danger, group('danger', semantic), 'danger');
    expectStyle(SemanticColors.light.info, SemanticColors.dark.info, group('info', semantic), 'info');
    final status = group('status');
    for (final s in AppStatus.values) {
      expectStyle(StatusColors.light.of(s), StatusColors.dark.of(s), group(s.name, status), 'status.${s.name}');
    }
    // Every status of the JSON has a Dart twin (`tag` is the v1.3 group, checked below).
    expect(status.keys.toSet(), {...AppStatus.values.map((s) => s.name), 'tag'});
  });

  test('v1.3 status.tag.* and action.* equal the JSON, one token per kind and tone', () {
    final tag = group('tag', group('status'))..remove('note');
    expect(tag.keys.toSet(), {for (final k in TagKind.values) k.token});
    for (final k in TagKind.values) {
      expectStyle(TagColors.light.of(k), TagColors.dark.of(k), group(k.token, tag), 'status.tag.${k.token}');
    }
    final action = group('action')..remove('note');
    expect(action.keys.toSet(), {for (final a in ActionTone.values) a.token});
    for (final a in ActionTone.values) {
      expectStyle(ActionColors.light.of(a), ActionColors.dark.of(a), group(a.token, action), 'action.${a.token}');
    }
  });

  test('tag reasons of the contract each have their own token; absconded is the strong one', () {
    // SetTag.reasonCode of the contract, the ones that set a tag.
    const reasons = ['plan_ended_unpaid', 'repeated_broken_promise', 'absconded', 'refused_to_pay', 'fraud_suspected', 'other'];
    final tokens = {for (final k in TagKind.values) k.token};
    expect(tokens.containsAll(reasons), isTrue);
    expect(tokens.difference(reasons.toSet()), {'legal'});
    expect([for (final k in TagKind.values) if (k.strong) k], [TagKind.absconded]);
    // Each kind has its own frame colour, in both themes.
    expect({for (final k in TagKind.values) hex(TagColors.light.of(k).fg)}.length, TagKind.values.length);
    expect({for (final k in TagKind.values) hex(TagColors.dark.of(k).fg)}.length, TagKind.values.length);
  });

  test('tag colours are readable: text and icon AA on the tint, the frame 3:1 on every surface', () {
    final themes = {
      'light': (TagColors.light, AppTheme.light().colorScheme, AppTheme.light().scaffoldBackgroundColor),
      'high contrast': (TagColors.light.highContrast(), AppTheme.light(highContrast: true).colorScheme, AppTheme.light(highContrast: true).scaffoldBackgroundColor),
      'dark': (TagColors.dark, AppTheme.dark().colorScheme, AppTheme.dark().scaffoldBackgroundColor),
    };
    for (final MapEntry(key: name, value: (tags, cs, scaffold)) in themes.entries) {
      // Where a customer row or the customer header sits.
      final surfaces = [cs.surface, cs.surfaceContainerLowest, cs.surfaceContainerLow, cs.surfaceContainer, scaffold];
      for (final k in TagKind.values) {
        final st = tags.of(k);
        // The tinted chip (fg on bg) and the filled one (bg on fg) share this ratio.
        expect(contrast(st.fg, st.bg), greaterThanOrEqualTo(4.5), reason: '$name ${k.token} fg on bg');
        for (final s in surfaces) {
          expect(contrast(st.fg, s), greaterThanOrEqualTo(3.0), reason: '$name ${k.token} frame on ${hex(s)}');
        }
      }
    }
  });

  test('the red family gets heavier with the case: absconded > legal > refused > other', () {
    const ramp = [TagKind.other, TagKind.refusedToPay, TagKind.legal, TagKind.absconded];
    final light = [for (final k in ramp) luminance(TagColors.light.of(k).fg)];
    final dark = [for (final k in ramp) luminance(TagColors.dark.of(k).fg)];
    for (var i = 1; i < ramp.length; i++) {
      expect(light[i], lessThan(light[i - 1]), reason: 'light: ${ramp[i].token} is darker than ${ramp[i - 1].token}');
      expect(dark[i], lessThan(dark[i - 1]), reason: 'dark: ${ramp[i].token} is more saturated (less washed out) than ${ramp[i - 1].token}');
    }
  });

  test('action tones: the icon is AA on its container, light and dark', () {
    for (final (name, tones) in [('light', ActionColors.light), ('dark', ActionColors.dark)]) {
      for (final a in ActionTone.values) {
        expect(contrast(tones.of(a).fg, tones.of(a).bg), greaterThanOrEqualTo(4.5), reason: '$name action.${a.token}');
      }
    }
  });

  test('the theme carries both v1.3 extensions', () {
    for (final t in [AppTheme.light(), AppTheme.dark(), AppTheme.light(highContrast: true)]) {
      expect(t.extension<TagColors>(), isNotNull);
      expect(t.extension<ActionColors>(), isNotNull);
    }
  });

  test('spacing, radius and motion equal the JSON', () {
    expect([Space.s0, Space.s2, Space.s4, Space.s8, Space.s12, Space.s16, Space.s20, Space.s24, Space.s32, Space.s40, Space.s48, Space.s64], json['space']);
    expect({'xs': Radii.xs, 'sm': Radii.sm, 'md': Radii.md, 'lg': Radii.lg, 'xl': Radii.xl, 'xxl': Radii.xxl, 'full': Radii.full}, json['radius']);
    final motion = json['motion'] as Map<String, dynamic>;
    expect([Motion.fast.inMilliseconds, Motion.base.inMilliseconds, Motion.slow.inMilliseconds], [motion['fastMs'], motion['baseMs'], motion['slowMs']]);
    expect(Sizes.minTarget, (json['touchTarget'] as Map<String, dynamic>)['appDp']);
  });
}
