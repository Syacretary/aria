import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/pref_keys.dart';
import '../../home/domain/entities/daily_summary.dart';
import '../../usage_tracking/data/daily_usage_store.dart';

class AchievementProgress {
  const AchievementProgress({
    required this.quickSocialReturns,
    required this.intentionalSocialExits,
    required this.completedBreathingPauses,
    required this.daysWithinTarget,
    required this.daysReduced,
  });

  final int quickSocialReturns;
  final int intentionalSocialExits;
  final int completedBreathingPauses;
  final int daysWithinTarget;
  final int daysReduced;
}

/// Turns local usage aggregates into cumulative, repeatable achievement counts.
class AchievementProgressStore {
  AchievementProgressStore(this._preferences);

  final SharedPreferences _preferences;

  Future<AchievementProgress> refresh({
    required DailySummary current,
    required int targetMinutes,
  }) async {
    final saved = _readCreditedDays();
    final withinTargetDays = saved.withinTarget.toSet();
    final reducedDays = saved.reduced.toSet();
    final today = DateTime(
      current.date.year,
      current.date.month,
      current.date.day,
    );
    final history = await DailyUsageStore(_preferences).readAll();
    history.sort((a, b) => a.day.compareTo(b.day));
    final byDay = {
      for (final snapshot in history) _dateKey(snapshot.day): snapshot,
    };

    for (final snapshot in history) {
      final day = DateTime(
        snapshot.day.year,
        snapshot.day.month,
        snapshot.day.day,
      );
      if (!day.isBefore(today)) continue; // Credit only complete days.
      final key = _dateKey(day);
      if (targetMinutes > 0 &&
          snapshot.socialMinutes > 0 &&
          snapshot.socialMinutes <= targetMinutes) {
        withinTargetDays.add(key);
      }

      final previousDay = day.subtract(const Duration(days: 1));
      final previous = byDay[_dateKey(previousDay)];
      if (previous != null &&
          snapshot.socialMinutes > 0 &&
          previous.socialMinutes - snapshot.socialMinutes >= 10) {
        reducedDays.add(key);
      }
    }

    if (withinTargetDays.length != saved.withinTarget.length ||
        reducedDays.length != saved.reduced.length) {
      await _preferences.setString(
        PrefKeys.achievementProgress,
        jsonEncode({
          'withinTargetDays': withinTargetDays.toList()..sort(),
          'reducedDays': reducedDays.toList()..sort(),
        }),
      );
    }

    return AchievementProgress(
      quickSocialReturns: _preferences.getInt(PrefKeys.quickSocialReturns) ?? 0,
      intentionalSocialExits:
          _preferences.getInt(PrefKeys.intentionalSocialExits) ?? 0,
      completedBreathingPauses:
          _preferences.getInt(PrefKeys.completedBreathingPauses) ?? 0,
      daysWithinTarget: withinTargetDays.length,
      daysReduced: reducedDays.length,
    );
  }

  ({List<String> withinTarget, List<String> reduced}) _readCreditedDays() {
    try {
      final raw = _preferences.getString(PrefKeys.achievementProgress);
      if (raw == null) return (withinTarget: const [], reduced: const []);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return (
        withinTarget: (data['withinTargetDays'] as List<dynamic>? ?? const [])
            .cast<String>(),
        reduced: (data['reducedDays'] as List<dynamic>? ?? const [])
            .cast<String>(),
      );
    } on Object {
      return (withinTarget: const [], reduced: const []);
    }
  }
}

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
