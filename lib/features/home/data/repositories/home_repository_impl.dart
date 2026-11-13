import '../../../../core/companion/aria_tone.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/aria_message.dart';
import '../../domain/entities/daily_summary.dart';
import '../../domain/entities/period_stats.dart';
import '../../domain/entities/top_app_usage.dart';
import '../../domain/entities/trend_point.dart';
import '../../domain/entities/win_entry.dart';
import '../aria_llm_service.dart';
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
  AriaCompanionRepositoryImpl(this._datasource, this._llm);

  final HomeDatasource _datasource;
  final AriaLlmService _llm;
  final List<Map<String, String>> _conversation = [];

  @override
  Future<Result<AriaMessage>> getCurrentMessage() => _guard(() async {
    final local = HomeMappers.toAriaMessage(
      await _datasource.fetchCurrentMessage(),
    );
    if (!_llm.enabled) return local;
    try {
      final text = await _llm.reply(
        'Buat satu pesan singkat untuk beranda berdasarkan konteks pengguna. Pilih saran praktis, apresiasi, atau refleksi yang paling sesuai. Jangan mengulang pesan generik.',
      );
      return _withText(local, text);
    } on Object {
      // Keep Beranda useful if the provider is offline or misconfigured.
      return local;
    }
  });

  @override
  Future<Result<AriaMessage>> reply(String userMessage) => _guard(() async {
    if (_llm.enabled) {
      final text = await _llm.reply(
        userMessage,
        conversation: List.unmodifiable(_conversation),
      );
      _conversation
        ..add({'role': 'user', 'content': userMessage})
        ..add({'role': 'assistant', 'content': text});
      if (_conversation.length > 10) {
        _conversation.removeRange(0, _conversation.length - 10);
      }
      return _withText(
        HomeMappers.toAriaMessage(await _datasource.fetchCurrentMessage()),
        text,
      );
    }
    return HomeMappers.toAriaMessage(await _datasource.sendReply(userMessage));
  });

  @override
  Future<Result<void>> setTone(AriaTone tone) async => const Ok<void>(null);

  AriaMessage _withText(AriaMessage message, String text) => AriaMessage(
    id: message.id,
    text: text,
    createdAt: message.createdAt,
    action: message.action,
    actionLabel: message.actionLabel,
    tone: message.tone,
  );
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
    PlatformExceptionWrapper(message: final message) => PlatformFailure(
      message,
    ),
    StateError(message: final message) => NotFoundFailure(message),
    _ => const UnknownFailure('Terjadi kesalahan saat memuat data.'),
  };
}
