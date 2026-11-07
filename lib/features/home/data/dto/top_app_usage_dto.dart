import 'package:freezed_annotation/freezed_annotation.dart';

part 'top_app_usage_dto.freezed.dart';
part 'top_app_usage_dto.g.dart';

/// Wire format for one app's usage.
@freezed
abstract class TopAppUsageDto with _$TopAppUsageDto {
  const factory TopAppUsageDto({
    @JsonKey(name: 'package_name') required String packageName,
    @JsonKey(name: 'app_name') required String appName,
    @JsonKey(name: 'screen_time_minutes') required int screenTimeMinutes,
    @JsonKey(name: 'session_count') required int sessionCount,
    @JsonKey(name: 'is_limited') @Default(false) bool isLimited,
  }) = _TopAppUsageDto;

  factory TopAppUsageDto.fromJson(Map<String, dynamic> json) =>
      _$TopAppUsageDtoFromJson(json);
}
