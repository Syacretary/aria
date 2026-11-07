import 'package:aria/core/companion/aria_tone.dart';
import 'package:aria/features/settings/data/datasources/permission_mock_source.dart';
import 'package:aria/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:aria/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:aria/features/settings/domain/entities/app_settings.dart';
import 'package:aria/features/settings/domain/entities/permission_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsRepositoryImpl', () {
    late SharedPreferences prefs;
    late SettingsLocalDatasource localDatasource;
    late PermissionMockSource permissionSource;
    late SettingsRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      localDatasource = SettingsLocalDatasource(prefs);
      permissionSource = PermissionMockSource();
      repository = SettingsRepositoryImpl(localDatasource, permissionSource);
    });

    test('getSettings returns defaults on fresh installation', () async {
      final result = await repository.getSettings();
      expect(result.isOk, isTrue);

      final settings = result.valueOrNull!;
      expect(settings, equals(AppSettings.defaults));
    });

    test('updateSettings modifies and persists settings', () async {
      final result = await repository.updateSettings(
        tone: AriaTone.firm,
        dailyTarget: const Duration(hours: 3),
        hapticsEnabled: false,
        maskAppNames: true,
      );

      expect(result.isOk, isTrue);
      final updated = result.valueOrNull!;
      expect(updated.tone, AriaTone.firm);
      expect(updated.dailyTarget, const Duration(hours: 3));
      expect(updated.hapticsEnabled, isFalse);
      expect(updated.maskAppNames, isTrue);

      // Verify persistence via a fresh read
      final freshResult = await repository.getSettings();
      expect(freshResult.valueOrNull, equals(updated));
    });

    test('getPermissionStates returns mapped permission status', () async {
      final result = await repository.getPermissionStates();
      expect(result.isOk, isTrue);

      final states = result.valueOrNull!;
      expect(states[AppPermission.usageAccess], PermissionState.granted);
      expect(states[AppPermission.notifications], PermissionState.denied);
    });

    test(
      'requestPermission grants simulated permission when not restricted',
      () async {
        final requestResult = await repository.requestPermission(
          AppPermission.notifications,
        );
        expect(requestResult.isOk, isTrue);

        final statesResult = await repository.getPermissionStates();
        expect(
          statesResult.valueOrNull![AppPermission.notifications],
          PermissionState.granted,
        );
      },
    );

    test('clearAllData wipes local settings', () async {
      await repository.updateSettings(tone: AriaTone.firm);
      final clearResult = await repository.clearAllData();
      expect(clearResult.isOk, isTrue);

      final fresh = (await repository.getSettings()).valueOrNull!;
      expect(fresh.tone, AppSettings.defaults.tone);
    });
  });
}
