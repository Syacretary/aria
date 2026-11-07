import '../../../../core/error/result.dart';
import '../repositories/usage_stats_repository.dart';

/// Returns total screen time for a single app today.
class GetTodayUsage {
  const GetTodayUsage(this._repository);

  final UsageStatsRepository _repository;

  Future<Result<Duration>> call(String packageName) async {
    final result = await _repository.getScreenTimeByApp(day: DateTime.now());
    return result.map((byApp) => byApp[packageName] ?? Duration.zero);
  }
}
