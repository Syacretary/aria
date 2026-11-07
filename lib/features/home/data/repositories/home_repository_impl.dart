import '../../../../core/companion/aria_tone.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/aria_message.dart';
import '../../domain/entities/daily_summary.dart';
import '../../domain/entities/period_stats.dart';
import '../../domain/entities/top_app_usage.dart';
import '../../domain/entities/trend_point.dart';
import '../../domain/entities/win_entry.dart';
import '../../domain/repositories/aria_companion_repository.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_datasource.dart';
import '../mappers/home_mappers.dart';

/// Translates datasource exceptions into [Failure]s and DTOs into entities.
///
/// Every method has the same three-line shape on purpose: call, map, catch.
/// Consistency here means a new endpoint is never a place where error handling
/// gets quietly skipped.
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._datasource);

  final HomeDatasource _datasource;

  @override
  Future<Result<DailySummary>> getDailySummary() => _guard(
    () async =>
        HomeMappers.toDailySummary(await _datasource.fetchDailySummary()),
  );

  @override
  Future<Result<PeriodBreakdown>> getPeriodBreakdown() => _guard(
    () async =>
        HomeMappers.toPeriodBreakdown(await _datasource.fetchPeriodBreakdown()),
  );

  @override
  Future<Result<List<TrendPoint>>> getTrend({int days = 7}) => _guard(
    () async =>
        (await _datasource.fetchTrend(days: days))
            .map(HomeMappers.toTrendPoint)
            .toList(growable: false),
  );

  @override
  Future<Result<List<TopAppUsage>>> getTopApps({int count = 3}) => _guard(
    () async =>
        (await _datasource.fetchTopApps(count: count))
            .map(HomeMappers.toTopAppUsage)
            .toList(growable: false),
  );

  @override
  Future<Result<List<WinEntry>>> getTodaysWins() => _guard(
    () async => (await _datasource.fetchTodaysWins())
        .map(HomeMappers.toWinEntry)
        .toList(growable: false),
  );
}

/// Companion-message implementation, backed by the same datasource.
///
/// Kept as its own class because the chat sheet only needs this narrow
/// surface, and because it will move to a different backend first.
class AriaCompanionRepositoryImpl implements AriaCompanionRepository {
  const AriaCompanionRepositoryImpl(this._datasource);

  final HomeDatasource _datasource;

  @override
  Future<Result<AriaMessage>> getCurrentMessage() => _guard(
    () async =>
        HomeMappers.toAriaMessage(await _datasource.fetchCurrentMessage()),
  );

  @override
  Future<Result<AriaMessage>> reply(String userMessage) => _guard(
    () async =>
        HomeMappers.toAriaMessage(await _datasource.sendReply(userMessage)),
  );

  @override
  Future<Result<void>> setTone(AriaTone tone) async => const Ok<void>(null);
}

/// Shared error boundary. Anything thrown below the repository becomes a
/// [Failure], so the presentation layer only ever handles `Result`.
Future<Result<T>> _guard<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on Object catch (error, stack) {
    return Err(_mapError(error, stack));
  }
}

Failure _mapError(Object error, StackTrace stack) {
  return switch (error) {
    Failure() => error,
    StateError(message: final message) => NotFoundFailure(message),
    _ => const UnknownFailure('Terjadi kesalahan saat memuat data.'),
  };
}
