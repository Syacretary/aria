import '../../domain/entities/installed_social_app.dart';
import '../../domain/entities/usage_session.dart';

/// Platform boundary for usage statistics.
///
/// Two implementations: a mock returning believable data now, and an Android
/// one that will wrap `UsageStatsManager` behind the very same methods.
abstract interface class UsageStatsSource {
  Future<List<InstalledSocialApp>> installedSocialApps();

  Future<Map<String, Duration>> screenTimeByApp({required DateTime day});

  Future<Map<String, int>> launchCounts({required DateTime day});

  Future<List<UsageSession>> sessions({required DateTime day});

  /// Locally derived count from the opt-in AccessibilityService. This is an
  /// estimate of short-video advances, never a count of taps or content read.
  Future<int> scrollCount({required DateTime day});

  Future<bool> hasUsageAccess();
}
