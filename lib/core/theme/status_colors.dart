import 'package:material_ui/material_ui.dart';

/// Customer / item statuses with token colours. Never mapped onto M3 roles.
enum AppStatus {
  overdue,
  dueToday,
  promised,
  current,
  paid,
  badSuggested,
  tagged,
  pending,
  mock,

  /// v1.4 (FR-M-085): an invoice returned in the ERP, and the "returned product customer" marker. Shown, never counted.
  returned,
}

@immutable
class StatusStyle {
  const StatusStyle({required this.fg, required this.bg, this.dashed = false});
  final Color fg;
  final Color bg;

  /// `badSuggested` uses a dashed border (it is only a suggestion).
  final bool dashed;
}

/// `ThemeExtension` carrying status fg/bg per brightness (tokens §2).
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors(this._map);

  final Map<AppStatus, StatusStyle> _map;

  StatusStyle of(AppStatus s) => _map[s]!;

  static const light = StatusColors({
    AppStatus.overdue: StatusStyle(fg: Color(0xFFC62828), bg: Color(0xFFFDECEC)),
    AppStatus.dueToday: StatusStyle(fg: Color(0xFF92400E), bg: Color(0xFFFEF3C7)),
    AppStatus.promised: StatusStyle(fg: Color(0xFF6D28D9), bg: Color(0xFFF1EAFE)),
    AppStatus.current: StatusStyle(fg: Color(0xFF2C44CC), bg: Color(0xFFEEF3FF)),
    AppStatus.paid: StatusStyle(fg: Color(0xFF166534), bg: Color(0xFFE8F6EC)),
    AppStatus.badSuggested:
        StatusStyle(fg: Color(0xFFC2410C), bg: Color(0xFFFFF1E8), dashed: true),
    AppStatus.tagged: StatusStyle(fg: Color(0xFFFFFFFF), bg: Color(0xFF7F1D1D)),
    AppStatus.pending: StatusStyle(fg: Color(0xFF475569), bg: Color(0xFFEEF1F5)),
    AppStatus.mock: StatusStyle(fg: Color(0xFF9D174D), bg: Color(0xFFFCE7F3)),
    AppStatus.returned: StatusStyle(fg: Color(0xFF0F766E), bg: Color(0xFFE3F5F2)),
  });

  static const dark = StatusColors({
    AppStatus.overdue: StatusStyle(fg: Color(0xFFF87171), bg: Color(0xFF2D1212)),
    AppStatus.dueToday: StatusStyle(fg: Color(0xFFFBBF24), bg: Color(0xFF2E2208)),
    AppStatus.promised: StatusStyle(fg: Color(0xFFA78BFA), bg: Color(0xFF1F1536)),
    AppStatus.current: StatusStyle(fg: Color(0xFF7C93FA), bg: Color(0xFF141B3D)),
    AppStatus.paid: StatusStyle(fg: Color(0xFF4ADE80), bg: Color(0xFF0F2A1A)),
    AppStatus.badSuggested:
        StatusStyle(fg: Color(0xFFFB923C), bg: Color(0xFF2E1A0C), dashed: true),
    AppStatus.tagged: StatusStyle(fg: Color(0xFFFFFFFF), bg: Color(0xFFB91C1C)),
    AppStatus.pending: StatusStyle(fg: Color(0xFFA9B1BF), bg: Color(0xFF1A2030)),
    AppStatus.mock: StatusStyle(fg: Color(0xFFF472B6), bg: Color(0xFF2E1020)),
    AppStatus.returned: StatusStyle(fg: Color(0xFF2DD4BF), bg: Color(0xFF0B2624)),
  });

  /// High-contrast mode: status fg darkened one step (light theme only).
  StatusColors highContrast() => StatusColors({
        for (final e in _map.entries)
          e.key: StatusStyle(
            fg: e.key == AppStatus.tagged
                ? e.value.fg
                : Color.lerp(e.value.fg, const Color(0xFF000000), 0.18)!,
            bg: e.value.bg,
            dashed: e.value.dashed,
          ),
      });

  @override
  StatusColors copyWith({Map<AppStatus, StatusStyle>? map}) =>
      StatusColors(map ?? _map);

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors({
      for (final s in AppStatus.values)
        s: StatusStyle(
          fg: Color.lerp(of(s).fg, other.of(s).fg, t)!,
          bg: Color.lerp(of(s).bg, other.of(s).bg, t)!,
          dashed: t < 0.5 ? of(s).dashed : other.of(s).dashed,
        ),
    });
  }
}

/// Semantic colours (success / warning / danger / info).
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  final StatusStyle success;
  final StatusStyle warning;
  final StatusStyle danger;
  final StatusStyle info;

  static const light = SemanticColors(
    success: StatusStyle(fg: Color(0xFF166534), bg: Color(0xFFE8F6EC)),
    warning: StatusStyle(fg: Color(0xFF92400E), bg: Color(0xFFFEF3C7)),
    danger: StatusStyle(fg: Color(0xFFB91C1C), bg: Color(0xFFFDECEC)),
    info: StatusStyle(fg: Color(0xFF0369A1), bg: Color(0xFFE6F4FB)),
  );

  static const dark = SemanticColors(
    success: StatusStyle(fg: Color(0xFF4ADE80), bg: Color(0xFF0F2A1A)),
    warning: StatusStyle(fg: Color(0xFFFBBF24), bg: Color(0xFF2E2208)),
    danger: StatusStyle(fg: Color(0xFFF87171), bg: Color(0xFF2D1212)),
    info: StatusStyle(fg: Color(0xFF38BDF8), bg: Color(0xFF0B2230)),
  );

  @override
  SemanticColors copyWith() => this;

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) =>
      t < 0.5 ? this : (other as SemanticColors? ?? this);
}

extension AppThemeX on BuildContext {
  StatusColors get statusColors =>
      Theme.of(this).extension<StatusColors>() ?? StatusColors.light;
  SemanticColors get semanticColors =>
      Theme.of(this).extension<SemanticColors>() ?? SemanticColors.light;
}
