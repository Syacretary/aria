import '../../../../core/error/result.dart';
import '../entities/usage_session.dart';

/// Abstraction over the platform's usage statistics.
///
/// This is the seam that keeps Android-specific code out of the app: the mock
/// source answers now, an Android source backed by `UsageStatsManager` will
/// answer later, and nothing above this interface changes. Every method
/// returns a [Result] because the system API can genuinely fail (permission
/// revoked mid-session, service unavailable).
abstract interface class UsageStatsRepository {
  /// Total screen time per package for the day containing [day].
  Future<Result<Map<String, Duration>>> getScreenTimeByApp({
    required DateTime day,
  });

  /// How many times each package was opened on [day].
  Future<Result<Map<String, int>>> getLaunchCounts({required DateTime day});

  /// Raw sessions for [day], used for pattern analysis.
  Future<Result<List<UsageSession>>> getSessions({required DateTime day});

  /// Whether the OS permission this repository depends on is granted.
  Future<Result<bool>> hasUsageAccess();
}
