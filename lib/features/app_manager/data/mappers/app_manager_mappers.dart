import '../../domain/entities/app_limit.dart';
import '../../domain/entities/limit_enforcement.dart';
import '../../domain/entities/managed_app.dart';
import '../dto/app_limit_dto.dart';
import '../dto/managed_app_dto.dart';

/// DTO ↔ entity translation for App Manager.
abstract final class AppManagerMappers {
  static AppLimit toAppLimit(AppLimitDto dto) => AppLimit(
    packageName: dto.packageName,
    dailyQuota: Duration(minutes: dto.quotaMinutes),
    enabled: dto.enabled,
    enforcement: _enforcementFrom(dto.enforcement),
    activeWeekdays: _weekdaysFrom(dto.activeWeekdays),
    activeFrom: _timeFrom(dto.activeFromMinutes),
    activeUntil: _timeFrom(dto.activeUntilMinutes),
  );

  static AppLimitDto toAppLimitDto(AppLimit limit) => AppLimitDto(
    packageName: limit.packageName,
    quotaMinutes: limit.dailyQuota.inMinutes,
    enabled: limit.enabled,
    enforcement: limit.enforcement.name,
    activeWeekdays: _weekdaysTo(limit.activeWeekdays),
    activeFromMinutes: _minutesFrom(limit.activeFrom),
    activeUntilMinutes: _minutesFrom(limit.activeUntil),
  );

  static Set<int> _weekdaysFrom(String raw) {
    if (raw.isEmpty) return const {};
    return raw.split(',').map(int.tryParse).whereType<int>().toSet();
  }

  static String _weekdaysTo(Set<int> weekdays) {
    final sorted = weekdays.toList()..sort();
    return sorted.join(',');
  }

  static ManagedApp toManagedApp(ManagedAppDto dto, {AppLimit? limit}) =>
      ManagedApp(
        packageName: dto.packageName,
        appName: dto.appName,
        usedToday: Duration(minutes: dto.usedMinutes),
        sessionCount: dto.sessionCount,
        category: _categoryFrom(dto.category),
        limit: limit,
      );

  static LimitEnforcement _enforcementFrom(String raw) => switch (raw) {
    'warn' => LimitEnforcement.warn,
    'block' => LimitEnforcement.block,
    'track_only' => LimitEnforcement.trackOnly,
    _ => LimitEnforcement.breathe,
  };

  static AppCategory _categoryFrom(String raw) => switch (raw) {
    'social' => AppCategory.social,
    'video' => AppCategory.video,
    'game' => AppCategory.game,
    'productivity' => AppCategory.productivity,
    'messaging' => AppCategory.messaging,
    _ => AppCategory.other,
  };

  static DurationOfDay? _timeFrom(int? minutes) {
    if (minutes == null) return null;
    return DurationOfDay(minutes ~/ 60, minutes % 60);
  }

  static int? _minutesFrom(DurationOfDay? time) {
    if (time == null) return null;
    return time.hour * 60 + time.minute;
  }
}
