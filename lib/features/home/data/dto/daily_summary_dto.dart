import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_summary_dto.freezed.dart';
part 'daily_summary_dto.g.dart';

/// Wire format for the daily summary.
///
/// Durations travel as minutes (integers) rather than ISO strings so the
/// payload stays trivial to produce from a platform channel later.
@freezed
abstract class DailySummaryDto with _$DailySummaryDto {
  const factory DailySummaryDto({
    @JsonKey(name: 'date') required String date,
    @JsonKey(name: 'videos_opened') required int videosOpened,
    @JsonKey(name: 'videos_opened_yesterday')
    required int videosOpenedYesterday,
    @JsonKey(name: 'social_opens') required int socialOpens,
    @JsonKey(name: 'social_opens_yesterday') required int socialOpensYesterday,
    @JsonKey(name: 'screen_time_minutes') required int screenTimeMinutes,
    @JsonKey(name: 'screen_time_minutes_yesterday')
    required int screenTimeMinutesYesterday,
  }) = _DailySummaryDto;

  factory DailySummaryDto.fromJson(Map<String, dynamic> json) =>
      _$DailySummaryDtoFromJson(json);
}
