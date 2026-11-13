// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_limit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppLimitDto _$AppLimitDtoFromJson(Map<String, dynamic> json) => _AppLimitDto(
  packageName: json['package_name'] as String,
  quotaMinutes: (json['quota_minutes'] as num).toInt(),
  enabled: json['enabled'] as bool? ?? true,
  enforcement: json['enforcement'] as String? ?? 'breathe',
  remindOnOpen: json['remind_on_open'] as bool? ?? false,
  activeWeekdays: json['active_weekdays'] as String? ?? '',
  activeFromMinutes: (json['active_from_minutes'] as num?)?.toInt(),
  activeUntilMinutes: (json['active_until_minutes'] as num?)?.toInt(),
);

Map<String, dynamic> _$AppLimitDtoToJson(_AppLimitDto instance) =>
    <String, dynamic>{
      'package_name': instance.packageName,
      'quota_minutes': instance.quotaMinutes,
      'enabled': instance.enabled,
      'enforcement': instance.enforcement,
      'remind_on_open': instance.remindOnOpen,
      'active_weekdays': instance.activeWeekdays,
      'active_from_minutes': instance.activeFromMinutes,
      'active_until_minutes': instance.activeUntilMinutes,
    };
