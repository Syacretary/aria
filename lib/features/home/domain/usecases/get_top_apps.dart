import '../../../../core/config/app_config.dart';
import '../../../../core/error/result.dart';
import '../entities/top_app_usage.dart';
import '../repositories/home_repository.dart';

/// Loads the top-N most-used apps, defaulting to the three shown on Beranda.
class GetTopApps {
  const GetTopApps(this._repository);

  final HomeRepository _repository;

  Future<Result<List<TopAppUsage>>> call({
    int count = AppConfig.topAppsCount,
  }) => _repository.getTopApps(count: count);
}
