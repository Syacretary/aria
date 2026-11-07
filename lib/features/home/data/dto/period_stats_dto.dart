import 'package:freezed_annotation/freezed_annotation.dart';

part 'period_stats_dto.freezed.dart';
part 'period_stats_dto.g.dart';

/// Wire format for one period row.
@freezed
abstract class PeriodStatDto with _$PeriodStatDto {
  const factory PeriodStatDto({
    required String label,
    required int opens,
    @JsonKey(name: 'previous_opens') required int previousOpens,
  }) = _PeriodStatDto;

  factory PeriodStatDto.fromJson(Map<String, dynamic> json) =>
      _$PeriodStatDtoFromJson(json);
}

/// Wire format for the three-period breakdown.
@freezed
abstract class PeriodBreakdownDto with _$PeriodBreakdownDto {
  const factory PeriodBreakdownDto({
    required PeriodStatDto daily,
    required PeriodStatDto weekly,
    required PeriodStatDto monthly,
  }) = _PeriodBreakdownDto;

  factory PeriodBreakdownDto.fromJson(Map<String, dynamic> json) =>
      _$PeriodBreakdownDtoFromJson(json);
}
