import 'package:freezed_annotation/freezed_annotation.dart';

part 'aria_message_dto.freezed.dart';
part 'aria_message_dto.g.dart';

/// Wire format for an ARIA message.
@freezed
abstract class AriaMessageDto with _$AriaMessageDto {
  const factory AriaMessageDto({
    required String id,
    required String text,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'action') @Default('chat') String action,
    @JsonKey(name: 'action_label') String? actionLabel,
    @JsonKey(name: 'tone') @Default('gentle') String tone,
  }) = _AriaMessageDto;

  factory AriaMessageDto.fromJson(Map<String, dynamic> json) =>
      _$AriaMessageDtoFromJson(json);
}
