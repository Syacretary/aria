import 'package:aria/core/companion/aria_tone.dart';
import 'package:aria/features/home/data/datasources/home_datasource.dart';
import 'package:aria/features/home/data/datasources/home_mock_datasource.dart';
import 'package:aria/features/home/data/dto/aria_message_dto.dart';
import 'package:aria/features/home/data/dto/daily_summary_dto.dart';
import 'package:aria/features/home/data/dto/period_stats_dto.dart';
import 'package:aria/features/home/data/dto/top_app_usage_dto.dart';
import 'package:aria/features/home/data/dto/trend_point_dto.dart';
import 'package:aria/features/home/data/dto/win_entry_dto.dart';
import 'package:aria/features/home/data/repositories/home_repository_impl.dart';
import 'package:aria/features/home/domain/usecases/get_top_apps.dart';
import 'package:aria/features/home/domain/usecases/get_weekly_trend.dart';
import 'package:flutter_test/flutter_test.dart';

/// Datasource that always throws, to prove the repository's error boundary.
class _FailingDatasource implements HomeDatasource {
  @override
  Future<DailySummaryDto> fetchDailySummary() async =>
      throw StateError('offline');

  @override
  Future<AriaMessageDto> fetchCurrentMessage() async =>
      throw StateError('offline');

  @override
  Future<PeriodBreakdownDto> fetchPeriodBreakdown() async =>
      throw StateError('offline');

  @override
  Future<List<TopAppUsageDto>> fetchTopApps({required int count}) async =>
      throw StateError('offline');

  @override
  Future<List<TrendPointDto>> fetchTrend({required int days}) async =>
      throw StateError('offline');

  @override
  Future<List<WinEntryDto>> fetchTodaysWins() async =>
      throw StateError('offline');

  @override
  Future<AriaMessageDto> sendReply(String userMessage) async =>
      throw StateError('offline');
}

void main() {
  group('HomeRepositoryImpl with the mock datasource', () {
    late HomeRepositoryImpl repository;

    setUp(() {
      repository = HomeRepositoryImpl(
        HomeMockDatasource(now: DateTime(2026, 11, 7, 14, 30), seed: 1),
      );
    });

    test('maps the daily summary and computes deltas', () async {
      final result = await repository.getDailySummary();
      final summary = result.valueOrNull;

      expect(result.isOk, isTrue);
      expect(summary, isNotNull);
      expect(summary!.videosOpened, 47);
      expect(summary.videosOpenedYesterday, 68);
      // Fewer videos than yesterday is the good direction.
      expect(summary.isCalmerThanYesterday, isTrue);
      expect(summary.videoDeltaRatio, lessThan(0));
    });

    test('returns exactly three top apps by default', () async {
      final result = await repository.getTopApps(count: 3);
      expect(result.valueOrNull, hasLength(3));
      expect(result.valueOrNull!.first.appName, 'TikTok');
    });

    test('returns exactly seven trend points, oldest first', () async {
      final result = await repository.getTrend(days: 7);
      final points = result.valueOrNull!;

      expect(points, hasLength(7));
      expect(
        points.first.date.isBefore(points.last.date),
        isTrue,
        reason: 'the trend should read left-to-right',
      );
    });

    test(
      'derives average session from screen time and session count',
      () async {
        final result = await repository.getTopApps(count: 1);
        final tiktok = result.valueOrNull!.first;

        // 78 minutes across 21 sessions.
        expect(tiktok.averageSession.inMinutes, 3);
        expect(tiktok.sessionCount, 21);
      },
    );
  });

  group('HomeRepositoryImpl error boundary', () {
    test('converts a thrown StateError into a Failure', () async {
      final repository = HomeRepositoryImpl(_FailingDatasource());
      final result = await repository.getDailySummary();

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isNotNull);
    });
  });

  group('Use cases delegate to the repository', () {
    test('GetWeeklyTrend defaults to the seven-day window', () async {
      final repository = HomeRepositoryImpl(
        HomeMockDatasource(now: DateTime(2026, 11, 7), seed: 2),
      );

      final result = await GetWeeklyTrend(repository)();
      expect(result.valueOrNull, hasLength(7));
    });

    test('GetTopApps defaults to three rows', () async {
      final repository = HomeRepositoryImpl(
        HomeMockDatasource(now: DateTime(2026, 11, 7), seed: 3),
      );

      final result = await GetTopApps(repository)();
      expect(result.valueOrNull, hasLength(3));
    });
  });

  group('AriaCompanionRepositoryImpl', () {
    test('reply returns an ARIA message with no action', () async {
      final repository = AriaCompanionRepositoryImpl(
        HomeMockDatasource(now: DateTime(2026, 11, 7), seed: 4),
      );

      final result = await repository.reply('aku lelah');
      final message = result.valueOrNull;

      expect(message, isNotNull);
      expect(message!.hasAction, isFalse);
      expect(message.tone, AriaTone.gentle);
    });
  });
}
