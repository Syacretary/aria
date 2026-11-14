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

  /// JSON daily measurements retained locally (maximum 35 days). No raw
  /// event stream, screen contents, or account data is persisted.
  static const String usageDailyHistory = 'aria.usage.daily_history.v1';

  /// Per-session video advances reported by ARIA-owned feed integrations.
  static const String scrollSessions = 'aria.usage.scroll_sessions.v1';

  /// Lifetime count of short social-app visits that ended within one minute.
  static const String quickSocialReturns =
      'aria.achievements.quick_social_returns';
  static const String intentionalSocialExits =
      'aria.achievements.intentional_exits';
  static const String completedBreathingPauses =
      'aria.achievements.completed_pauses';

  /// Dates already credited toward cumulative achievement levels.
  static const String achievementProgress = 'aria.achievements.progress.v1';

  /// Opt-in and cadence for private, local spot-check notifications.
  static const String spotCheckEnabled = 'aria.check_ins.enabled';
  static const String spotCheckIntervalDays = 'aria.check_ins.interval_days';

  /// Completed spot-checks and answers, retained only on this device.
  static const String spotCheckHistory = 'aria.check_ins.history.v1';

  static const String ariaAiEnabled = 'aria.ai.enabled';
  static const String ariaAiProactive = 'aria.ai.proactive';

  /// Whether the user has seen or completed the initial permission onboarding.
  static const String permissionOnboardingCompleted =
      'aria.onboarding.permission_flow_completed';
}
