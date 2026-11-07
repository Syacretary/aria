import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale.
///
/// Choices worth knowing:
/// - **Plus Jakarta Sans, vendored.** The TTF files live in `assets/fonts/` and
///   are declared in `pubspec.yaml`, so the app renders identically offline and
///   golden tests are deterministic. Nothing is fetched at runtime.
/// - **Weights spread across 400/500/600/700** rather than only 400/700 — that
///   is what creates hierarchy without needing a size jump everywhere.
/// - **Numbers use tabular figures.** Screen time, percentages and counts are
///   compared vertically all over this app; proportional digits make those
///   columns visibly ragged.
/// - **Negative tracking on display sizes**, positive tracking on micro labels.
abstract final class AppTypography {
  /// The bundled family name. Must match `flutter.fonts[].family` in pubspec.
  static const String family = 'PlusJakartaSans';

  /// Tabular figures for any numeric context.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static TextStyle numeric(TextStyle? base) =>
      (base ?? const TextStyle()).copyWith(fontFeatures: tabular);

  /// Base text style resolved against the bundled family.
  static TextStyle _base({
    required double fontSize,
    required FontWeight weight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) {
    final ink = onSurface;

    return TextTheme(
      displaySmall: _base(
        fontSize: 38,
        weight: FontWeight.w700,
        color: ink,
        letterSpacing: -1.4,
        height: 1.02,
      ),
      headlineMedium: _base(
        fontSize: 28,
        weight: FontWeight.w700,
        color: ink,
        letterSpacing: -0.9,
        height: 1.1,
      ),
      headlineSmall: _base(
        fontSize: 23,
        weight: FontWeight.w600,
        color: ink,
        letterSpacing: -0.6,
        height: 1.15,
      ),
      titleLarge: _base(
        fontSize: 19,
        weight: FontWeight.w600,
        color: ink,
        letterSpacing: -0.4,
      ),
      titleMedium: _base(
        fontSize: 16,
        weight: FontWeight.w600,
        color: ink,
        letterSpacing: -0.2,
      ),
      titleSmall: _base(fontSize: 14, weight: FontWeight.w600, color: ink),
      // Body is set a touch looser than Material's default: this app is read in
      // short glances, and cramped leading makes that harder.
      bodyLarge: _base(
        fontSize: 15.5,
        weight: FontWeight.w400,
        color: ink,
        height: 1.5,
        letterSpacing: -0.1,
      ),
      bodyMedium: _base(
        fontSize: 14,
        weight: FontWeight.w400,
        color: ink,
        height: 1.5,
      ),
      bodySmall: _base(
        fontSize: 12.5,
        weight: FontWeight.w400,
        color: onSurfaceVariant,
        height: 1.4,
      ),
      labelLarge: _base(fontSize: 14, weight: FontWeight.w600, color: ink),
      labelMedium: _base(
        fontSize: 12.5,
        weight: FontWeight.w500,
        color: ink,
        letterSpacing: 0.1,
      ),
      // Micro labels: the "eyebrow" treatment. Positive tracking at tiny sizes
      // is what keeps uppercase text legible instead of shouty.
      labelSmall: _base(
        fontSize: 10.5,
        weight: FontWeight.w600,
        color: onSurfaceVariant,
        letterSpacing: 1.1,
      ),
    );
  }

  /// The eyebrow style used above section headers and card titles.
  static TextStyle eyebrow(Color color) => _base(
    fontSize: 10.5,
    weight: FontWeight.w600,
    color: color,
    letterSpacing: 1.6,
    height: 1.2,
  );

  /// Applies tabular figures to the numeric parts of a theme.
  static TextTheme withTabularFigures(TextTheme theme) => theme.copyWith(
    displaySmall: numeric(theme.displaySmall),
    headlineMedium: numeric(theme.headlineMedium),
    headlineSmall: numeric(theme.headlineSmall),
    titleLarge: numeric(theme.titleLarge),
    titleMedium: numeric(theme.titleMedium),
  );

  /// Convenience for inline numeric spans.
  static TextStyle tabularStyle(TextStyle style) => style.copyWith(
    fontFeatures: tabular,
    color: style.color ?? AppColors.ink,
  );
}
