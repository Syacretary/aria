import '../../../../core/error/result.dart';
import '../entities/win_entry.dart';
import '../repositories/home_repository.dart';

/// Loads the accomplishments logged today.
class GetTodaysWins {
  const GetTodaysWins(this._repository);

  final HomeRepository _repository;

  Future<Result<List<WinEntry>>> call() => _repository.getTodaysWins();
}
