import 'package:flutter/services.dart';

import '../../domain/entities/permission_status.dart';
import '../datasources/permission_source.dart';

/// Android implementation of [PermissionSource].
///
/// Uses Android's Settings pages for special permissions and the system dialog
/// for notifications. The screen re-reads status after a user returns.
class PermissionAndroidSource implements PermissionSource {
  const PermissionAndroidSource();

  static const _channel = MethodChannel('com.aria.aria/permissions');

  @override
  Future<Map<AppPermission, PermissionState>> states() async {
    final raw = await _channel.invokeMapMethod<String, dynamic>('states') ?? {};
    return {
      for (final permission in AppPermission.values)
        permission: switch (raw[permission.name]) {
          'granted' => PermissionState.granted,
          'restricted' => PermissionState.restricted,
          _ => PermissionState.denied,
        },
    };
  }

  @override
  Future<void> request(AppPermission permission) =>
      _channel.invokeMethod<void>('request', {'permission': permission.name});
}
