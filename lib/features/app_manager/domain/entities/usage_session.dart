/// One stretch of continuous use of an app.
///
/// The building block for the "trigger patterns" improvisation: knowing that
/// TikTok is opened 20 times in 5-minute bursts tells a very different story
/// from 2 forty-minute sessions, even at identical total screen time.
class UsageSession {
  const UsageSession({
    required this.packageName,
    required this.start,
    required this.end,
  });

  final String packageName;
  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);

  int get startHour => start.hour;

  /// Whether this session happened inside the given quiet window.
  bool overlapsWindow({required int fromHour, required int untilHour}) {
    if (fromHour <= untilHour) {
      return startHour >= fromHour && startHour < untilHour;
    }
    // Window crosses midnight.
    return startHour >= fromHour || startHour < untilHour;
  }
}
