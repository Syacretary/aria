/// Date helpers shared across features.
extension DateX on DateTime {
  static const _shortWeekdays = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];
  static const _weekdays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String get _day => day.toString();
  String get _shortMonth => _shortMonths[month - 1];
  String get _month => _months[month - 1];
  String get _time =>
      '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';

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
  String get shortWeekdayId => _shortWeekdays[weekday - 1];

  /// "3 Nov" — for chart axis and list subtitles.
  String get shortDateId => '$_day $_shortMonth';

  /// "Senin, 3 November 2026" — for page headers.
  String get longDateId => '${_weekdays[weekday - 1]}, $_day $_month $year';

  /// "3 Nov 2026, 14.30" — for message timestamps.
  String get dateTimeId => '$_day $_shortMonth $year, $_time';

  /// "14.30" — for compact list subtitles.
  String get shortTimeId => _time;
}
