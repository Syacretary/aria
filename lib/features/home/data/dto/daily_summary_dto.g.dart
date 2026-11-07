// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DailySummaryDto _$DailySummaryDtoFromJson(Map<String, dynamic> json) =>
    _DailySummaryDto(
      date: json['date'] as String,
      videosOpened: (json['videos_opened'] as num).toInt(),
      videosOpenedYesterday: (json['videos_opened_yesterday'] as num).toInt(),
      socialOpens: (json['social_opens'] as num).toInt(),
      socialOpensYesterday: (json['social_opens_yesterday'] as num).toInt(),
      screenTimeMinutes: (json['screen_time_minutes'] as num).toInt(),
      screenTimeMinutesYesterday: (json['screen_time_minutes_yesterday'] as num)
          .toInt(),
    );

Map<String, dynamic> _$DailySummaryDtoToJson(_DailySummaryDto instance) =>
    <String, dynamic>{
      'date': instance.date,
      'videos_opened': instance.videosOpened,
      'videos_opened_yesterday': instance.videosOpenedYesterday,
      'social_opens': instance.socialOpens,
      'social_opens_yesterday': instance.socialOpensYesterday,
      'screen_time_minutes': instance.screenTimeMinutes,
      'screen_time_minutes_yesterday': instance.screenTimeMinutesYesterday,
    };
