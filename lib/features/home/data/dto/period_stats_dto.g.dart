// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PeriodStatDto _$PeriodStatDtoFromJson(Map<String, dynamic> json) =>
    _PeriodStatDto(
      label: json['label'] as String,
      opens: (json['opens'] as num).toInt(),
      previousOpens: (json['previous_opens'] as num).toInt(),
    );

Map<String, dynamic> _$PeriodStatDtoToJson(_PeriodStatDto instance) =>
    <String, dynamic>{
      'label': instance.label,
      'opens': instance.opens,
      'previous_opens': instance.previousOpens,
    };

_PeriodBreakdownDto _$PeriodBreakdownDtoFromJson(Map<String, dynamic> json) =>
    _PeriodBreakdownDto(
      daily: PeriodStatDto.fromJson(json['daily'] as Map<String, dynamic>),
      weekly: PeriodStatDto.fromJson(json['weekly'] as Map<String, dynamic>),
      monthly: PeriodStatDto.fromJson(json['monthly'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PeriodBreakdownDtoToJson(_PeriodBreakdownDto instance) =>
    <String, dynamic>{
      'daily': instance.daily,
      'weekly': instance.weekly,
      'monthly': instance.monthly,
    };
