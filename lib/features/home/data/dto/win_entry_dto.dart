import 'package:freezed_annotation/freezed_annotation.dart';

part 'win_entry_dto.freezed.dart';
part 'win_entry_dto.g.dart';

/// Wire format for one win.
@freezed
abstract class WinEntryDto with _$WinEntryDto {
  const factory WinEntryDto({
    required String id,
    required String label,
    required String detail,
    @JsonKey(name: 'occurred_at') required String occurredAt,
    @JsonKey(name: 'kind') @Default('delay') String kind,
  }) = _WinEntryDto;

  factory WinEntryDto.fromJson(Map<String, dynamic> json) =>
      _$WinEntryDtoFromJson(json);
}
