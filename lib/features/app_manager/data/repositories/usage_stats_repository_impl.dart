import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/usage_session.dart';
import '../../domain/repositories/usage_stats_repository.dart';
import '../datasources/usage_stats_source.dart';

/// Turns datasource exceptions into [Failure]s for the usage-stats boundary.
class UsageStatsRepositoryImpl implements UsageStatsRepository {
  const UsageStatsRepositoryImpl(this._source);

  final UsageStatsSource _source;

  @override
  Future<Result<Map<String, Duration>>> getScreenTimeByApp({
    required DateTime day,
  }) => _guard(() => _source.screenTimeByApp(day: day));

  @override
  Future<Result<Map<String, int>>> getLaunchCounts({required DateTime day}) =>
      _guard(() => _source.launchCounts(day: day));

  @override
  Future<Result<List<UsageSession>>> getSessions({required DateTime day}) =>
      _guard(() => _source.sessions(day: day));

  @override
  Future<Result<bool>> hasUsageAccess() => _guard(_source.hasUsageAccess);
}

Future<Result<T>> _guard<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on Object {
    return const Err(
      PlatformFailure('Data pemakaian tidak dapat dibaca di perangkat ini.'),
    );
  }
}
