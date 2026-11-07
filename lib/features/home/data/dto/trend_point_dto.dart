import 'package:freezed_annotation/freezed_annotation.dart';

part 'trend_point_dto.freezed.dart';
part 'trend_point_dto.g.dart';

/// Wire format for one trend point.
@freezed
abstract class TrendPointDto with _$TrendPointDto {
  const factory TrendPointDto({
    required String date,
    @JsonKey(name: 'screen_time_minutes') required int screenTimeMinutes,
    @JsonKey(name: 'target_minutes') required int targetMinutes,
  }) = _TrendPointDto;

  factory TrendPointDto.fromJson(Map<String, dynamic> json) =>
      _$TrendPointDtoFromJson(json);
}
