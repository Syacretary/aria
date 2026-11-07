/// Screen time for one application, shown in the top-3 card.
class TopAppUsage {
  const TopAppUsage({
    required this.packageName,
    required this.appName,
    required this.screenTime,
    required this.sessionCount,
    required this.isLimited,
  });

  /// Android package id, e.g. `com.zhiliaoapp.musically`.
  final String packageName;
  final String appName;
  final Duration screenTime;

  /// How many separate sessions today — a 90-minute day in 2 sessions reads
  /// very differently from 20.
  final int sessionCount;

  /// Whether App Manager has a daily limit configured for this app.
  final bool isLimited;

  /// Average session length, or [Duration.zero] when there were no sessions.
  Duration get averageSession => sessionCount <= 0
      ? Duration.zero
      : Duration(seconds: screenTime.inSeconds ~/ sessionCount);

  /// Fraction used to size the inline usage bar relative to [busiest].
  double fractionAgainst(Duration busiest) {
    if (busiest.inSeconds <= 0) return 0;
    return (screenTime.inSeconds / busiest.inSeconds).clamp(0.0, 1.0);
  }
}
