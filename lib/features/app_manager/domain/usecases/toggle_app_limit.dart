import '../../../../core/error/result.dart';
import '../repositories/app_manager_repository.dart';

/// Enables or disables a limit without discarding its configuration.
///
/// Separate from [SetDailyLimit] so toggling a switch doesn't require the UI to
/// know the current quota.
class ToggleAppLimit {
  const ToggleAppLimit(this._repository);

  final AppManagerRepository _repository;

  Future<Result<void>> call({
    required String packageName,
    required bool enabled,
  }) => _repository.setLimitEnabled(packageName, enabled);
}
