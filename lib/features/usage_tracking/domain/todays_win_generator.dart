import '../../home/domain/entities/win_entry.dart';
import '../data/daily_usage_store.dart';

/// Deterministic rule engine for positive, varied reinforcement. The daily
/// seed rotates copy without an LLM and priority prevents a long list of
/// redundant achievements from appearing together.
abstract final class TodaysWinGenerator {
  static List<WinEntry> build({
    required DailyUsageSnapshot today,
    required DailyUsageSnapshot? yesterday,
    required int targetMinutes,
    required DateTime now,
  }) {
    final candidates = <WinEntry>[];
    final reducedMinutes =
        (yesterday?.socialMinutes ?? today.socialMinutes) - today.socialMinutes;
    final reducedOpens =
        (yesterday?.socialOpens ?? today.socialOpens) - today.socialOpens;
    final minuteCopy = [
      'Lebih lega dari kemarin',
      'Ritme layar lebih tenang',
      'Kamu memberi ruang untuk dirimu',
    ];
    final openCopy = [
      'Lebih jarang kembali',
      'Kamu memutus dorongan berulang',
      'Lebih sedikit pintu yang dibuka',
    ];
    final variant = now.day % 3;

    if (reducedMinutes >= 10) {
      candidates.add(
        WinEntry(
          id: 'less-time-${dayKey(today.day)}',
          label: minuteCopy[variant],
          detail: '$reducedMinutes menit lebih singkat dibanding kemarin',
          occurredAt: now,
          icon: WinKind.focus,
        ),
      );
    }
    if (reducedOpens >= 2) {
      candidates.add(
        WinEntry(
          id: 'fewer-opens-${dayKey(today.day)}',
          label: openCopy[(variant + 1) % 3],
          detail: '$reducedOpens kali buka sosmed lebih sedikit',
          occurredAt: now,
          icon: WinKind.delay,
        ),
      );
    }
    if (today.socialMinutes <= targetMinutes && targetMinutes > 0) {
      final left = targetMinutes - today.socialMinutes;
      candidates.add(
        WinEntry(
          id: 'target-kept-${dayKey(today.day)}',
          label: [
            'Batas harian tetap terjaga',
            'Kamu menjaga batasmu',
            'Targetmu masih aman',
          ][variant],
          detail: left == 0
              ? 'Tepat di batas yang kamu pilih'
              : 'Masih tersisa $left menit dari target',
          occurredAt: now,
          icon: WinKind.limitKept,
        ),
      );
    }
    return candidates.take(2).toList(growable: false);
  }
}
