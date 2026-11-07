// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'win_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WinEntryDto _$WinEntryDtoFromJson(Map<String, dynamic> json) => _WinEntryDto(
  id: json['id'] as String,
  label: json['label'] as String,
  detail: json['detail'] as String,
  occurredAt: json['occurred_at'] as String,
  kind: json['kind'] as String? ?? 'delay',
);

Map<String, dynamic> _$WinEntryDtoToJson(_WinEntryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'detail': instance.detail,
      'occurred_at': instance.occurredAt,
      'kind': instance.kind,
    };
