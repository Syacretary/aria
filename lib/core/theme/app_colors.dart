import 'package:flutter/material.dart';

/// ARIA's palette — warm editorial neutrals with a single desaturated accent.
///
/// Design constraints this file encodes:
/// - **One accent only.** Sage. The skill's rule: more than one accent without
///   a distinct role makes a palette read as noise. ARIA's companion voice is
///   therefore a *tint* of the same sage, not a second hue.
/// - **No purple/blue "AI gradient".** That look is the most recognisable
///   generic-AI fingerprint, and it also works against a companion whose job is
///   to calm the user down.
/// - **Warm grays only.** Every neutral is tinted toward the same warm hue.
///   Mixing warm and cool grays is what makes a palette feel accidental.
/// - **No pure black, no pure white.** #1A1A18 and #FAF8F4 read as paper and
///   ink rather than screen.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  /// The one accent. Sage, saturation kept under 30% so it sits inside the
  /// neutrals instead of shouting over them.
  static const Color sage = Color(0xFF9A783E);

  /// A lighter sage for fills and rings on dark surfaces.
  static const Color sageSoft = Color(0xFFE1CB9C);

  /// Companion tint — ARIA's voice uses the same hue family, lighter and
  /// warmer, so the message card is distinguishable without introducing a
  /// second accent.
  static const Color companionTintLight = Color(0xFFFFF8E9);
  static const Color companionTintDark = Color(0xFF30291D);

  // ---------------------------------------------------------------------------
  // Warm neutrals — light
  // ---------------------------------------------------------------------------

  /// Page background: warm ivory, deliberately off-white.
  static const Color parchment = Color(0xFFFAF8F4);

  /// Raised surfaces (cards).
  static const Color paper = Color(0xFFFFFFFF);

  /// Recessed / inset areas (segmented tracks, input fills, skeleton base).
  static const Color recessLight = Color(0xFFF2EFE9);

  /// Ink.
  static const Color ink = Color(0xFF1A1A18);

  /// Secondary ink — the only "gray" in the system, warm-tinted.
  static const Color inkMuted = Color(0xFF6B6862);

  // ---------------------------------------------------------------------------
  // Warm neutrals — dark
  // ---------------------------------------------------------------------------

  /// Not a neutral charcoal: espresso, warm like the light mode.
  static const Color espresso = Color(0xFF141413);
  static const Color espressoRaised = Color(0xFF1C1B19);
  static const Color recessDark = Color(0xFF232220);

  static const Color inkLight = Color(0xFFF2F0EC);
  static const Color inkMutedDark = Color(0xFFA19D95);

  // ---------------------------------------------------------------------------
  // Semantic — all desaturated to sit in the same family
  // ---------------------------------------------------------------------------

  /// Achievement. A muted olive-sage, not a bright "success green".
  static const Color win = Color(0xFF8C713D);
  static const Color winSurfaceLight = Color(0xFFF5EBD3);
  static const Color winSurfaceDark = Color(0xFF30291D);

  /// Caution. Warm ochre, desaturated.
  static const Color caution = Color(0xFFB08A47);

  /// Over-limit. Terracotta rather than a warning-red; reads as concern, not
  /// alarm.
  static const Color over = Color(0xFF95705A);
  static const Color overSurfaceLight = Color(0xFFF1E5EF);
  static const Color overSurfaceDark = Color(0xFF302532);

  /// The Material seed. Only used to generate the ColorScheme; every visible
  /// colour is specified explicitly below so nothing drifts.
  static const Color seed = sage;
}
