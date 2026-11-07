import '../../../../core/error/exceptions.dart';
import '../../domain/entities/usage_session.dart';
import 'usage_stats_source.dart';

/// Android implementation backed by `UsageStatsManager`.
///
/// Not wired in iteration 1 — this is the landing site for the real
/// integration. The steps it needs are written down so the work is scoped:
///
/// 1. Declare `android.permission.PACKAGE_USAGE_STATS` in the manifest.
/// 2. Detect the grant via `AppOpsManager` (`OPSTR_GET_USAGE_STATS`); the
///    permission cannot be requested from a dialog, only from Settings.
/// 3. Query `UsageStatsManager.queryUsageStats(INTERVAL_DAILY, start, end)`
///    for per-app totals, or `queryEvents` for raw session boundaries.
/// 4. Map `UsageEvents.Event.ACTIVITY_RESUMED`/`ACTIVITY_PAUSED` pairs into
///    [UsageSession]s.
/// 5. Expose all of it over a `MethodChannel` and delegate from this class.
class UsageStatsAndroidSource implements UsageStatsSource {
  const UsageStatsAndroidSource();

  @override
  Future<Map<String, Duration>> screenTimeByApp({required DateTime day}) async {
    throw const PlatformExceptionWrapper(
      'Integrasi UsageStatsManager belum diimplementasikan.',
    );
  }

  @override
  Future<Map<String, int>> launchCounts({required DateTime day}) async {
    throw const PlatformExceptionWrapper(
      'Integrasi UsageStatsManager belum diimplementasikan.',
    );
  }

  @override
  Future<List<UsageSession>> sessions({required DateTime day}) async {
    throw const PlatformExceptionWrapper(
      'Integrasi UsageStatsManager belum diimplementasikan.',
    );
  }

  @override
  Future<bool> hasUsageAccess() async => false;
}
