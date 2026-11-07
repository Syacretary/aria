/// A single day's headline numbers, shown at the top of Beranda.
class DailySummary {
  const DailySummary({
    required this.date,
    required this.videosOpened,
    required this.videosOpenedYesterday,
    required this.socialAppOpens,
    required this.socialAppOpensYesterday,
    required this.totalScreenTime,
    required this.totalScreenTimeYesterday,
  });

  final DateTime date;

  /// Short-form videos opened today (the number ARIA nudges you about).
  final int videosOpened;
  final int videosOpenedYesterday;

  /// How many times social apps were opened today.
  final int socialAppOpens;
  final int socialAppOpensYesterday;

  final Duration totalScreenTime;
  final Duration totalScreenTimeYesterday;

  /// Change vs yesterday as a ratio. Positive means "more than yesterday".
  double get videoDeltaRatio => _ratio(videosOpened, videosOpenedYesterday);

  double get socialDeltaRatio =>
      _ratio(socialAppOpens, socialAppOpensYesterday);

  double get screenTimeDeltaRatio =>
      _ratio(totalScreenTime.inMinutes, totalScreenTimeYesterday.inMinutes);

  /// True when today is calmer than yesterday on the headline metric.
  bool get isCalmerThanYesterday => videosOpened <= videosOpenedYesterday;

  static double _ratio(num today, num yesterday) {
    if (yesterday <= 0) return today > 0 ? 1 : 0;
    return (today - yesterday) / yesterday;
  }
}
