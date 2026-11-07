import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/app_limit.dart';
import '../entities/limit_enforcement.dart';
import '../repositories/app_manager_repository.dart';

/// Saves a daily limit for one app.
///
/// Validates the quota here so an impossible value (zero or negative) can
/// never reach storage, regardless of which UI triggered it.
class SetDailyLimit {
  const SetDailyLimit(this._repository);

  final AppManagerRepository _repository;

  Future<Result<void>> call({
    required String packageName,
    required Duration quota,
    bool enabled = true,
    LimitEnforcement enforcement = LimitEnforcement.breathe,
  }) {
    if (quota.inMinutes < _minimumMinutes) {
      return Future.value(
        const Err(NotFoundFailure('Batas harian minimal 1 menit.')),
      );
    }
    return _repository.setLimit(
      AppLimit(
        packageName: packageName,
        dailyQuota: quota,
        enabled: enabled,
        enforcement: enforcement,
      ),
    );
  }

  static const int _minimumMinutes = 1;
}
