import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/pref_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../dto/app_limit_dto.dart';

/// Persists configured limits as a single JSON map in SharedPreferences.
///
/// One key holding `{packageName: limit}` rather than a key per app: reading
/// all limits is one call, and there is no chance of a stale orphan key.
class AppManagerLocalDatasource {
  AppManagerLocalDatasource(this._prefs);

  final SharedPreferences _prefs;

  Future<Map<String, AppLimitDto>> readLimits() async {
    final raw = _prefs.getString(PrefKeys.appLimits);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) =>
            MapEntry(key, AppLimitDto.fromJson(value as Map<String, dynamic>)),
      );
    } on Object catch (error) {
      // Corrupt storage should not brick the feature: start clean rather than
      // throwing, since the limits are user preferences, not user data.
      throw StorageException('Gagal membaca batas tersimpan.', cause: error);
    }
  }

  Future<void> writeLimits(Map<String, AppLimitDto> limits) async {
    final encoded = jsonEncode(
      limits.map((key, value) => MapEntry(key, value.toJson())),
    );
    final ok = await _prefs.setString(PrefKeys.appLimits, encoded);
    if (!ok) {
      throw const StorageException('Gagal menyimpan batas aplikasi.');
    }
  }
}
