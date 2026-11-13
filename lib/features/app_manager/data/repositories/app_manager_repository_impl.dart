import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/app_limit.dart';
import '../../domain/entities/managed_app.dart';
import '../../domain/repositories/app_manager_repository.dart';
import '../datasources/app_manager_local_datasource.dart';
import '../datasources/usage_stats_source.dart';
import '../dto/app_limit_dto.dart';
import '../mappers/app_manager_mappers.dart';

/// Joins two independent sources into the row model the UI renders:
///
/// - **what the system knows** — installed app names, today's usage, session
///   counts (from [UsageStatsSource]);
/// - **what the user configured** — limits (from local storage).
///
/// Keeping them separate means a limit can be edited while the usage source is
/// unavailable, and vice versa.
class AppManagerRepositoryImpl implements AppManagerRepository {
  const AppManagerRepositoryImpl(this._usageSource, this._local);

  final UsageStatsSource _usageSource;
  final AppManagerLocalDatasource _local;

  /// Metadata for curated social apps; Android reports only those actually
  /// installed, together with their launcher labels and icons.
  static const List<ManagedApp> _catalogue = [
    ManagedApp(
      packageName: 'com.zhiliaoapp.musically',
      appName: 'TikTok',
      usedToday: Duration.zero,
      sessionCount: 0,
      category: AppCategory.video,
    ),
    ManagedApp(
      packageName: 'com.instagram.android',
      appName: 'Instagram',
      usedToday: Duration.zero,
      sessionCount: 0,
      category: AppCategory.social,
    ),
    ManagedApp(
      packageName: 'com.google.android.youtube',
      appName: 'YouTube',
      usedToday: Duration.zero,
      sessionCount: 0,
      category: AppCategory.video,
    ),
    ManagedApp(
      packageName: 'com.facebook.katana',
      appName: 'Facebook',
      usedToday: Duration.zero,
      sessionCount: 0,
      category: AppCategory.social,
    ),
    ManagedApp(
      packageName: 'com.twitter.android',
      appName: 'X',
      usedToday: Duration.zero,
      sessionCount: 0,
      category: AppCategory.social,
    ),
    ManagedApp(
      packageName: 'com.reddit.frontpage',
      appName: 'Reddit',
      usedToday: Duration.zero,
      sessionCount: 0,
      category: AppCategory.social,
    ),
    ManagedApp(
      packageName: 'com.snapchat.android',
      appName: 'Snapchat',
      usedToday: Duration.zero,
      sessionCount: 0,
      category: AppCategory.social,
    ),
    ManagedApp(
      packageName: 'com.pinterest',
      appName: 'Pinterest',
      usedToday: Duration.zero,
      sessionCount: 0,
      category: AppCategory.social,
    ),
    ManagedApp(
      packageName: 'com.instagram.barcelona',
      appName: 'Threads',
      usedToday: Duration.zero,
      sessionCount: 0,
      category: AppCategory.social,
    ),
    ManagedApp(
      packageName: 'com.ss.android.ugc.trill',
      appName: 'TikTok',
      usedToday: Duration.zero,
      sessionCount: 0,
      category: AppCategory.video,
    ),
  ];

  @override
  Future<Result<List<ManagedApp>>> getManagedApps() async {
    try {
      final today = DateTime.now();
      final installed = await _usageSource.installedSocialApps();
      final screenTime = await _usageSource.screenTimeByApp(day: today);
      final launches = await _usageSource.launchCounts(day: today);
      final limits = await _local.readLimits();

      final templates = {for (final app in _catalogue) app.packageName: app};
      final apps =
          installed
              .map((installedApp) {
                final template = templates[installedApp.packageName];
                final limitDto = limits[installedApp.packageName];
                return ManagedApp(
                  packageName: installedApp.packageName,
                  appName: installedApp.appName,
                  usedToday:
                      screenTime[installedApp.packageName] ?? Duration.zero,
                  sessionCount: launches[installedApp.packageName] ?? 0,
                  limit: limitDto == null
                      ? null
                      : AppManagerMappers.toAppLimit(limitDto),
                  category: template?.category ?? AppCategory.social,
                  iconPng: installedApp.iconPng,
                );
              })
              .toList(growable: false)
            // Busiest first: the apps competing for attention belong at the top.
            ..sort((a, b) => b.usedToday.compareTo(a.usedToday));

      return Ok(apps);
    } on Object catch (error) {
      return Err(_mapError(error));
    }
  }

  @override
  Future<Result<ManagedApp>> getApp(String packageName) async {
    final result = await getManagedApps();
    return result.when(
      ok: (apps) {
        final match = apps.where((a) => a.packageName == packageName);
        if (match.isEmpty) {
          return const Err(NotFoundFailure('Aplikasi tidak ditemukan.'));
        }
        return Ok(match.first);
      },
      err: (failure) => Err(failure),
    );
  }

  @override
  Future<Result<void>> setLimit(AppLimit limit) => _mutate((limits) {
    limits[limit.packageName] = AppManagerMappers.toAppLimitDto(limit);
  });

  @override
  Future<Result<void>> removeLimit(String packageName) =>
      _mutate((limits) => limits.remove(packageName));

  @override
  Future<Result<void>> setLimitEnabled(String packageName, bool enabled) =>
      _mutate((limits) {
        final existing = limits[packageName];
        if (existing == null) return;
        limits[packageName] = existing.copyWith(enabled: enabled);
      });

  /// Read-modify-write helper so every mutation has identical error handling.
  Future<Result<void>> _mutate(
    void Function(Map<String, AppLimitDto>) change,
  ) async {
    try {
      final limits = Map<String, AppLimitDto>.from(await _local.readLimits());
      change(limits);
      await _local.writeLimits(limits);
      return const Ok<void>(null);
    } on Object catch (error) {
      return Err(_mapError(error));
    }
  }

  Failure _mapError(Object error) => switch (error) {
    Failure() => error,
    _ => const StorageFailure('Perubahan batas gagal disimpan.'),
  };
}
