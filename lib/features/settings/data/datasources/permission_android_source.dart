import '../../domain/entities/permission_status.dart';
import '../datasources/permission_source.dart';

/// Android implementation of [PermissionSource].
///
/// Not wired in iteration 1. What it needs:
///
/// 1. `permission_handler` for notifications and overlay; `request()` maps to
///    `Permission.notification.request()` and `Permission.systemAlertWindow`.
/// 2. Usage access has no runtime request — it requires firing
///    `Settings.ACTION_USAGE_ACCESS_SETTINGS`.
/// 3. Battery exemption likewise: `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`.
/// 4. Re-read state on `AppLifecycleState.resumed`, since the user grants these
///    in a different app and returns.
class PermissionAndroidSource implements PermissionSource {
  const PermissionAndroidSource();

  @override
  Future<Map<AppPermission, PermissionState>> states() async => {
    for (final permission in AppPermission.values)
      permission: PermissionState.denied,
  };

  @override
  Future<void> request(AppPermission permission) async {
    throw UnimplementedError(
      'Izin sistem belum diimplementasikan: ${permission.name}',
    );
  }
}
