import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/pref_keys.dart';

/// A privacy-preserving, local-only daily aggregate. Keeping aggregates rather
/// than raw UsageEvents makes week/month comparisons durable even though
/// Android retains raw events for only a limited time.
class DailyUsageSnapshot {
  const DailyUsageSnapshot({
    required this.day,
    required this.socialMinutes,
    required this.socialOpens,
    required this.videosAdvanced,
  });

  final DateTime day;
  final int socialMinutes;
  final int socialOpens;
  final int videosAdvanced;

  Map<String, Object> toJson() => {
    'day': _dayKey(day),
    'socialMinutes': socialMinutes,
    'socialOpens': socialOpens,
    'videosAdvanced': videosAdvanced,
  };

  static DailyUsageSnapshot fromJson(Map<String, dynamic> json) =>
      DailyUsageSnapshot(
        day: DateTime.parse(json['day']! as String),
        socialMinutes: json['socialMinutes']! as int,
        socialOpens: json['socialOpens']! as int,
        videosAdvanced: json['videosAdvanced']! as int,
      );
}

class DailyUsageStore {
  DailyUsageStore(this._prefs);

  final SharedPreferences _prefs;

  Future<void> upsert(DailyUsageSnapshot snapshot) async {
    final items = await readAll();
    final byDay = {for (final item in items) _dayKey(item.day): item};
    byDay[_dayKey(snapshot.day)] = snapshot;
    final trimmed = byDay.values.toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    final retained = trimmed.length > 35
        ? trimmed.sublist(trimmed.length - 35)
        : trimmed;
    await _prefs.setString(
      PrefKeys.usageDailyHistory,
      jsonEncode(retained.map((item) => item.toJson()).toList()),
    );
  }

  Future<List<DailyUsageSnapshot>> readAll() async {
    final raw = _prefs.getString(PrefKeys.usageDailyHistory);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map(
            (item) => DailyUsageSnapshot.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false);
    } on Object {
      // A malformed cache should never prevent access to current usage.
      return const [];
    }
  }
}

String dayKey(DateTime value) => _dayKey(value);

String _dayKey(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
