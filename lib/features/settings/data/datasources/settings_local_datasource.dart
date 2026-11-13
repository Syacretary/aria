import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/companion/aria_tone.dart';
import '../../../../core/constants/pref_keys.dart';
import '../../domain/entities/app_settings.dart';

/// Persists [AppSettings] to SharedPreferences.
///
/// Scalar keys rather than a JSON blob: each preference is independently
/// readable, so a corrupt value for one setting can't take down the rest.
class SettingsLocalDatasource {
  SettingsLocalDatasource(this._prefs);

  final SharedPreferences _prefs;

  AppSettings read() {
    return AppSettings(
      tone: _toneFrom(_prefs.getString(PrefKeys.ariaTone)),
      dailyTarget: Duration(
        minutes:
            _prefs.getInt(PrefKeys.dailyTargetMinutes) ??
            AppSettings.defaults.dailyTarget.inMinutes,
      ),
      hapticsEnabled:
          _prefs.getBool(PrefKeys.hapticsEnabled) ??
          AppSettings.defaults.hapticsEnabled,
      quietHoursEnabled: _prefs.getBool(PrefKeys.quietHoursEnabled) ?? false,
      quietHoursFrom: Duration(
        minutes:
            _prefs.getInt(PrefKeys.quietHoursFrom) ??
            AppSettings.defaults.quietHoursFrom.inMinutes,
      ),
      quietHoursUntil: Duration(
        minutes:
            _prefs.getInt(PrefKeys.quietHoursUntil) ??
            AppSettings.defaults.quietHoursUntil.inMinutes,
      ),
      maskAppNames: _prefs.getBool(PrefKeys.maskAppNames) ?? false,
    );
  }

  Future<void> write(AppSettings settings) async {
    await _prefs.setString(PrefKeys.ariaTone, settings.tone.name);
    await _prefs.setInt(
      PrefKeys.dailyTargetMinutes,
      settings.dailyTarget.inMinutes,
    );
    await _prefs.setBool(PrefKeys.hapticsEnabled, settings.hapticsEnabled);
    await _prefs.setBool(
      PrefKeys.quietHoursEnabled,
      settings.quietHoursEnabled,
    );
    await _prefs.setInt(
      PrefKeys.quietHoursFrom,
      settings.quietHoursFrom.inMinutes,
    );
    await _prefs.setInt(
      PrefKeys.quietHoursUntil,
      settings.quietHoursUntil.inMinutes,
    );
    await _prefs.setBool(PrefKeys.maskAppNames, settings.maskAppNames);
  }

  Future<void> clear() async {
    await Future.wait([
      _prefs.remove(PrefKeys.ariaTone),
      _prefs.remove(PrefKeys.dailyTargetMinutes),
      _prefs.remove(PrefKeys.hapticsEnabled),
      _prefs.remove(PrefKeys.quietHoursEnabled),
      _prefs.remove(PrefKeys.quietHoursFrom),
      _prefs.remove(PrefKeys.quietHoursUntil),
      _prefs.remove(PrefKeys.maskAppNames),
      _prefs.remove(PrefKeys.spotCheckEnabled),
      _prefs.remove(PrefKeys.spotCheckIntervalDays),
      _prefs.remove(PrefKeys.spotCheckHistory),
      _prefs.remove(PrefKeys.ariaAiEnabled),
      _prefs.remove(PrefKeys.ariaAiProactive),
      _prefs.remove(PrefKeys.quickSocialReturns),
      _prefs.remove(PrefKeys.intentionalSocialExits),
      _prefs.remove(PrefKeys.completedBreathingPauses),
      _prefs.remove(PrefKeys.achievementProgress),
    ]);
  }

  AriaTone _toneFrom(String? raw) => AriaToneX.fromName(raw);
}
