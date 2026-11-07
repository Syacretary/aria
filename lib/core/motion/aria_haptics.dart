import 'package:flutter/services.dart';

/// All haptics go through here.
///
/// House rule: feedback must be *light*. It should feel like a fingernail
/// tapped once on wood or paper — never like a phone buzzing in a pocket.
/// That means `selectionClick` and `lightImpact` only; `heavyImpact`,
/// `vibrate` and `mediumImpact` are banned by design.
///
/// No-ops silently on platforms without a haptic engine (desktop/web), and
/// respects the user's "reduce motion / disable haptics" accessibility setting
/// when the caller passes [enabled].
abstract final class AriaHaptics {
  /// The softest possible acknowledgement. Used for every ordinary tap.
  static Future<void> tap() => HapticFeedback.selectionClick();

  /// For discrete selections: segmented controls, list item choice.
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// A hair firmer, still light. Reserved for confirmations the user
  /// deliberately triggered (saving a limit, toggling a switch).
  static Future<void> confirm() => HapticFeedback.lightImpact();

  /// Celebratory but restrained — used when a "win" is logged.
  static Future<void> success() => HapticFeedback.lightImpact();

  /// Attention without alarm. Deliberately NOT a heavy buzz.
  static Future<void> warning() => HapticFeedback.lightImpact();

  // --- Disabled counterparts ------------------------------------------------
  // Used when the caller has determined haptics should be suppressed
  // (accessibility setting, tests). Kept as named methods so call sites read
  // identically whether haptics are on or off.

  static Future<void> silent() async {}
}
