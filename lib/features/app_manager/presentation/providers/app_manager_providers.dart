import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/feature_flags.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../data/datasources/app_manager_local_datasource.dart';
import '../../data/datasources/usage_stats_android_source.dart';
import '../../data/datasources/usage_stats_mock_source.dart';
import '../../data/datasources/usage_stats_source.dart';
import '../../data/repositories/app_manager_repository_impl.dart';
import '../../data/repositories/usage_stats_repository_impl.dart';
import '../../domain/entities/limit_enforcement.dart';
import '../../domain/entities/managed_app.dart';
import '../../domain/repositories/app_manager_repository.dart';
import '../../domain/repositories/usage_stats_repository.dart';
import '../../domain/usecases/get_managed_apps.dart';
import '../../domain/usecases/set_daily_limit.dart';
import '../../domain/usecases/toggle_app_limit.dart';

// -----------------------------------------------------------------------------
// Data sources
// -----------------------------------------------------------------------------

/// The switch between fake and real usage data.
///
/// When the Android integration lands, this provider returns
/// `UsageStatsAndroidSource()` and nothing above it changes.
final usageStatsSourceProvider = Provider<UsageStatsSource>((ref) {
  if (FeatureFlags.useMockData) {
    return UsageStatsMockSource();
  }
  return const UsageStatsAndroidSource();
});

final appManagerLocalDatasourceProvider = Provider<AppManagerLocalDatasource>(
  (ref) => AppManagerLocalDatasource(ref.watch(sharedPreferencesProvider)),
);

// -----------------------------------------------------------------------------
// Repositories
// -----------------------------------------------------------------------------

final appManagerRepositoryProvider = Provider<AppManagerRepository>(
  (ref) => AppManagerRepositoryImpl(
    ref.watch(usageStatsSourceProvider),
    ref.watch(appManagerLocalDatasourceProvider),
  ),
);

final usageStatsRepositoryProvider = Provider<UsageStatsRepository>(
  (ref) => UsageStatsRepositoryImpl(ref.watch(usageStatsSourceProvider)),
);

// -----------------------------------------------------------------------------
// Use cases
// -----------------------------------------------------------------------------

final getManagedAppsProvider = Provider<GetManagedApps>(
  (ref) => GetManagedApps(ref.watch(appManagerRepositoryProvider)),
);

final setDailyLimitProvider = Provider<SetDailyLimit>(
  (ref) => SetDailyLimit(ref.watch(appManagerRepositoryProvider)),
);

final toggleAppLimitProvider = Provider<ToggleAppLimit>(
  (ref) => ToggleAppLimit(ref.watch(appManagerRepositoryProvider)),
);

// -----------------------------------------------------------------------------
// Screen state
// -----------------------------------------------------------------------------

/// The App Manager list.
///
/// An [AsyncNotifier] rather than a [FutureProvider] because the screen mutates
/// the data (save a limit, toggle one off) and needs to reflect the change
/// without a full refetch flash.
class ManagedAppsNotifier extends AsyncNotifier<List<ManagedApp>> {
  @override
  Future<List<ManagedApp>> build() async {
    final result = await ref.watch(getManagedAppsProvider)();
    return result.when(ok: (apps) => apps, err: (failure) => throw failure);
  }

  /// Saves a quota for one app and refreshes the row in place.
  Future<Failure?> setLimit({
    required String packageName,
    required Duration quota,
    bool enabled = true,
    LimitEnforcement enforcement = LimitEnforcement.breathe,
  }) async {
    final usecase = ref.read(setDailyLimitProvider);
    final result = await usecase(
      packageName: packageName,
      quota: quota,
      enabled: enabled,
      enforcement: enforcement,
    );

    return result.when(
      ok: (_) async {
        await _refresh();
        return null;
      },
      err: (failure) async => failure,
    );
  }

  /// Turns a limit on or off without changing its quota.
  Future<Failure?> setEnabled(String packageName, bool enabled) async {
    final usecase = ref.read(toggleAppLimitProvider);
    final result = await usecase(packageName: packageName, enabled: enabled);

    return result.when(
      ok: (_) async {
        await _refresh();
        return null;
      },
      err: (failure) async => failure,
    );
  }

  /// Removes a limit entirely.
  Future<Failure?> removeLimit(String packageName) async {
    final result = await ref
        .read(appManagerRepositoryProvider)
        .removeLimit(packageName);

    return result.when(
      ok: (_) async {
        await _refresh();
        return null;
      },
      err: (failure) async => failure,
    );
  }

  /// Re-reads the list, keeping the previous data visible while loading so the
  /// list doesn't collapse to a skeleton on every edit.
  Future<void> _refresh() async {
    state = await AsyncValue.guard(build);
  }
}

final managedAppsProvider =
    AsyncNotifierProvider<ManagedAppsNotifier, List<ManagedApp>>(
      ManagedAppsNotifier.new,
    );
