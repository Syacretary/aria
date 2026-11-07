/// Spatial scale.
///
/// Doubled relative to a typical app: the design brief calls for heavy
/// whitespace, and this app is read in short glances rather than studied. More
/// air per card means less scanning.
abstract final class AppSpacing {
  static const double xxs = 3;
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 56;

  /// Page gutter.
  static const double pageGutter = 20;

  /// Gap between stacked cards on a feed. Deliberately large — cards should
  /// read as separate objects, not as one continuous list.
  static const double cardGap = 16;

  /// Inset of an outer shell around an inner core (the Double-Bezel offset).
  static const double shellInset = 6;
}
