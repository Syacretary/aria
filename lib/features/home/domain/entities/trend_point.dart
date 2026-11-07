/// One point in the 7-day trend chart.
class TrendPoint {
  const TrendPoint({
    required this.date,
    required this.screenTime,
    required this.target,
  });

  final DateTime date;
  final Duration screenTime;

  /// The user's daily target for that day, drawn as the reference ceiling.
  final Duration target;

  /// Whether screen time is at or under target — drives bar colour.
  bool get isWithinTarget => screenTime <= target;

  /// Height fraction for the chart, capped so one outlier day doesn't flatten
  /// every other bar.
  double get fraction {
    final ceiling = target.inMinutes > 0 ? target.inMinutes * 1.4 : 1.0;
    return (screenTime.inMinutes / ceiling).clamp(0.04, 1.0);
  }
}
