import 'dart:math';

import '../../domain/entities/installed_social_app.dart';
import '../../domain/entities/usage_session.dart';
import 'usage_stats_source.dart';

/// Believable fake usage for iteration 1.
///
/// The numbers are hand-picked to exercise every UI state at once: one app well
/// over quota (TikTok), one nearly there (Instagram), one comfortably under
/// (YouTube), and several untouched. Session times cluster in the evening,
/// which is what the "trigger patterns" feature will eventually detect.
class UsageStatsMockSource implements UsageStatsSource {
  UsageStatsMockSource({int seed = 771}) : _random = Random(seed);

  final Random _random;

  @override
  Future<List<InstalledSocialApp>> installedSocialApps() async => const [
    InstalledSocialApp(
      packageName: 'com.zhiliaoapp.musically',
      appName: 'TikTok',
    ),
    InstalledSocialApp(
      packageName: 'com.instagram.android',
      appName: 'Instagram',
    ),
    InstalledSocialApp(
      packageName: 'com.google.android.youtube',
      appName: 'YouTube',
    ),
  ];

  static const Map<String, int> _baseMinutes = {
    'com.zhiliaoapp.musically': 78, // TikTok — over a 60m limit
    'com.instagram.android': 54, // Instagram — near a 60m limit
    'com.google.android.youtube': 41, // YouTube — under a 90m limit
    'com.whatsapp': 29,
    'com.google.android.apps.nbu.files': 12,
    'com.spotify.music': 22,
  };

  static const Map<String, int> _baseLaunches = {
    'com.zhiliaoapp.musically': 21,
    'com.instagram.android': 12,
    'com.google.android.youtube': 6,
    'com.whatsapp': 34,
    'com.google.android.apps.nbu.files': 3,
    'com.spotify.music': 4,
  };

  @override
  Future<Map<String, Duration>> screenTimeByApp({required DateTime day}) async {
    await _latency();
    return {
      for (final entry in _baseMinutes.entries)
        entry.key: Duration(minutes: _jitter(entry.value)),
    };
  }

  @override
  Future<Map<String, int>> launchCounts({required DateTime day}) async {
    await _latency();
    return {
      for (final entry in _baseLaunches.entries)
        entry.key: _jitter(entry.value, spread: 3),
    };
  }

  @override
  Future<List<UsageSession>> sessions({required DateTime day}) async {
    await _latency();
    final base = DateTime(day.year, day.month, day.day);
    return [
      UsageSession(
        packageName: 'com.zhiliaoapp.musically',
        start: base.add(const Duration(hours: 8, minutes: 15)),
        end: base.add(const Duration(hours: 8, minutes: 24)),
      ),
      UsageSession(
        packageName: 'com.zhiliaoapp.musically',
        start: base.add(const Duration(hours: 12, minutes: 40)),
        end: base.add(const Duration(hours: 13, minutes: 2)),
      ),
      UsageSession(
        packageName: 'com.zhiliaoapp.musically',
        start: base.add(const Duration(hours: 20, minutes: 5)),
        end: base.add(const Duration(hours: 20, minutes: 48)),
      ),
      UsageSession(
        packageName: 'com.instagram.android',
        start: base.add(const Duration(hours: 19, minutes: 10)),
        end: base.add(const Duration(hours: 19, minutes: 44)),
      ),
    ];
  }

  @override
  Future<int> scrollCount({required DateTime day}) async => 47;

  @override
  Future<bool> hasUsageAccess() async => true;

  Future<void> _latency() =>
      Future<void>.delayed(Duration(milliseconds: 140 + _random.nextInt(180)));

  /// Applies a small deterministic wobble so the data feels measured rather
  /// than hard-coded, while staying stable across launches.
  int _jitter(int value, {int spread = 4}) {
    final delta = _random.nextInt(spread * 2 + 1) - spread;
    final result = value + delta;
    return result < 0 ? 0 : result;
  }
}
