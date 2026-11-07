import '../../domain/entities/usage_session.dart';

/// Platform boundary for usage statistics.
///
/// Two implementations: a mock returning believable data now, and an Android
/// one that will wrap `UsageStatsManager` behind the very same methods.
abstract interface class UsageStatsSource {
  Future<Map<String, Duration>> screenTimeByApp({required DateTime day});

  Future<Map<String, int>> launchCounts({required DateTime day});

  Future<List<UsageSession>> sessions({required DateTime day});

  Future<bool> hasUsageAccess();
}
