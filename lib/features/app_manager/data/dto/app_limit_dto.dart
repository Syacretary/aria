import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_limit_dto.freezed.dart';
part 'app_limit_dto.g.dart';

/// Persisted form of an [AppLimit].
///
/// Stored as JSON inside a single SharedPreferences string keyed by package
/// name, so a limit survives restarts without a database.
///
/// Note: `activeWeekdays` is a comma-separated string rather than a `List<int>`
/// because the current `freezed` generator emits an invalid constructor for
/// list-typed fields. The mapper converts to and from `Set<int>`.
@freezed
abstract class AppLimitDto with _$AppLimitDto {
  const factory AppLimitDto({
    @JsonKey(name: 'package_name') required String packageName,
    @JsonKey(name: 'quota_minutes') required int quotaMinutes,
    @Default(true) bool enabled,
    @JsonKey(name: 'enforcement') @Default('breathe') String enforcement,
    @JsonKey(name: 'active_weekdays') @Default('') String activeWeekdays,
    @JsonKey(name: 'active_from_minutes') int? activeFromMinutes,
    @JsonKey(name: 'active_until_minutes') int? activeUntilMinutes,
  }) = _AppLimitDto;

  factory AppLimitDto.fromJson(Map<String, dynamic> json) =>
      _$AppLimitDtoFromJson(json);
}
