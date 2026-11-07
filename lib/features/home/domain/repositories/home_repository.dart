import '../../../../core/error/result.dart';
import '../entities/daily_summary.dart';
import '../entities/period_stats.dart';
import '../entities/top_app_usage.dart';
import '../entities/trend_point.dart';
import '../entities/win_entry.dart';

/// Read-side contract for everything the Beranda feed displays.
///
/// Split per concern rather than exposing one "home data" blob, so each card
/// can load, fail and refresh independently.
abstract interface class HomeRepository {
  Future<Result<DailySummary>> getDailySummary();

  Future<Result<PeriodBreakdown>> getPeriodBreakdown();

  Future<Result<List<TrendPoint>>> getTrend({int days});

  Future<Result<List<TopAppUsage>>> getTopApps({int count});

  Future<Result<List<WinEntry>>> getTodaysWins();
}
