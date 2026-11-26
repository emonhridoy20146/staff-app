import 'package:material_ui/material_ui.dart';

import 'status_colors.dart';

/// Why a customer is marked bad (tokens `status.tag.*`, v1.3). One per tag reason of the contract plus the
/// `legal` severity; [other] is the generic bad colour, also used for a reason code this app does not know.
///
/// Declared strongest first: [absconded] (পলাতক) wins over [legal], which wins over the plain reasons.
enum TagKind {
  absconded('absconded'),
  legal('legal'),
  refusedToPay('refused_to_pay'),
  other('other'),
  fraudSuspected('fraud_suspected'),
  brokenPromise('repeated_broken_promise'),
  planEndedUnpaid('plan_ended_unpaid');

  const TagKind(this.token);

  /// The key under `color.status.tag` in `docs/design-tokens.json` (the contract's reason code, or `legal`).
  final String token;

  /// The strongest kind is drawn heavier: a 2 dp frame and a filled chip (design guide §6 `TagFrame`).
  bool get strong => this == TagKind.absconded;
}

/// `ThemeExtension` with the frame / chip colours of every [TagKind]: `fg` is the frame, the icon and the text
/// on the tint; `bg` is the tint. One red family (absconded → legal → refused → other, darker = harder case;
/// in dark mode more saturated = harder) and three hues the app already uses with the same meaning: magenta
/// (something is fake), violet (promises), orange (the term ran out).
@immutable
class TagColors extends ThemeExtension<TagColors> {
  const TagColors(this._map);

  final Map<TagKind, StatusStyle> _map;

  StatusStyle of(TagKind k) => _map[k]!;

  static const light = TagColors({
    TagKind.absconded: StatusStyle(fg: Color(0xFF7F1D1D), bg: Color(0xFFFBDADA)),
    TagKind.legal: StatusStyle(fg: Color(0xFF991B1B), bg: Color(0xFFFDE3E3)),
    TagKind.refusedToPay: StatusStyle(fg: Color(0xFFB91C1C), bg: Color(0xFFFDECEC)),
    TagKind.other: StatusStyle(fg: Color(0xFFD42020), bg: Color(0xFFFEF2F2)),
    TagKind.fraudSuspected: StatusStyle(fg: Color(0xFF9D174D), bg: Color(0xFFFCE7F3)),
    TagKind.brokenPromise: StatusStyle(fg: Color(0xFF6D28D9), bg: Color(0xFFF1EAFE)),
    TagKind.planEndedUnpaid: StatusStyle(fg: Color(0xFFC2410C), bg: Color(0xFFFFF1E8)),
  });

  static const dark = TagColors({
    TagKind.absconded: StatusStyle(fg: Color(0xFFEF4444), bg: Color(0xFF2D1212)),
    TagKind.legal: StatusStyle(fg: Color(0xFFF87171), bg: Color(0xFF2D1212)),
    TagKind.refusedToPay: StatusStyle(fg: Color(0xFFFCA5A5), bg: Color(0xFF2D1212)),
    TagKind.other: StatusStyle(fg: Color(0xFFFECACA), bg: Color(0xFF2D1212)),
    TagKind.fraudSuspected: StatusStyle(fg: Color(0xFFF472B6), bg: Color(0xFF2E1020)),
    TagKind.brokenPromise: StatusStyle(fg: Color(0xFFA78BFA), bg: Color(0xFF1F1536)),
    TagKind.planEndedUnpaid: StatusStyle(fg: Color(0xFFFB923C), bg: Color(0xFF2E1A0C)),
  });

  /// High-contrast mode: fg darkened one step (light theme only), like [StatusColors.highContrast].
  TagColors highContrast() => TagColors({
        for (final e in _map.entries) e.key: StatusStyle(fg: Color.lerp(e.value.fg, const Color(0xFF000000), 0.18)!, bg: e.value.bg),
      });

  @override
  TagColors copyWith({Map<TagKind, StatusStyle>? map}) => TagColors(map ?? _map);

  @override
  TagColors lerp(ThemeExtension<TagColors>? other, double t) {
    if (other is! TagColors) return this;
    return TagColors({
      for (final k in TagKind.values) k: StatusStyle(fg: Color.lerp(of(k).fg, other.of(k).fg, t)!, bg: Color.lerp(of(k).bg, other.of(k).bg, t)!),
    });
  }
}

/// The tone of a quick action's icon circle (tokens `action.*`, v1.3): five tonal containers shared by the
/// Home grid and the Settings rows. A tone goes with a meaning (green = money, amber = time and notices,
/// brand = duty and the office, teal = the field and people, violet = goals), never a rainbow.
enum ActionTone {
  brand,
  teal,
  green,
  violet,
  amber;

  /// The key under `color.action` in `docs/design-tokens.json`.
  String get token => name;
}

/// `ThemeExtension` with the container (`bg`) and icon (`fg`) colour of every [ActionTone].
@immutable
class ActionColors extends ThemeExtension<ActionColors> {
  const ActionColors(this._map);

  final Map<ActionTone, StatusStyle> _map;

  StatusStyle of(ActionTone t) => _map[t]!;

  static const light = ActionColors({
    ActionTone.brand: StatusStyle(fg: Color(0xFF2437A6), bg: Color(0xFFDCE5FF)),
    ActionTone.teal: StatusStyle(fg: Color(0xFF115E59), bg: Color(0xFFD5F3F0)),
    ActionTone.green: StatusStyle(fg: Color(0xFF166534), bg: Color(0xFFDDF3E4)),
    ActionTone.violet: StatusStyle(fg: Color(0xFF5B21B6), bg: Color(0xFFEBE5FD)),
    ActionTone.amber: StatusStyle(fg: Color(0xFF92400E), bg: Color(0xFFFEF0C7)),
  });

  static const dark = ActionColors({
    ActionTone.brand: StatusStyle(fg: Color(0xFFB9C6FF), bg: Color(0xFF1B2757)),
    ActionTone.teal: StatusStyle(fg: Color(0xFF5EEAD4), bg: Color(0xFF0E2F2D)),
    ActionTone.green: StatusStyle(fg: Color(0xFF4ADE80), bg: Color(0xFF0F2A1A)),
    ActionTone.violet: StatusStyle(fg: Color(0xFFC4B5FD), bg: Color(0xFF251A45)),
    ActionTone.amber: StatusStyle(fg: Color(0xFFFBBF24), bg: Color(0xFF2E2208)),
  });

  @override
  ActionColors copyWith({Map<ActionTone, StatusStyle>? map}) => ActionColors(map ?? _map);

  @override
  ActionColors lerp(ThemeExtension<ActionColors>? other, double t) {
    if (other is! ActionColors) return this;
    return ActionColors({
      for (final a in ActionTone.values) a: StatusStyle(fg: Color.lerp(of(a).fg, other.of(a).fg, t)!, bg: Color.lerp(of(a).bg, other.of(a).bg, t)!),
    });
  }
}

extension TagThemeX on BuildContext {
  TagColors get tagColors => Theme.of(this).extension<TagColors>() ?? TagColors.light;
  ActionColors get actionColors => Theme.of(this).extension<ActionColors>() ?? ActionColors.light;
}
