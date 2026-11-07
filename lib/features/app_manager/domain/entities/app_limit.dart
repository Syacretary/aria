import 'limit_enforcement.dart';

/// A daily usage quota for one app.
///
/// [activeWeekdays] is where the "schedule" improvisation lands: an empty set
/// means every day, otherwise the limit only applies on the listed days
/// (1 = Monday … 7 = Sunday, matching `DateTime.weekday`).
class AppLimit {
  const AppLimit({
    required this.packageName,
    required this.dailyQuota,
    this.enabled = true,
    this.enforcement = LimitEnforcement.breathe,
    this.activeWeekdays = const {},
    this.activeFrom,
    this.activeUntil,
  });

  final String packageName;

  /// Total allowed usage per day.
  final Duration dailyQuota;

  /// Whether the limit is currently in force.
  final bool enabled;

  final LimitEnforcement enforcement;

  /// Days the limit applies to. Empty = every day.
  final Set<int> activeWeekdays;

  /// Optional time-of-day window. Null means "all day".
  final DurationOfDay? activeFrom;
  final DurationOfDay? activeUntil;

  bool get hasSchedule =>
      activeWeekdays.isNotEmpty || activeFrom != null || activeUntil != null;

  /// Whether this limit applies on [weekday] (`DateTime.monday`…`DateTime.sunday`).
  bool appliesOn(int weekday) =>
      activeWeekdays.isEmpty || activeWeekdays.contains(weekday);

  AppLimit copyWith({
    Duration? dailyQuota,
    bool? enabled,
    LimitEnforcement? enforcement,
    Set<int>? activeWeekdays,
    DurationOfDay? activeFrom,
    DurationOfDay? activeUntil,
    bool clearSchedule = false,
  }) {
    return AppLimit(
      packageName: packageName,
      dailyQuota: dailyQuota ?? this.dailyQuota,
      enabled: enabled ?? this.enabled,
      enforcement: enforcement ?? this.enforcement,
      activeWeekdays: clearSchedule
          ? const {}
          : (activeWeekdays ?? this.activeWeekdays),
      activeFrom: clearSchedule ? null : (activeFrom ?? this.activeFrom),
      activeUntil: clearSchedule ? null : (activeUntil ?? this.activeUntil),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLimit &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName &&
          dailyQuota == other.dailyQuota &&
          enabled == other.enabled &&
          enforcement == other.enforcement &&
          activeWeekdays == other.activeWeekdays &&
          activeFrom == other.activeFrom &&
          activeUntil == other.activeUntil;

  @override
  int get hashCode => Object.hash(
    packageName,
    dailyQuota,
    enabled,
    enforcement,
    activeWeekdays,
    activeFrom,
    activeUntil,
  );
}

/// A wall-clock time of day, stored as an offset from midnight.
///
/// A dedicated type rather than `TimeOfDay` so the domain layer stays free of
/// Flutter imports.
class DurationOfDay {
  const DurationOfDay(this.hour, this.minute);

  final int hour;
  final int minute;

  Duration get asDuration => Duration(hours: hour, minutes: minute);

  String get formatted =>
      '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DurationOfDay &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}
