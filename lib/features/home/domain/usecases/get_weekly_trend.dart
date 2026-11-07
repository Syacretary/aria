import '../../../../core/config/app_config.dart';
import '../../../../core/error/result.dart';
import '../entities/trend_point.dart';
import '../repositories/home_repository.dart';

/// Loads the screen-time trend, defaulting to the 7-day window.
class GetWeeklyTrend {
  const GetWeeklyTrend(this._repository);

  final HomeRepository _repository;

  Future<Result<List<TrendPoint>>> call({
    int days = AppConfig.trendWindowDays,
  }) => _repository.getTrend(days: days);
}
