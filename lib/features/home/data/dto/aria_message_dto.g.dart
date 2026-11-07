// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aria_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AriaMessageDto _$AriaMessageDtoFromJson(Map<String, dynamic> json) =>
    _AriaMessageDto(
      id: json['id'] as String,
      text: json['text'] as String,
      createdAt: json['created_at'] as String,
      action: json['action'] as String? ?? 'chat',
      actionLabel: json['action_label'] as String?,
      tone: json['tone'] as String? ?? 'gentle',
    );

Map<String, dynamic> _$AriaMessageDtoToJson(_AriaMessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'created_at': instance.createdAt,
      'action': instance.action,
      'action_label': instance.actionLabel,
      'tone': instance.tone,
    };
