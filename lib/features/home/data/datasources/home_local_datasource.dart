import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/pref_keys.dart';
import '../dto/aria_message_dto.dart';
import '../dto/daily_summary_dto.dart';
import '../dto/period_stats_dto.dart';
import '../dto/top_app_usage_dto.dart';
import '../dto/trend_point_dto.dart';
import '../dto/win_entry_dto.dart';
import 'home_datasource.dart';

/// Local cache for the Beranda feed.
///
/// Not wired in iteration 1 (the mock is the source of truth), but the shape
/// is here so "show yesterday's numbers instantly, refresh in the background"
/// is a repository change rather than a new layer.
class HomeLocalDatasource implements HomeDatasource {
  HomeLocalDatasource(this._prefs);

  final SharedPreferences _prefs;

  static const _summaryKey = '${PrefKeys.mockSeedInitialised}.home.summary';
  static const _periodsKey = '${PrefKeys.mockSeedInitialised}.home.periods';
  static const _trendKey = '${PrefKeys.mockSeedInitialised}.home.trend';
  static const _topAppsKey = '${PrefKeys.mockSeedInitialised}.home.top_apps';
  static const _winsKey = '${PrefKeys.mockSeedInitialised}.home.wins';

  @override
  Future<DailySummaryDto> fetchDailySummary() async {
    final raw = _prefs.getString(_summaryKey);
    if (raw == null) throw StateError('No cached daily summary');
    return DailySummaryDto.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> cacheDailySummary(DailySummaryDto dto) async {
    await _prefs.setString(_summaryKey, jsonEncode(dto.toJson()));
  }

  @override
  Future<PeriodBreakdownDto> fetchPeriodBreakdown() async {
    final raw = _prefs.getString(_periodsKey);
    if (raw == null) throw StateError('No cached period breakdown');
    return PeriodBreakdownDto.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> cachePeriodBreakdown(PeriodBreakdownDto dto) async {
    await _prefs.setString(_periodsKey, jsonEncode(dto.toJson()));
  }

  @override
  Future<List<TrendPointDto>> fetchTrend({required int days}) async {
    final raw = _prefs.getString(_trendKey);
    if (raw == null) throw StateError('No cached trend');
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TrendPointDto.fromJson(e as Map<String, dynamic>))
        .take(days)
        .toList(growable: false);
  }

  Future<void> cacheTrend(List<TrendPointDto> points) async {
    await _prefs.setString(
      _trendKey,
      jsonEncode(points.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<List<TopAppUsageDto>> fetchTopApps({required int count}) async {
    final raw = _prefs.getString(_topAppsKey);
    if (raw == null) throw StateError('No cached top apps');
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TopAppUsageDto.fromJson(e as Map<String, dynamic>))
        .take(count)
        .toList(growable: false);
  }

  Future<void> cacheTopApps(List<TopAppUsageDto> apps) async {
    await _prefs.setString(
      _topAppsKey,
      jsonEncode(apps.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<List<WinEntryDto>> fetchTodaysWins() async {
    final raw = _prefs.getString(_winsKey);
    if (raw == null) throw StateError('No cached wins');
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => WinEntryDto.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> cacheWins(List<WinEntryDto> wins) async {
    await _prefs.setString(
      _winsKey,
      jsonEncode(wins.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<AriaMessageDto> fetchCurrentMessage() async =>
      throw StateError('ARIA messages are never cached locally');

  @override
  Future<AriaMessageDto> sendReply(String userMessage) async =>
      throw StateError('Replies require a network round trip');
}
