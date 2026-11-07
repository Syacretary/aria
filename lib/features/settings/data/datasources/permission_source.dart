import '../../domain/entities/permission_status.dart';

/// Platform boundary for OS permissions.
///
/// Permissions are the one thing ARIA cannot abstract away — the real
/// implementation will call `permission_handler` and the Android Settings
/// intents. The interface exists so the UI can be built and tested now.
abstract interface class PermissionSource {
  Future<Map<AppPermission, PermissionState>> states();

  /// Requests, or opens the relevant settings screen for permissions that
  /// cannot be granted from a dialog.
  Future<void> request(AppPermission permission);
}
