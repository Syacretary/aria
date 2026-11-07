import 'package:flutter/widgets.dart';

/// Corner radius scale, built for the Double-Bezel nesting technique.
///
/// The rule: an inner surface's radius is the outer radius minus the shell's
/// padding, so the two curves stay concentric. Arithmetic in `AppRadius.inner`
/// keeps that honest instead of eyeballed.
abstract final class AppRadius {
  // Base scale — tighter on small elements, softer on containers.
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;

  /// The house container radius. Generous, squircle-ish.
  static const double shell = 28;

  /// Sheet top corners.
  static const double sheet = 34;

  /// Outer shell of a nested card.
  static const BorderRadius shellBorder = BorderRadius.all(
    Radius.circular(shell),
  );

  /// Inner core of a nested card whose shell has [shellPadding] inset.
  static BorderRadius inner({double shellPadding = 6, double? override}) {
    final radius = override ?? (shell - shellPadding);
    return BorderRadius.all(Radius.circular(radius));
  }

  /// Convenience for the common 6px shell.
  static const BorderRadius innerDefault = BorderRadius.all(
    Radius.circular(shell - 6),
  );

  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );

  /// Fully rounded, for pills and chips.
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));

  /// Default radius for snackbars and small floating surfaces.
  static const BorderRadius snack = BorderRadius.all(Radius.circular(18));
}
