import '../../../../core/error/result.dart';
import '../entities/period_stats.dart';
import '../repositories/home_repository.dart';

/// Loads the Harian/Mingguan/Bulanan social-app open counts.
class GetPeriodBreakdown {
  const GetPeriodBreakdown(this._repository);

  final HomeRepository _repository;

  Future<Result<PeriodBreakdown>> call() => _repository.getPeriodBreakdown();
}
