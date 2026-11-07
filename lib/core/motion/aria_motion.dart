import 'package:flutter/animation.dart';

/// Central source of truth for every duration, curve and spring in ARIA.
///
/// Nothing in the app should hard-code a duration. The `prefer_aria_duration`
/// lint rule flags raw integers passed to animation APIs so new code
/// automatically inherits the house feel.
abstract final class AriaMotion {
  // ---------------------------------------------------------------------------
  // Durations
  // ---------------------------------------------------------------------------

  /// Fast micro-interactions: press scale, icon toggles, chip selection.
  static const Duration fast = Duration(milliseconds: 140);

  /// Standard transition: color changes, small reveals, inline feedback.
  static const Duration medium = Duration(milliseconds: 240);

  /// Sheets and page transitions. Slow enough to read as "weightless".
  static const Duration slow = Duration(milliseconds: 320);

  /// Deliberate, ceremonial motion (e.g. ARIA speaking, onboarding).
  static const Duration deliberate = Duration(milliseconds: 460);

  /// How long a sheet takes to leave. Shorter than entry so dismissal feels
  /// responsive rather than sluggish.
  static const Duration sheetExit = Duration(milliseconds: 200);

  // ---------------------------------------------------------------------------
  // Content motion
  // ---------------------------------------------------------------------------

  /// Data visualisation entrance (bars growing, rings filling).
  static const Duration chartEnter = Duration(milliseconds: 480);

  /// Slow, looping shimmer for skeleton placeholders.
  static const Duration shimmer = Duration(milliseconds: 1400);

  /// Scroll-to-end when a new chat message arrives.
  static const Duration scrollToEnd = Duration(milliseconds: 260);

  // ---------------------------------------------------------------------------
  // Curves
  // ---------------------------------------------------------------------------

  /// Decelerating curve for anything entering the screen.
  static const Curve enter = Curves.easeOutCubic;

  /// Accelerating curve for anything leaving the screen.
  static const Curve exit = Curves.easeInCubic;

  /// For press/scale feedback — symmetric so press and release match.
  static const Curve press = Curves.easeOut;

  /// Gentle overshoot. Deliberately mild (not `easeOutBack`, which is too
  /// bouncy): gives the soft "spring" landing without feeling cartoonish.
  static const Curve softSpring = Cubic(0.22, 1.12, 0.32, 1.0);

  // ---------------------------------------------------------------------------
  // Springs (used by SpringSimulation where a curve isn't enough)
  // ---------------------------------------------------------------------------

  /// The house spring: light, quick settle, no visible wobble.
  static const SpringDescription soft = SpringDescription(
    mass: 1,
    stiffness: 260,
    damping: 26,
  );

  /// Slightly softer, for surfaces with more visual mass (sheets).
  static const SpringDescription surface = SpringDescription(
    mass: 1,
    stiffness: 210,
    damping: 26,
  );

  // ---------------------------------------------------------------------------
  // Press feedback
  // ---------------------------------------------------------------------------

  /// Scale applied while a tap is held. Barely perceptible on purpose.
  static const double pressedScale = 0.97;

  /// Scale for large surfaces (cards) — even subtler than [pressedScale].
  static const double pressedScaleCard = 0.985;
}
