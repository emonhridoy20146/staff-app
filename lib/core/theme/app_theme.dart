import 'package:material_ui/material_ui.dart';

import 'status_colors.dart';
import 'tag_colors.dart';
import 'tokens.dart';

/// Material 3 theme built from the shared tokens (design guide §3).
abstract final class AppTheme {
  static const fontFamily = 'Inter';
  static const fontFallback = ['NotoSansBengali'];
  static const monoFamily = 'JetBrainsMono';

  static ThemeData light({bool highContrast = false}) =>
      _build(_lightScheme(highContrast), Brightness.light, highContrast);

  static ThemeData dark({bool highContrast = false}) =>
      _build(_darkScheme, Brightness.dark, highContrast);

  static ColorScheme _lightScheme(bool hc) {
    final base = ColorScheme.fromSeed(seedColor: Brand.c600);
    return base.copyWith(
      primary: Brand.c600,
      onPrimary: Neutral.c0,
      primaryContainer: Brand.c100,
      onPrimaryContainer: Brand.c950,
      secondary: Neutral.c600,
      onSecondary: Neutral.c0,
      secondaryContainer: Neutral.c100,
      onSecondaryContainer: Neutral.c900,
      tertiary: const Color(0xFF6D28D9),
      onTertiary: Neutral.c0,
      tertiaryContainer: const Color(0xFFF1EAFE),
      onTertiaryContainer: const Color(0xFF2E1065),
      error: const Color(0xFFB91C1C),
      onError: Neutral.c0,
      errorContainer: const Color(0xFFFDECEC),
      onErrorContainer: const Color(0xFF7F1D1D),
      surface: Neutral.c0,
      onSurface: Neutral.c900,
      surfaceContainerLowest: Neutral.c0,
      surfaceContainerLow: Neutral.c25,
      surfaceContainer: Neutral.c50,
      surfaceContainerHigh: Neutral.c100,
      surfaceContainerHighest: Neutral.c200,
      onSurfaceVariant: hc ? Neutral.c800 : Neutral.c600,
      outline: hc ? Neutral.c600 : Neutral.c400,
      outlineVariant: hc ? Neutral.c500 : Neutral.c200,
      inverseSurface: Neutral.c800,
      onInverseSurface: Neutral.c50,
      inversePrimary: Brand.c300,
      surfaceTint: Colors.transparent,
    );
  }

  static final ColorScheme _darkScheme =
      ColorScheme.fromSeed(seedColor: Brand.c600, brightness: Brightness.dark).copyWith(
    primary: const Color(0xFFB9C6FF),
    onPrimary: const Color(0xFF0F1F7A),
    primaryContainer: Brand.c700,
    onPrimaryContainer: Brand.c100,
    secondary: Neutral.c300,
    onSecondary: Neutral.c900,
    secondaryContainer: const Color(0xFF2A3242),
    onSecondaryContainer: DarkTokens.text,
    tertiary: const Color(0xFFCDB8FF),
    onTertiary: const Color(0xFF2E1065),
    tertiaryContainer: const Color(0xFF1F1536),
    onTertiaryContainer: const Color(0xFFE9DDFF),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF5C1414),
    errorContainer: const Color(0xFF5C1414),
    onErrorContainer: const Color(0xFFFFDAD6),
    surface: DarkTokens.surface,
    onSurface: DarkTokens.text,
    surfaceContainerLowest: DarkTokens.background,
    surfaceContainerLow: const Color(0xFF151B27),
    surfaceContainer: DarkTokens.raised,
    surfaceContainerHigh: const Color(0xFF212839),
    surfaceContainerHighest: const Color(0xFF283043),
    onSurfaceVariant: DarkTokens.textSecondary,
    outline: Neutral.c500,
    outlineVariant: const Color(0xFF2A3242),
    inverseSurface: DarkTokens.text,
    onInverseSurface: Neutral.c900,
    inversePrimary: Brand.c600,
    surfaceTint: Colors.transparent,
  );

  static TextTheme _textTheme(Color on) {
    TextStyle s(double size, double line, FontWeight w) => TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFallback,
          fontSize: size,
          height: line / size,
          fontWeight: w,
          color: on,
          letterSpacing: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );
    const sb = FontWeight.w600;
    const r = FontWeight.w400;
    return TextTheme(
      displayLarge: s(48, 56, sb),
      displayMedium: s(42, 50, sb),
      displaySmall: s(36, 44, sb),
      headlineLarge: s(32, 40, sb),
      headlineMedium: s(28, 36, sb),
      headlineSmall: s(24, 32, sb),
      titleLarge: s(22, 28, sb),
      titleMedium: s(18, 26, sb),
      titleSmall: s(16, 24, sb),
      bodyLarge: s(17, 26, r),
      bodyMedium: s(16, 24, r),
      bodySmall: s(14, 20, r),
      labelLarge: s(16, 22, sb),
      labelMedium: s(14, 20, sb),
      labelSmall: s(12, 16, sb),
    );
  }

  static ThemeData _build(ColorScheme cs, Brightness b, bool hc) {
    final text = _textTheme(cs.onSurface);
    final isDark = b == Brightness.dark;
    final borderW = hc ? 1.5 : 1.0;
    final status = isDark ? StatusColors.dark : (hc ? StatusColors.light.highContrast() : StatusColors.light);
    final semantic = isDark ? SemanticColors.dark : SemanticColors.light;
    // Tokens v1.3: the bad-tag kinds (`status.tag.*`) and the quick-action tones (`action.*`).
    final tags = isDark ? TagColors.dark : (hc ? TagColors.light.highContrast() : TagColors.light);
    final actions = isDark ? ActionColors.dark : ActionColors.light;
    const btnShape = RoundedRectangleBorder(borderRadius: Radii.brLg);
    const btnSize = Size(Sizes.minTarget, Sizes.primaryButton);

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: cs,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallback,
      textTheme: text,
      scaffoldBackgroundColor: isDark ? DarkTokens.background : Neutral.c50,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: [status, semantic, tags, actions],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? DarkTokens.background : Neutral.c50,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        toolbarHeight: 64,
      ),
      cardTheme: CardThemeData(
        color: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.brXl,
          side: BorderSide(color: cs.outlineVariant, width: borderW),
        ),
      ),
      dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: borderW, space: borderW),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: btnSize,
          shape: btnShape,
          textStyle: text.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: Space.s24),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: btnSize,
          shape: btnShape,
          textStyle: text.labelLarge,
          side: BorderSide(color: cs.outline, width: borderW),
          padding: const EdgeInsets.symmetric(horizontal: Space.s20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(Sizes.minTarget, Sizes.minTarget),
          shape: btnShape,
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(Sizes.minTarget, Sizes.minTarget)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        extendedTextStyle: text.labelLarge,
        extendedSizeConstraints: const BoxConstraints(minHeight: Sizes.primaryButton, minWidth: 120),
        shape: const RoundedRectangleBorder(borderRadius: Radii.brXl),
        elevation: 3,
        highlightElevation: 4,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: cs.primaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelSmall!.copyWith(
            color: s.contains(WidgetState.selected) ? cs.onSurface : cs.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 24,
            color: s.contains(WidgetState.selected) ? cs.onPrimaryContainer : cs.onSurfaceVariant,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: text.labelMedium,
        shape: const RoundedRectangleBorder(borderRadius: Radii.brMd),
        side: BorderSide(color: cs.outlineVariant, width: borderW),
        padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: Space.s8),
        backgroundColor: cs.surface,
        selectedColor: cs.primaryContainer,
        checkmarkColor: cs.onPrimaryContainer,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s16),
        border: OutlineInputBorder(
          borderRadius: Radii.brLg,
          borderSide: BorderSide(color: cs.outline, width: borderW),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.brLg,
          borderSide: BorderSide(color: cs.outline, width: borderW),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.brLg,
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        labelStyle: text.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
        hintStyle: text.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: cs.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xxl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: Radii.brLg),
        contentTextStyle: text.bodyMedium!.copyWith(color: cs.onInverseSurface),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: Space.s12,
        contentPadding: const EdgeInsets.symmetric(horizontal: Space.s16),
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
        iconColor: cs.onSurfaceVariant,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(Sizes.minTarget, Sizes.minTarget),
          textStyle: text.labelLarge,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: cs.surfaceContainerHigh,
        linearMinHeight: 8,
        borderRadius: const BorderRadius.all(Radius.circular(Radii.full)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
      ),
    );
  }

  /// Tabular-figure style for money and times.
  static TextStyle tabular(TextStyle base) =>
      base.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// Monospace for receipt numbers.
  static TextStyle mono(TextStyle base) =>
      base.copyWith(fontFamily: monoFamily, fontFamilyFallback: fontFallback);
}
