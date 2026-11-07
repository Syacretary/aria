import '../dto/aria_message_dto.dart';
import '../dto/daily_summary_dto.dart';
import '../dto/period_stats_dto.dart';
import '../dto/top_app_usage_dto.dart';
import '../dto/trend_point_dto.dart';
import '../dto/win_entry_dto.dart';

/// Read contract for Beranda data.
///
/// Three implementations exist: [HomeMockDatasource] (iteration 1),
/// a local cache, and a remote stub. The repository picks one; the UI never
/// knows which.
abstract interface class HomeDatasource {
  Future<DailySummaryDto> fetchDailySummary();

  Future<PeriodBreakdownDto> fetchPeriodBreakdown();

  Future<List<TrendPointDto>> fetchTrend({required int days});

  Future<List<TopAppUsageDto>> fetchTopApps({required int count});

  Future<List<WinEntryDto>> fetchTodaysWins();

  Future<AriaMessageDto> fetchCurrentMessage();

  Future<AriaMessageDto> sendReply(String userMessage);
}
