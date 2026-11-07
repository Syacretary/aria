/// App-wide configuration constants.
abstract final class AppConfig {
  /// Shown in the about section and user-agent strings.
  static const String appName = 'ARIA';

  /// Bump alongside `pubspec.yaml` on release.
  static const String version = '1.0.0';

  /// Locale used for all `intl` formatting.
  static const String locale = 'id_ID';

  /// Default daily screentime target used when the user has not calibrated.
  static const Duration defaultDailyTarget = Duration(hours: 3);

  /// How many days the home trend chart covers.
  static const int trendWindowDays = 7;

  /// Number of apps shown in the "top apps" card.
  static const int topAppsCount = 3;
}
