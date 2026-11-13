import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/pref_keys.dart';
import '../../usage_tracking/data/daily_usage_store.dart';
import '../domain/spot_check_models.dart';

class SpotCheckPreferences {
  const SpotCheckPreferences({
    required this.enabled,
    required this.intervalDays,
  });

  final bool enabled;
  final int intervalDays;
}

class SpotCheckStore {
  SpotCheckStore(this._preferences);

  final SharedPreferences _preferences;

  SpotCheckPreferences readPreferences() => SpotCheckPreferences(
    enabled: _preferences.getBool(PrefKeys.spotCheckEnabled) ?? false,
    intervalDays: _preferences.getInt(PrefKeys.spotCheckIntervalDays) ?? 7,
  );

  Future<void> savePreferences({
    required bool enabled,
    required int intervalDays,
  }) async {
    await _preferences.setBool(PrefKeys.spotCheckEnabled, enabled);
    await _preferences.setInt(PrefKeys.spotCheckIntervalDays, intervalDays);
  }

  Future<List<SpotCheckSession>> readSessions() async {
    final raw = _preferences.getString(PrefKeys.spotCheckHistory);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .whereType<Map>()
          .map(
            (item) =>
                SpotCheckSession.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    } on Object {
      return const [];
    }
  }

  Future<void> saveSession(SpotCheckSession session) async {
    final sessions = await readSessions();
    final updated = [session, ...sessions]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    final retained = updated.take(60).map((item) => item.toJson()).toList();
    await _preferences.setString(
      PrefKeys.spotCheckHistory,
      jsonEncode(retained),
    );
  }

  Future<UsageTrend> readTrend() async {
    final days = await DailyUsageStore(_preferences).readAll();
    final byDate = {for (final day in days) dayKey(day.day): day};
    final today = DateTime.now();
    // Compare the last three complete days with the three before them. Today
    // is partial, so it is excluded from the signal.
    final recent = <int>[];
    final previous = <int>[];
    for (var offset = 1; offset <= 6; offset++) {
      final date = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: offset));
      final value = byDate[dayKey(date)]?.socialMinutes;
      if (value == null) continue;
      if (offset <= 3) {
        recent.add(value);
      } else {
        previous.add(value);
      }
    }
    if (recent.length < 2 || previous.length < 2) return UsageTrend.unknown;
    final recentAverage = recent.reduce((a, b) => a + b) / recent.length;
    final previousAverage = previous.reduce((a, b) => a + b) / previous.length;
    final change = recentAverage - previousAverage;
    final threshold = previousAverage * .12;
    if (change <= -threshold && change < -5) return UsageTrend.decreasing;
    if (change >= threshold && change > 5) return UsageTrend.increasing;
    return UsageTrend.steady;
  }
}
