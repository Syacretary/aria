import 'package:flutter/material.dart';

import '../motion/aria_page_transition.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';
import 'aria_semantic_colors.dart';

/// Builds the ARIA [ThemeData] for a given brightness.
///
/// Everything visual flows from here. Two decisions are deliberately visible in
/// the code: the `ColorScheme` is generated from the sage seed and then
/// *overridden* on every surface role, and the text theme gets tabular figures
/// applied at the theme level so no call site has to remember.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final semantic = isLight
        ? AriaSemanticColors.light
        : AriaSemanticColors.dark;

    final base = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );

    // Surface roles are all set explicitly: letting Material derive them from
    // the seed is how palettes end up with a stray cool-grey surface in an
    // otherwise warm design.
    final scheme = base.copyWith(
      surface: isLight ? AppColors.parchment : AppColors.espresso,
      surfaceContainerLowest: isLight
          ? AppColors.paper
          : AppColors.espressoRaised,
      surfaceContainerLow: isLight ? AppColors.paper : AppColors.espressoRaised,
      surfaceContainer: isLight ? AppColors.recessLight : AppColors.recessDark,
      surfaceContainerHigh: isLight
          ? AppColors.recessLight
          : AppColors.recessDark,
      surfaceContainerHighest: isLight
          ? const Color(0xFFEAE6DE)
          : const Color(0xFF2C2B28),
      onSurface: isLight ? AppColors.ink : AppColors.inkLight,
      onSurfaceVariant: isLight ? AppColors.inkMuted : AppColors.inkMutedDark,
      primary: isLight ? AppColors.sage : AppColors.sageSoft,
      onPrimary: isLight ? Colors.white : const Color(0xFF10201C),
      primaryContainer: isLight
          ? const Color(0xFFDCE8E3)
          : const Color(0xFF243430),
      onPrimaryContainer: isLight
          ? const Color(0xFF1D3B34)
          : const Color(0xFFCFE3DC),
      secondary: AppColors.caution,
      onSecondary: isLight ? Colors.white : const Color(0xFF241B08),
      tertiary: semantic.win,
      onTertiary: Colors.white,
      error: semantic.over,
      outline: isLight ? const Color(0xFF9C978D) : const Color(0xFF6E6961),
      outlineVariant: isLight
          ? const Color(0xFFE2DED6)
          : const Color(0xFF34322E),
      inverseSurface: isLight ? AppColors.ink : AppColors.inkLight,
      onInverseSurface: isLight ? AppColors.parchment : AppColors.espresso,
    );

    final textTheme = AppTypography.withTabularFigures(
      AppTypography.textTheme(scheme.onSurface, scheme.onSurfaceVariant),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: kAriaPageTransitionsTheme,
      extensions: <ThemeExtension<dynamic>>[semantic],

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),

      // Card shape only. Actual cards use `AriaCard`, which draws the nested
      // shell itself.
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.shellBorder,
        ),
      ),

      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.shellBorder),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : (isLight ? const Color(0xFFF6F4EF) : const Color(0xFF5A5751)),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : scheme.outlineVariant,
        ),
      ),

      // Chunky thumb, quiet track: the slider is the main interaction in the
      // limit editor, so it should feel physical.
      sliderTheme: SliderThemeData(
        trackHeight: 8,
        activeTrackColor: scheme.primary,
        inactiveTrackColor: semantic.usageTrack,
        thumbColor: isLight ? Colors.white : AppColors.sageSoft,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
          elevation: 2,
          pressedElevation: 4,
        ),
        overlayColor: scheme.primary.withValues(alpha: 0.12),
      ),

      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primaryContainer,
        labelStyle: textTheme.labelMedium,
        showCheckmark: false,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
          side: BorderSide(color: scheme.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
          textStyle: textTheme.labelLarge,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 68,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.snack),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.pill,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
      ),
    );
  }
}
