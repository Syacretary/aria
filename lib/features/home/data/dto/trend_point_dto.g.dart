// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_point_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrendPointDto _$TrendPointDtoFromJson(Map<String, dynamic> json) =>
    _TrendPointDto(
      date: json['date'] as String,
      screenTimeMinutes: (json['screen_time_minutes'] as num).toInt(),
      targetMinutes: (json['target_minutes'] as num).toInt(),
    );

Map<String, dynamic> _$TrendPointDtoToJson(_TrendPointDto instance) =>
    <String, dynamic>{
      'date': instance.date,
      'screen_time_minutes': instance.screenTimeMinutes,
      'target_minutes': instance.targetMinutes,
    };
