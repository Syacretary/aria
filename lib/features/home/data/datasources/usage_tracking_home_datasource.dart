import 'package:shared_preferences/shared_preferences.dart';

import '../../../app_manager/data/datasources/usage_stats_source.dart';
import '../../../usage_tracking/data/daily_usage_store.dart';
import '../../../usage_tracking/domain/social_apps.dart';
import '../../../usage_tracking/domain/todays_win_generator.dart';
import '../dto/aria_message_dto.dart';
import '../dto/daily_summary_dto.dart';
import '../dto/period_stats_dto.dart';
import '../dto/top_app_usage_dto.dart';
import '../dto/trend_point_dto.dart';
import '../dto/win_entry_dto.dart';
import 'home_datasource.dart';

/// Adapts platform usage data to the existing home-feed contract and stores a
/// compact daily checkpoint each time the dashboard refreshes.
class UsageTrackingHomeDatasource implements HomeDatasource {
  UsageTrackingHomeDatasource({
    required UsageStatsSource usageStats,
    required SharedPreferences preferences,
    required DateTime Function() clock,
  }) : _usageStats = usageStats,
       _store = DailyUsageStore(preferences),
       _clock = clock;

  final UsageStatsSource _usageStats;
  final DailyUsageStore _store;
  final DateTime Function() _clock;
  static const _targetMinutes = 180;

  @override
  Future<DailySummaryDto> fetchDailySummary() async {
    final today = _startOfDay(_clock());
    final current = await _refresh(today);
    final yesterday = await _forDay(today.subtract(const Duration(days: 1)));
    return DailySummaryDto(
      date: today.toIso8601String(),
      videosOpened: current.videosAdvanced,
      videosOpenedYesterday: yesterday?.videosAdvanced ?? 0,
      socialOpens: current.socialOpens,
      socialOpensYesterday: yesterday?.socialOpens ?? 0,
      screenTimeMinutes: current.socialMinutes,
      screenTimeMinutesYesterday: yesterday?.socialMinutes ?? 0,
    );
  }

  @override
  Future<PeriodBreakdownDto> fetchPeriodBreakdown() async {
    final today = _startOfDay(_clock());
    await _refresh(today);
    final history = await _store.readAll();
    int sum(int days, int offset) => history
        .where(
          (item) =>
              !item.day.isBefore(
                today.subtract(Duration(days: days - 1 + offset)),
              ) &&
              item.day.isBefore(today.subtract(Duration(days: offset - 1))),
        )
        .fold(0, (total, item) => total + item.socialOpens);
    return PeriodBreakdownDto(
      daily: PeriodStatDto(
        label: 'Hari ini',
        opens: sum(1, 0),
        previousOpens: sum(1, 1),
      ),
      weekly: PeriodStatDto(
        label: 'Minggu ini',
        opens: sum(7, 0),
        previousOpens: sum(7, 7),
      ),
      monthly: PeriodStatDto(
        label: 'Bulan ini',
        opens: sum(30, 0),
        previousOpens: sum(30, 30),
      ),
    );
  }

  @override
  Future<List<TrendPointDto>> fetchTrend({required int days}) async {
    final today = _startOfDay(_clock());
    await _refresh(today);
    final history = {
      for (final item in await _store.readAll()) dayKey(item.day): item,
    };
    return List.generate(days, (index) {
      final day = today.subtract(Duration(days: days - 1 - index));
      return TrendPointDto(
        date: day.toIso8601String(),
        screenTimeMinutes: history[dayKey(day)]?.socialMinutes ?? 0,
        targetMinutes: _targetMinutes,
      );
    });
  }

  @override
  Future<List<TopAppUsageDto>> fetchTopApps({required int count}) async {
    final today = _startOfDay(_clock());
    final screenTime = await _usageStats.screenTimeByApp(day: today);
    final opens = await _usageStats.launchCounts(day: today);
    final apps =
        screenTime.entries
            .where((entry) => SocialApps.contains(entry.key))
            .map(
              (entry) => TopAppUsageDto(
                packageName: entry.key,
                appName: SocialApps.labelFor(entry.key),
                screenTimeMinutes: entry.value.inMinutes,
                sessionCount: opens[entry.key] ?? 0,
              ),
            )
            .toList()
          ..sort((a, b) => b.screenTimeMinutes.compareTo(a.screenTimeMinutes));
    return apps.take(count).toList(growable: false);
  }

  @override
  Future<List<WinEntryDto>> fetchTodaysWins() async {
    final today = _startOfDay(_clock());
    final current = await _refresh(today);
    final previous = await _forDay(today.subtract(const Duration(days: 1)));
    return TodaysWinGenerator.build(
          today: current,
          yesterday: previous,
          targetMinutes: _targetMinutes,
          now: _clock(),
        )
        .map(
          (win) => WinEntryDto(
            id: win.id,
            label: win.label,
            detail: win.detail,
            occurredAt: win.occurredAt.toIso8601String(),
            kind: switch (win.icon) {
              // These are the wire names expected by HomeMappers.
              _ => win.icon.name == 'limitKept' ? 'limit_kept' : win.icon.name,
            },
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<AriaMessageDto> fetchCurrentMessage() async {
    final summary = await fetchDailySummary();
    final difference =
        summary.screenTimeMinutesYesterday - summary.screenTimeMinutes;
    final text = difference >= 10
        ? 'Hari ini kamu memberi dirimu $difference menit lebih banyak ruang dari kemarin. Itu kemajuan yang nyata.'
        : 'Aku sedang mencatat ritmemu dengan tenang. Setiap pilihan kecil tetap berarti.';
    return AriaMessageDto(
      id: 'usage-${summary.date}',
      text: text,
      createdAt: _clock().toIso8601String(),
      action: 'chat',
      actionLabel: 'Ngobrol',
      tone: 'gentle',
    );
  }

  @override
  Future<AriaMessageDto> sendReply(String userMessage) => fetchCurrentMessage();

  Future<DailyUsageSnapshot> _refresh(DateTime day) async {
    final screenTime = await _usageStats.screenTimeByApp(day: day);
    final opens = await _usageStats.launchCounts(day: day);
    final snapshot = DailyUsageSnapshot(
      day: day,
      socialMinutes: screenTime.entries
          .where((e) => SocialApps.contains(e.key))
          .fold(0, (sum, e) => sum + e.value.inMinutes),
      socialOpens: opens.entries
          .where((e) => SocialApps.contains(e.key))
          .fold(0, (sum, e) => sum + e.value),
      // Only emitted by the user-enabled service; UsageStats is never used to
      // infer this value from time spent or app-open events.
      videosAdvanced: await _usageStats.scrollCount(day: day),
    );
    await _store.upsert(snapshot);
    return snapshot;
  }

  Future<DailyUsageSnapshot?> _forDay(DateTime day) async {
    final entries = await _store.readAll();
    for (final item in entries) {
      if (dayKey(item.day) == dayKey(day)) return item;
    }
    return null;
  }

  DateTime _startOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
