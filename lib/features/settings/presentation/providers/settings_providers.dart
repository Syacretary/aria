import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/companion/aria_tone.dart';
import '../../../../core/config/feature_flags.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../data/datasources/permission_android_source.dart';
import '../../data/datasources/permission_mock_source.dart';
import '../../data/datasources/permission_source.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/permission_status.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/check_permissions.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_settings.dart';

// -----------------------------------------------------------------------------
// Data sources
// -----------------------------------------------------------------------------

final permissionSourceProvider = Provider<PermissionSource>((ref) {
  if (FeatureFlags.useMockData) return PermissionMockSource();
  return const PermissionAndroidSource();
});

final settingsLocalDatasourceProvider = Provider<SettingsLocalDatasource>(
  (ref) => SettingsLocalDatasource(ref.watch(sharedPreferencesProvider)),
);

// -----------------------------------------------------------------------------
// Repository + use cases
// -----------------------------------------------------------------------------

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(
    ref.watch(settingsLocalDatasourceProvider),
    ref.watch(permissionSourceProvider),
  ),
);

final getSettingsProvider = Provider<GetSettings>(
  (ref) => GetSettings(ref.watch(settingsRepositoryProvider)),
);

final updateSettingsProvider = Provider<UpdateSettings>(
  (ref) => UpdateSettings(ref.watch(settingsRepositoryProvider)),
);

final checkPermissionsProvider = Provider<CheckPermissions>(
  (ref) => CheckPermissions(ref.watch(settingsRepositoryProvider)),
);

// -----------------------------------------------------------------------------
// Screen state
// -----------------------------------------------------------------------------

/// User preferences, mutable from the Settings screen.
///
/// An [AsyncNotifier] so each toggle can save and reflect the new value
/// immediately, without the previous values disappearing while it writes.
class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final result = await ref.watch(getSettingsProvider)();
    return result.when(
      ok: (settings) => settings,
      err: (failure) => throw failure,
    );
  }

  /// Applies a partial update, optimistically showing the change.
  ///
  /// Optimism matters here: a switch that takes 30ms to flip feels broken. On
  /// failure the previous state is restored and the failure is returned.
  Future<Failure?> save({
    AriaTone? tone,
    Duration? dailyTarget,
    bool? hapticsEnabled,
    bool? quietHoursEnabled,
    Duration? quietHoursFrom,
    Duration? quietHoursUntil,
    bool? maskAppNames,
  }) async {
    final AppSettings? previous = state.hasValue ? state.requireValue : null;
    if (previous != null) {
      state = AsyncData(
        previous.copyWith(
          tone: tone,
          dailyTarget: dailyTarget,
          hapticsEnabled: hapticsEnabled,
          quietHoursEnabled: quietHoursEnabled,
          quietHoursFrom: quietHoursFrom,
          quietHoursUntil: quietHoursUntil,
          maskAppNames: maskAppNames,
        ),
      );
    }

    final result = await ref.read(updateSettingsProvider)(
      tone: tone,
      dailyTarget: dailyTarget,
      hapticsEnabled: hapticsEnabled,
      quietHoursEnabled: quietHoursEnabled,
      quietHoursFrom: quietHoursFrom,
      quietHoursUntil: quietHoursUntil,
      maskAppNames: maskAppNames,
    );

    return result.when(
      ok: (settings) {
        state = AsyncData(settings);
        return null;
      },
      err: (failure) {
        if (previous != null) state = AsyncData(previous);
        return failure;
      },
    );
  }

  /// Wipes stored preferences and returns them to defaults.
  Future<Failure?> clearAllData() async {
    final result = await ref.read(settingsRepositoryProvider).clearAllData();
    return result.when(
      ok: (_) {
        state = const AsyncData(AppSettings.defaults);
        return null;
      },
      err: (failure) => failure,
    );
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

/// Permission states, refreshed on demand (e.g. when returning from Android
/// Settings).
final permissionStatesProvider =
    FutureProvider<Map<AppPermission, PermissionState>>((ref) async {
      final result = await ref.watch(checkPermissionsProvider)();
      return result.when(
        ok: (states) => states,
        err: (failure) => throw failure,
      );
    });
