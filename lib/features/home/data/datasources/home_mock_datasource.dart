import 'dart:math';

import '../dto/aria_message_dto.dart';
import '../dto/daily_summary_dto.dart';
import '../dto/period_stats_dto.dart';
import '../dto/top_app_usage_dto.dart';
import '../dto/trend_point_dto.dart';
import '../dto/win_entry_dto.dart';
import 'home_datasource.dart';

/// Deterministic fake data for iteration 1.
///
/// Seeded with a fixed [Random] so the home feed looks the same on every
/// launch — screenshots, golden tests and manual QA all stay comparable.
/// Values are shaped to tell a believable story: a slight improvement over
/// yesterday, one app already over its limit, a couple of real wins.
class HomeMockDatasource implements HomeDatasource {
  HomeMockDatasource({DateTime? now, int seed = 20261107})
    : _now = now ?? DateTime.now(),
      _random = Random(seed);

  final DateTime _now;
  final Random _random;

  /// A tiny artificial delay so loading skeletons are actually visible.
  Future<void> _latency() =>
      Future<void>.delayed(Duration(milliseconds: 180 + _random.nextInt(220)));

  @override
  Future<DailySummaryDto> fetchDailySummary() async {
    await _latency();
    final today = DateTime(_now.year, _now.month, _now.day);
    return DailySummaryDto(
      date: today.toIso8601String(),
      videosOpened: 47,
      videosOpenedYesterday: 68,
      socialOpens: 23,
      socialOpensYesterday: 31,
      screenTimeMinutes: 214,
      screenTimeMinutesYesterday: 268,
    );
  }

  @override
  Future<PeriodBreakdownDto> fetchPeriodBreakdown() async {
    await _latency();
    return const PeriodBreakdownDto(
      daily: PeriodStatDto(label: 'Hari ini', opens: 23, previousOpens: 31),
      weekly: PeriodStatDto(
        label: 'Minggu ini',
        opens: 164,
        previousOpens: 189,
      ),
      monthly: PeriodStatDto(
        label: 'Bulan ini',
        opens: 712,
        previousOpens: 655,
      ),
    );
  }

  @override
  Future<List<TrendPointDto>> fetchTrend({required int days}) async {
    await _latency();
    // Hand-tuned so the 7-day story reads as "improving, with a rough
    // weekend" rather than random noise.
    const screenMinutes = [268, 245, 231, 198, 176, 289, 214];
    const targetMinutes = 180;

    return List.generate(days, (i) {
      final day = _now.subtract(Duration(days: days - 1 - i));
      return TrendPointDto(
        date: DateTime(day.year, day.month, day.day).toIso8601String(),
        screenTimeMinutes: screenMinutes[i % screenMinutes.length],
        targetMinutes: targetMinutes,
      );
    });
  }

  @override
  Future<List<TopAppUsageDto>> fetchTopApps({required int count}) async {
    await _latency();
    const apps = [
      TopAppUsageDto(
        packageName: 'com.zhiliaoapp.musically',
        appName: 'TikTok',
        screenTimeMinutes: 78,
        sessionCount: 21,
        isLimited: true,
      ),
      TopAppUsageDto(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        screenTimeMinutes: 54,
        sessionCount: 12,
        isLimited: true,
      ),
      TopAppUsageDto(
        packageName: 'com.google.android.youtube',
        appName: 'YouTube',
        screenTimeMinutes: 41,
        sessionCount: 6,
        isLimited: false,
      ),
      TopAppUsageDto(
        packageName: 'com.whatsapp',
        appName: 'WhatsApp',
        screenTimeMinutes: 29,
        sessionCount: 34,
        isLimited: false,
      ),
    ];
    return apps.take(count).toList(growable: false);
  }

  @override
  Future<List<WinEntryDto>> fetchTodaysWins() async {
    await _latency();
    final base = DateTime(_now.year, _now.month, _now.day);
    return [
      WinEntryDto(
        id: 'win-1',
        label: 'Menunda TikTok',
        detail: '3 kali hari ini',
        occurredAt: base
            .add(const Duration(hours: 9, minutes: 20))
            .toIso8601String(),
        kind: 'delay',
      ),
      WinEntryDto(
        id: 'win-2',
        label: 'Instagram sesuai batas',
        detail: 'Tersisa 6 menit',
        occurredAt: base.add(const Duration(hours: 13)).toIso8601String(),
        kind: 'limit_kept',
      ),
      WinEntryDto(
        id: 'win-3',
        label: 'Sesi fokus',
        detail: '45 menit tanpa buka sosmed',
        occurredAt: base
            .add(const Duration(hours: 15, minutes: 30))
            .toIso8601String(),
        kind: 'focus',
      ),
    ];
  }

  @override
  Future<AriaMessageDto> fetchCurrentMessage() async {
    await _latency();
    return AriaMessageDto(
      id: 'msg-${_now.millisecondsSinceEpoch ~/ 86400000}',
      text:
          'Kamu sudah membuka video 47 kali hari ini — 21 kali lebih sedikit '
          'dari kemarin. Itu kemajuan yang nyata. Mau kita bicarakan apa yang '
          'membuat sore ini terasa lebih tenang?',
      createdAt: _now.toIso8601String(),
      action: 'chat',
      actionLabel: 'Ngobrol',
      tone: 'gentle',
    );
  }

  @override
  Future<AriaMessageDto> sendReply(String userMessage) async {
    await _latency();
    return AriaMessageDto(
      id: 'reply-${DateTime.now().millisecondsSinceEpoch}',
      text:
          'Aku mendengar. "$userMessage" — mari kita pelan-pelan. '
          'Apa satu hal kecil yang bisa kita jaga besok?',
      createdAt: DateTime.now().toIso8601String(),
      action: 'none',
      tone: 'gentle',
    );
  }
}
