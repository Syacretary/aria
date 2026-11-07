import '../../domain/entities/permission_status.dart';
import 'permission_source.dart';

/// Fake permission state for iteration 1.
///
/// Usage access reads as granted (so Beranda has data) while the others start
/// denied — that mix is what the real first-run experience looks like, and it
/// means the Settings screen shows both states out of the box.
class PermissionMockSource implements PermissionSource {
  PermissionMockSource({Map<AppPermission, PermissionState>? initial})
    : _states = {
        AppPermission.usageAccess: PermissionState.granted,
        AppPermission.notifications: PermissionState.denied,
        AppPermission.overlay: PermissionState.denied,
        AppPermission.batteryExemption: PermissionState.restricted,
        ...?initial,
      };

  final Map<AppPermission, PermissionState> _states;

  @override
  Future<Map<AppPermission, PermissionState>> states() async => Map.of(_states);

  @override
  Future<void> request(AppPermission permission) async {
    // Simulate the user granting it in the system UI. A restricted permission
    // stays restricted: on a real device some of these genuinely cannot be
    // granted, and the UI needs to handle that honestly.
    if (_states[permission] == PermissionState.restricted) return;
    _states[permission] = PermissionState.granted;
  }
}
