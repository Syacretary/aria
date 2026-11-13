import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic colours that don't belong in [ColorScheme].
///
/// Reach for these via `context.ariaColors`.
@immutable
class AriaSemanticColors extends ThemeExtension<AriaSemanticColors> {
  const AriaSemanticColors({
    required this.companion,
    required this.companionSurface,
    required this.companionBorder,
    required this.win,
    required this.winSurface,
    required this.over,
    required this.overSurface,
    required this.usageTrack,
    required this.usageFill,
    required this.shellWash,
    required this.hairline,
    required this.grain,
  });

  /// ARIA's voice. A tint of the single sage accent — not a second hue.
  final Color companion;
  final Color companionSurface;
  final Color companionBorder;

  final Color win;
  final Color winSurface;

  final Color over;
  final Color overSurface;

  /// Usage indicators.
  final Color usageTrack;
  final Color usageFill;

  /// The thin wash behind the outer shell of a nested card — this is what
  /// makes the card look like it sits in a tray rather than on the page.
  final Color shellWash;

  /// Hairline borders. Never a solid grey: always the surface hue at low alpha.
  final Color hairline;

  /// Noise overlay opacity and colour, kept here so both themes stay subtle.
  final Color grain;

  static const AriaSemanticColors light = AriaSemanticColors(
    companion: AppColors.sage,
    companionSurface: AppColors.companionTintLight,
    companionBorder: Color(0x1F4A7C6F),
    win: Color(0xFF8C713D),
    winSurface: AppColors.winSurfaceLight,
    over: Color(0xFF95705A),
    overSurface: AppColors.overSurfaceLight,
    usageTrack: Color(0xFFE6E2DA),
    usageFill: AppColors.sage,
    shellWash: Color(0x0A4A5046),
    hairline: Color(0x124A5046),
    grain: Color(0x0A1A1A18),
  );

  static const AriaSemanticColors dark = AriaSemanticColors(
    companion: AppColors.sageSoft,
    companionSurface: AppColors.companionTintDark,
    companionBorder: Color(0x2E7FA99C),
    win: Color(0xFFE4CA8D),
    winSurface: AppColors.winSurfaceDark,
    over: Color(0xFFC9A5D9),
    overSurface: AppColors.overSurfaceDark,
    usageTrack: Color(0xFF2A2926),
    usageFill: AppColors.sageSoft,
    shellWash: Color(0x14FFFFFF),
    hairline: Color(0x1FFFFFFF),
    grain: Color(0x0DFFFFFF),
  );

  @override
  AriaSemanticColors copyWith({
    Color? companion,
    Color? companionSurface,
    Color? companionBorder,
    Color? win,
    Color? winSurface,
    Color? over,
    Color? overSurface,
    Color? usageTrack,
    Color? usageFill,
    Color? shellWash,
    Color? hairline,
    Color? grain,
  }) {
    return AriaSemanticColors(
      companion: companion ?? this.companion,
      companionSurface: companionSurface ?? this.companionSurface,
      companionBorder: companionBorder ?? this.companionBorder,
      win: win ?? this.win,
      winSurface: winSurface ?? this.winSurface,
      over: over ?? this.over,
      overSurface: overSurface ?? this.overSurface,
      usageTrack: usageTrack ?? this.usageTrack,
      usageFill: usageFill ?? this.usageFill,
      shellWash: shellWash ?? this.shellWash,
      hairline: hairline ?? this.hairline,
      grain: grain ?? this.grain,
    );
  }

  @override
  AriaSemanticColors lerp(
    covariant ThemeExtension<AriaSemanticColors>? other,
    double t,
  ) {
    if (other is! AriaSemanticColors) return this;
    return AriaSemanticColors(
      companion: Color.lerp(companion, other.companion, t)!,
      companionSurface: Color.lerp(
        companionSurface,
        other.companionSurface,
        t,
      )!,
      companionBorder: Color.lerp(companionBorder, other.companionBorder, t)!,
      win: Color.lerp(win, other.win, t)!,
      winSurface: Color.lerp(winSurface, other.winSurface, t)!,
      over: Color.lerp(over, other.over, t)!,
      overSurface: Color.lerp(overSurface, other.overSurface, t)!,
      usageTrack: Color.lerp(usageTrack, other.usageTrack, t)!,
      usageFill: Color.lerp(usageFill, other.usageFill, t)!,
      shellWash: Color.lerp(shellWash, other.shellWash, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      grain: Color.lerp(grain, other.grain, t)!,
    );
  }
}

/// Convenience accessor so call sites read `context.ariaColors.companion`.
extension AriaSemanticColorsX on BuildContext {
  AriaSemanticColors get ariaColors =>
      Theme.of(this).extension<AriaSemanticColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AriaSemanticColors.dark
          : AriaSemanticColors.light);
}
