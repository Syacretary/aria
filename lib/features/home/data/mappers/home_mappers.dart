import '../../../../core/companion/aria_tone.dart';
import '../../domain/entities/aria_message.dart';
import '../../domain/entities/daily_summary.dart';
import '../../domain/entities/period_stats.dart';
import '../../domain/entities/top_app_usage.dart';
import '../../domain/entities/trend_point.dart';
import '../../domain/entities/win_entry.dart';
import '../dto/aria_message_dto.dart';
import '../dto/daily_summary_dto.dart';
import '../dto/period_stats_dto.dart';
import '../dto/top_app_usage_dto.dart';
import '../dto/trend_point_dto.dart';
import '../dto/win_entry_dto.dart';

/// DTO → entity translation.
///
/// Kept in one file per feature: the mapping rules are the contract between
/// the wire format and the domain, and reading them together is how you spot
/// drift.
abstract final class HomeMappers {
  static DailySummary toDailySummary(DailySummaryDto dto) {
    return DailySummary(
      date: DateTime.parse(dto.date),
      videosOpened: dto.videosOpened,
      videosOpenedYesterday: dto.videosOpenedYesterday,
      socialAppOpens: dto.socialOpens,
      socialAppOpensYesterday: dto.socialOpensYesterday,
      totalScreenTime: Duration(minutes: dto.screenTimeMinutes),
      totalScreenTimeYesterday: Duration(
        minutes: dto.screenTimeMinutesYesterday,
      ),
    );
  }

  static PeriodStat toPeriodStat(PeriodStatDto dto) => PeriodStat(
    label: dto.label,
    opens: dto.opens,
    previousOpens: dto.previousOpens,
  );

  static PeriodBreakdown toPeriodBreakdown(PeriodBreakdownDto dto) =>
      PeriodBreakdown(
        daily: toPeriodStat(dto.daily),
        weekly: toPeriodStat(dto.weekly),
        monthly: toPeriodStat(dto.monthly),
      );

  static TrendPoint toTrendPoint(TrendPointDto dto) => TrendPoint(
    date: DateTime.parse(dto.date),
    screenTime: Duration(minutes: dto.screenTimeMinutes),
    target: Duration(minutes: dto.targetMinutes),
  );

  static TopAppUsage toTopAppUsage(TopAppUsageDto dto) => TopAppUsage(
    packageName: dto.packageName,
    appName: dto.appName,
    screenTime: Duration(minutes: dto.screenTimeMinutes),
    sessionCount: dto.sessionCount,
    isLimited: dto.isLimited,
  );

  static WinEntry toWinEntry(WinEntryDto dto) => WinEntry(
    id: dto.id,
    label: dto.label,
    detail: dto.detail,
    occurredAt: DateTime.parse(dto.occurredAt),
    icon: _winKindFrom(dto.kind),
  );

  static AriaMessage toAriaMessage(AriaMessageDto dto) => AriaMessage(
    id: dto.id,
    text: dto.text,
    createdAt: DateTime.parse(dto.createdAt),
    action: _messageActionFrom(dto.action),
    actionLabel: dto.actionLabel,
    tone: _toneFrom(dto.tone),
  );

  static WinKind _winKindFrom(String raw) => switch (raw) {
    'limit_kept' => WinKind.limitKept,
    'offline' => WinKind.offline,
    'focus' => WinKind.focus,
    'prayer' => WinKind.prayer,
    _ => WinKind.delay,
  };

  static AriaMessageAction _messageActionFrom(String raw) => switch (raw) {
    'manage_limits' => AriaMessageAction.manageLimits,
    'view_trend' => AriaMessageAction.viewTrend,
    'none' => AriaMessageAction.none,
    _ => AriaMessageAction.chat,
  };

  static AriaTone _toneFrom(String raw) => AriaToneX.fromName(raw);
}
