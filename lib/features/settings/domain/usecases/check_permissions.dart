import '../../../../core/error/result.dart';
import '../entities/permission_status.dart';
import '../repositories/settings_repository.dart';

/// Reads permission states and requests grants.
///
/// Kept separate from [UpdateSettings] because permissions live in the OS, not
/// in ARIA's storage — different failure modes, different callers.
class CheckPermissions {
  const CheckPermissions(this._repository);

  final SettingsRepository _repository;

  Future<Result<Map<AppPermission, PermissionState>>> call() =>
      _repository.getPermissionStates();

  /// Convenience for gating a feature: are the permissions it needs granted?
  Future<bool> areGranted(List<AppPermission> required) async {
    final result = await _repository.getPermissionStates();
    return result.when(
      ok: (states) => required.every(
        (permission) => states[permission]?.isGranted ?? false,
      ),
      err: (_) => false,
    );
  }

  Future<Result<void>> request(AppPermission permission) =>
      _repository.requestPermission(permission);
}
