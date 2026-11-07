import 'package:aria/features/app_manager/data/datasources/app_manager_local_datasource.dart';
import 'package:aria/features/app_manager/data/datasources/usage_stats_mock_source.dart';
import 'package:aria/features/app_manager/data/repositories/app_manager_repository_impl.dart';
import 'package:aria/features/app_manager/domain/entities/app_limit.dart';
import 'package:aria/features/app_manager/domain/entities/limit_enforcement.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppManagerRepositoryImpl', () {
    late SharedPreferences prefs;
    late AppManagerLocalDatasource localDatasource;
    late UsageStatsMockSource usageSource;
    late AppManagerRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      localDatasource = AppManagerLocalDatasource(prefs);
      usageSource = UsageStatsMockSource(seed: 42);
      repository = AppManagerRepositoryImpl(usageSource, localDatasource);
    });

    test(
      'getManagedApps returns apps sorted by screen time descending',
      () async {
        final result = await repository.getManagedApps();
        expect(result.isOk, isTrue);

        final apps = result.valueOrNull!;
        expect(apps, isNotEmpty);

        // Verify sorted descending
        for (var i = 0; i < apps.length - 1; i++) {
          expect(apps[i].usedToday >= apps[i + 1].usedToday, isTrue);
        }
      },
    );

    test('setLimit saves a new limit and updates managed app', () async {
      const pkg = 'com.zhiliaoapp.musically';
      const limit = AppLimit(
        packageName: pkg,
        dailyQuota: Duration(minutes: 60),
        enforcement: LimitEnforcement.block,
        enabled: true,
      );

      final setResult = await repository.setLimit(limit);
      expect(setResult.isOk, isTrue);

      final appsResult = await repository.getManagedApps();
      final apps = appsResult.valueOrNull!;
      final tiktok = apps.firstWhere((a) => a.packageName == pkg);

      expect(tiktok.hasLimit, isTrue);
      expect(tiktok.limit?.dailyQuota, const Duration(minutes: 60));
      expect(tiktok.limit?.enforcement, LimitEnforcement.block);
    });

    test('setLimitEnabled changes enabled status of a limit', () async {
      const pkg = 'com.instagram.android';
      const limit = AppLimit(
        packageName: pkg,
        dailyQuota: Duration(minutes: 45),
        enforcement: LimitEnforcement.breathe,
        enabled: true,
      );

      await repository.setLimit(limit);

      final toggleResult = await repository.setLimitEnabled(pkg, false);
      expect(toggleResult.isOk, isTrue);

      final appsResult = await repository.getManagedApps();
      final insta = appsResult.valueOrNull!.firstWhere(
        (a) => a.packageName == pkg,
      );
      expect(insta.limit?.enabled, isFalse);
    });

    test('removeLimit deletes configured limit', () async {
      const pkg = 'com.google.android.youtube';
      const limit = AppLimit(
        packageName: pkg,
        dailyQuota: Duration(minutes: 30),
        enforcement: LimitEnforcement.trackOnly,
        enabled: true,
      );

      await repository.setLimit(limit);
      var apps = (await repository.getManagedApps()).valueOrNull!;
      expect(apps.firstWhere((a) => a.packageName == pkg).hasLimit, isTrue);

      final removeResult = await repository.removeLimit(pkg);
      expect(removeResult.isOk, isTrue);

      apps = (await repository.getManagedApps()).valueOrNull!;
      expect(apps.firstWhere((a) => a.packageName == pkg).hasLimit, isFalse);
    });

    test('getApp returns the matching app with its usage and limits', () async {
      const pkg = 'com.zhiliaoapp.musically';
      final appResult = await repository.getApp(pkg);
      expect(appResult.isOk, isTrue);
      final app = appResult.valueOrNull!;
      expect(app.packageName, pkg);
      expect(app.appName, 'TikTok');
    });
  });
}
