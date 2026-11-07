import '../../../../core/error/result.dart';
import '../entities/managed_app.dart';
import '../repositories/app_manager_repository.dart';

/// Loads every governed app with its usage and limit.
class GetManagedApps {
  const GetManagedApps(this._repository);

  final AppManagerRepository _repository;

  Future<Result<List<ManagedApp>>> call() => _repository.getManagedApps();
}
