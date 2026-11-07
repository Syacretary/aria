/// SharedPreferences keys, namespaced so they're greppable and never collide.
abstract final class PrefKeys {
  static const String themeMode = 'aria.settings.theme_mode';
  static const String hapticsEnabled = 'aria.settings.haptics_enabled';
  static const String ariaTone = 'aria.settings.tone';
  static const String dailyTargetMinutes = 'aria.settings.daily_target_min';
  static const String quietHoursEnabled = 'aria.settings.quiet_hours_enabled';
  static const String quietHoursFrom = 'aria.settings.quiet_hours_from';
  static const String quietHoursUntil = 'aria.settings.quiet_hours_until';
  static const String maskAppNames = 'aria.settings.mask_app_names';

  /// JSON map of `packageName -> AppLimit`.
  static const String appLimits = 'aria.app_manager.limits';

  /// Seeded flag so mock data stays stable between launches.
  static const String mockSeedInitialised = 'aria.debug.mock_seed';
}
