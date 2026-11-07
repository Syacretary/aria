import 'package:intl/intl.dart';

/// Date helpers shared across features.
extension DateX on DateTime {
  /// Midnight of this day, local time.
  DateTime get startOfDay => DateTime(year, month, day);

  /// Midnight of the next day (exclusive upper bound for "today").
  DateTime get endOfDay => startOfDay.add(const Duration(days: 1));

  /// Monday-based start of week.
  DateTime get startOfWeek {
    final monday = subtract(Duration(days: weekday - DateTime.monday));
    return monday.startOfDay;
  }

  /// First instant of the month.
  DateTime get startOfMonth => DateTime(year, month);

  bool isSameDayAs(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Number of whole days between two dates, ignoring time.
  int daysBetween(DateTime other) =>
      startOfDay.difference(other.startOfDay).inDays;

  /// "Sen", "Sel", ... — for compact week labels in charts.
  String get shortWeekdayId => DateFormat('E', 'id_ID').format(this);

  /// "3 Nov" — for chart axis and list subtitles.
  String get shortDateId => DateFormat('d MMM', 'id_ID').format(this);

  /// "Senin, 3 November 2026" — for page headers.
  String get longDateId => DateFormat('EEEE, d MMMM y', 'id_ID').format(this);

  /// "3 Nov 2026, 14.30" — for message timestamps.
  String get dateTimeId => DateFormat('d MMM y, HH.mm', 'id_ID').format(this);

  /// "14.30" — for compact list subtitles.
  String get shortTimeId => DateFormat('HH.mm', 'id_ID').format(this);
}
