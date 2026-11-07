import 'package:freezed_annotation/freezed_annotation.dart';

part 'managed_app_dto.freezed.dart';
part 'managed_app_dto.g.dart';

/// Wire format for one governed app.
@freezed
abstract class ManagedAppDto with _$ManagedAppDto {
  const factory ManagedAppDto({
    @JsonKey(name: 'package_name') required String packageName,
    @JsonKey(name: 'app_name') required String appName,
    @JsonKey(name: 'used_minutes') @Default(0) int usedMinutes,
    @JsonKey(name: 'session_count') @Default(0) int sessionCount,
    @JsonKey(name: 'category') @Default('other') String category,
    @JsonKey(name: 'is_installed') @Default(true) bool isInstalled,
  }) = _ManagedAppDto;

  factory ManagedAppDto.fromJson(Map<String, dynamic> json) =>
      _$ManagedAppDtoFromJson(json);
}
