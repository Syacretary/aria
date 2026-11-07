import 'package:flutter/material.dart';

/// Elevation, expressed as light rather than as a shadow ramp.
///
/// Two rules from the design audit are baked in here:
/// - **Shadows are tinted.** A pure black shadow at low opacity reads as dirty
///   grey. Every shadow here is mixed from the surface hue so it looks like the
///   card is sitting in warm light.
/// - **One light source.** All offsets share the same direction (down, slightly
///   right), so every raised surface agrees on where the light is.
abstract final class AppShadows {
  static const Offset _lightDirection = Offset(0, 6);

  /// Standard raised card. Wide, very low-opacity, barely perceptible — the
  /// card should look like it floats, not like it is stamped on.
  static List<BoxShadow> raised(Brightness brightness) {
    final tint = brightness == Brightness.light
        ? const Color(0xFF4A5046) // warm dark-olive tint
        : const Color(0xFF000000);

    return [
      BoxShadow(
        color: tint.withValues(
          alpha: brightness == Brightness.light ? 0.05 : 0.45,
        ),
        offset: _lightDirection,
        blurRadius: 24,
        spreadRadius: -6,
      ),
      BoxShadow(
        color: tint.withValues(
          alpha: brightness == Brightness.light ? 0.03 : 0.30,
        ),
        offset: const Offset(0, 2),
        blurRadius: 6,
        spreadRadius: -2,
      ),
    ];
  }

  /// Hover / pressed lift for interactive cards.
  static List<BoxShadow> lifted(Brightness brightness) {
    final tint = brightness == Brightness.light
        ? const Color(0xFF4A5046)
        : const Color(0xFF000000);

    return [
      BoxShadow(
        color: tint.withValues(
          alpha: brightness == Brightness.light ? 0.08 : 0.55,
        ),
        offset: const Offset(0, 12),
        blurRadius: 36,
        spreadRadius: -8,
      ),
      BoxShadow(
        color: tint.withValues(
          alpha: brightness == Brightness.light ? 0.04 : 0.32,
        ),
        offset: const Offset(0, 3),
        blurRadius: 8,
        spreadRadius: -2,
      ),
    ];
  }

  /// The inner highlight that sells the "machined plate" look on the inner
  /// core of a Double-Bezel card. Light comes from above.
  static List<BoxShadow> innerHighlight(Brightness brightness) => [
    BoxShadow(
      color: Colors.white.withValues(
        alpha: brightness == Brightness.light ? 0.9 : 0.05,
      ),
      offset: const Offset(0, 1),
      blurRadius: 1,
      spreadRadius: 0,
    ),
  ];
}
