import '../../../../core/companion/aria_tone.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/permission_status.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/permission_source.dart';
import '../datasources/settings_local_datasource.dart';

/// Settings storage plus OS permission queries.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._local, this._permissions);

  final SettingsLocalDatasource _local;
  final PermissionSource _permissions;

  @override
  Future<Result<AppSettings>> getSettings() async {
    try {
      return Ok(_local.read());
    } on Object {
      // A read failure still yields usable defaults rather than blocking the
      // Settings screen entirely.
      return const Ok(AppSettings.defaults);
    }
  }

  @override
  Future<Result<AppSettings>> updateSettings({
    AriaTone? tone,
    Duration? dailyTarget,
    bool? hapticsEnabled,
    bool? quietHoursEnabled,
    Duration? quietHoursFrom,
    Duration? quietHoursUntil,
    bool? maskAppNames,
  }) async {
    try {
      final current = _local.read();
      final updated = current.copyWith(
        tone: tone,
        dailyTarget: dailyTarget,
        hapticsEnabled: hapticsEnabled,
        quietHoursEnabled: quietHoursEnabled,
        quietHoursFrom: quietHoursFrom,
        quietHoursUntil: quietHoursUntil,
        maskAppNames: maskAppNames,
      );
      await _local.write(updated);
      return Ok(updated);
    } on Object {
      return const Err(StorageFailure('Pengaturan gagal disimpan.'));
    }
  }

  @override
  Future<Result<Map<AppPermission, PermissionState>>>
  getPermissionStates() async {
    try {
      return Ok(await _permissions.states());
    } on Object {
      return const Err(PermissionFailure('Status izin tidak dapat dibaca.'));
    }
  }

  @override
  Future<Result<void>> requestPermission(AppPermission permission) async {
    try {
      await _permissions.request(permission);
      return const Ok<void>(null);
    } on UnimplementedError {
      return const Err(
        PermissionFailure('Izin ini belum didukung di versi ini.'),
      );
    } on Object {
      return const Err(PermissionFailure('Permintaan izin gagal.'));
    }
  }

  @override
  Future<Result<void>> clearAllData() async {
    try {
      await _local.clear();
      return const Ok<void>(null);
    } on Object {
      return const Err(StorageFailure('Data lokal gagal dihapus.'));
    }
  }
}
