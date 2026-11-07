/// Duration formatting in the "1j 24m" style ARIA uses in the UI.
extension DurationX on Duration {
  /// Compact human form. Zero minutes renders as "0m".
  ///
  /// - 45m       -> "45m"
  /// - 1h 5m     -> "1j 5m"
  /// - 2h 0m     -> "2j"
  /// - 1d 3h     -> "1h 3j"
  String get compact {
    final totalMinutes = inMinutes;
    if (totalMinutes <= 0) return '0m';
    if (totalMinutes < 60) return '${totalMinutes}m';

    final days = totalMinutes ~/ (60 * 24);
    final hours = (totalMinutes ~/ 60) % 24;
    final minutes = totalMinutes % 60;

    final parts = <String>[];
    if (days > 0) parts.add('${days}h');
    if (hours > 0) parts.add('${hours}j');
    if (minutes > 0 && days == 0) parts.add('${minutes}m');
    return parts.join(' ');
  }

  /// Rounded to the nearest whole minute, as "12 menit".
  String get inWordsId {
    final minutes = inMinutes;
    if (minutes < 60) return '$minutes menit';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (rest == 0) return '$hours jam';
    return '$hours jam $rest menit';
  }

  /// Fraction of [limit] consumed, clamped to `[0, 1]`.
  double ratioTo(Duration limit) {
    if (limit.inSeconds <= 0) return 0;
    return (inSeconds / limit.inSeconds).clamp(0.0, 1.0);
  }
}
