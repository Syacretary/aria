import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../dto/aria_message_dto.dart';
import '../dto/daily_summary_dto.dart';
import '../dto/period_stats_dto.dart';
import '../dto/top_app_usage_dto.dart';
import '../dto/trend_point_dto.dart';
import '../dto/win_entry_dto.dart';
import 'home_datasource.dart';

/// Backend implementation of [HomeDatasource].
///
/// Present but unused in iteration 1: `FeatureFlags.useMockData` keeps the mock
/// in place. The endpoint mapping is written out anyway so the switch is a
/// provider override rather than a research task.
class HomeRemoteDatasource implements HomeDatasource {
  HomeRemoteDatasource(this._client);

  final ApiClient _client;

  @override
  Future<DailySummaryDto> fetchDailySummary() async {
    final json = await _client.get('/v1/home/daily-summary');
    return _parse(json, DailySummaryDto.fromJson);
  }

  @override
  Future<PeriodBreakdownDto> fetchPeriodBreakdown() async {
    final json = await _client.get('/v1/home/period-breakdown');
    return _parse(json, PeriodBreakdownDto.fromJson);
  }

  @override
  Future<List<TrendPointDto>> fetchTrend({required int days}) async {
    final json = await _client.get('/v1/home/trend', query: {'days': days});
    return _parseList(json, TrendPointDto.fromJson);
  }

  @override
  Future<List<TopAppUsageDto>> fetchTopApps({required int count}) async {
    final json = await _client.get(
      '/v1/home/top-apps',
      query: {'count': count},
    );
    return _parseList(json, TopAppUsageDto.fromJson);
  }

  @override
  Future<List<WinEntryDto>> fetchTodaysWins() async {
    final json = await _client.get('/v1/home/wins');
    return _parseList(json, WinEntryDto.fromJson);
  }

  @override
  Future<AriaMessageDto> fetchCurrentMessage() async {
    final json = await _client.get('/v1/companion/message');
    return _parse(json, AriaMessageDto.fromJson);
  }

  @override
  Future<AriaMessageDto> sendReply(String userMessage) async {
    final json = await _client.post(
      '/v1/companion/reply',
      body: {'message': userMessage},
    );
    return _parse(json, AriaMessageDto.fromJson);
  }

  T _parse<T>(
    Map<String, Object?> json,
    T Function(Map<String, dynamic>) from,
  ) {
    try {
      return from(Map<String, dynamic>.from(json));
    } on Object catch (error) {
      throw ParseException('Gagal membaca respons server.', cause: error);
    }
  }

  List<T> _parseList<T>(
    Map<String, Object?> json,
    T Function(Map<String, dynamic>) from,
  ) {
    final items = json['items'];
    if (items is! List) {
      throw const ParseException('Respons server tidak berisi daftar.');
    }
    return items
        .map((e) => from(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }
}
