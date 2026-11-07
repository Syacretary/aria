import '../../../../core/companion/aria_tone.dart';
import '../../../../core/error/result.dart';
import '../entities/app_settings.dart';
import '../entities/permission_status.dart';

/// Contract for reading and writing user preferences and querying the OS for
/// permission state.
abstract interface class SettingsRepository {
  Future<Result<AppSettings>> getSettings();

  /// Applies a partial update. Only the provided fields change.
  Future<Result<AppSettings>> updateSettings({
    AriaTone? tone,
    Duration? dailyTarget,
    bool? hapticsEnabled,
    bool? quietHoursEnabled,
    Duration? quietHoursFrom,
    Duration? quietHoursUntil,
    bool? maskAppNames,
  });

  /// Current grant state of every permission ARIA cares about.
  Future<Result<Map<AppPermission, PermissionState>>> getPermissionStates();

  /// Asks the OS to grant [permission]. For permissions that require a manual
  /// visit, opens the relevant settings screen instead.
  Future<Result<void>> requestPermission(AppPermission permission);

  /// Clears all locally stored ARIA data.
  Future<Result<void>> clearAllData();
}
