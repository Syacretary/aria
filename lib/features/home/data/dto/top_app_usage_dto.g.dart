// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_app_usage_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TopAppUsageDto _$TopAppUsageDtoFromJson(Map<String, dynamic> json) =>
    _TopAppUsageDto(
      packageName: json['package_name'] as String,
      appName: json['app_name'] as String,
      screenTimeMinutes: (json['screen_time_minutes'] as num).toInt(),
      sessionCount: (json['session_count'] as num).toInt(),
      isLimited: json['is_limited'] as bool? ?? false,
    );

Map<String, dynamic> _$TopAppUsageDtoToJson(_TopAppUsageDto instance) =>
    <String, dynamic>{
      'package_name': instance.packageName,
      'app_name': instance.appName,
      'screen_time_minutes': instance.screenTimeMinutes,
      'session_count': instance.sessionCount,
      'is_limited': instance.isLimited,
    };
