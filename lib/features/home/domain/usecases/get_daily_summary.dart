import '../../../../core/error/result.dart';
import '../entities/daily_summary.dart';
import '../repositories/home_repository.dart';

/// Loads the headline daily numbers for the top of Beranda.
class GetDailySummary {
  const GetDailySummary(this._repository);

  final HomeRepository _repository;

  Future<Result<DailySummary>> call() => _repository.getDailySummary();
}
