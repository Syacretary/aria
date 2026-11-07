// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'managed_app_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ManagedAppDto _$ManagedAppDtoFromJson(Map<String, dynamic> json) =>
    _ManagedAppDto(
      packageName: json['package_name'] as String,
      appName: json['app_name'] as String,
      usedMinutes: (json['used_minutes'] as num?)?.toInt() ?? 0,
      sessionCount: (json['session_count'] as num?)?.toInt() ?? 0,
      category: json['category'] as String? ?? 'other',
      isInstalled: json['is_installed'] as bool? ?? true,
    );

Map<String, dynamic> _$ManagedAppDtoToJson(_ManagedAppDto instance) =>
    <String, dynamic>{
      'package_name': instance.packageName,
      'app_name': instance.appName,
      'used_minutes': instance.usedMinutes,
      'session_count': instance.sessionCount,
      'category': instance.category,
      'is_installed': instance.isInstalled,
    };
