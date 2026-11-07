import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/aria_scaffold.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../domain/entities/daily_summary.dart';
import 'providers/home_providers.dart';
import 'widgets/aria_message_card.dart';
import 'widgets/daily_summary_card.dart';
import 'widgets/seven_day_trend_card.dart';
import 'widgets/todays_wins_card.dart';
import 'widgets/top_apps_card.dart';
import 'widgets/usage_period_card.dart';

/// Beranda — the home feed.
///
/// Six blocks, each owning its own loading and error state:
/// 1. today's video count,
/// 2. daily/weekly/monthly social opens,
/// 3. ARIA's message with the "Ngobrol" follow-up,
/// 4. today's wins,
/// 5. the 7-day trend,
/// 6. top-3 apps by screen time.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(_greetingProvider);

    return AriaScaffold(
      title: greeting.title,
      subtitle: DateTime.now().longDateId,
      child: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(dailySummaryProvider)
            ..invalidate(periodBreakdownProvider)
            ..invalidate(weeklyTrendProvider)
            ..invalidate(topAppsProvider)
            ..invalidate(todaysWinsProvider)
            ..invalidate(ariaMessageProvider);
          // Give the invalidated providers a frame to start loading so the
          // spinner doesn't vanish before the skeletons appear.
          await Future<void>.delayed(const Duration(milliseconds: 250));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            0,
            AppSpacing.pageGutter,
            AppSpacing.huge,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            DailySummaryCard(),
            SizedBox(height: AppSpacing.cardGap),
            UsagePeriodCard(),
            SizedBox(height: AppSpacing.cardGap),
            AriaMessageCard(),
            SizedBox(height: AppSpacing.cardGap),
            TodaysWinsCard(),
            SizedBox(height: AppSpacing.cardGap),
            SevenDayTrendCard(),
            SizedBox(height: AppSpacing.cardGap),
            TopAppsCard(),
          ],
        ),
      ),
    );
  }
}

/// Time-of-day greeting derived from the daily summary's calm/direction.
///
/// Split out so the header reacts to data without rebuilding the feed.
final _greetingProvider = Provider<({String title, String? note})>((ref) {
  final hour = DateTime.now().hour;
  final base = switch (hour) {
    < 11 => 'Selamat pagi',
    < 15 => 'Selamat siang',
    < 19 => 'Selamat sore',
    _ => 'Selamat malam',
  };

  final summary = ref.watch(dailySummaryProvider);
  final note = summary.maybeWhen(
    data: (data) => _noteFor(data),
    orElse: () => null,
  );

  return (title: base, note: note);
});

String? _noteFor(DailySummary data) {
  if (data.videosOpened < data.videosOpenedYesterday) {
    return 'Hari ini lebih tenang dari kemarin.';
  }
  if (data.videosOpened > data.videosOpenedYesterday) {
    return 'Sedikit lebih ramai dari kemarin — tidak apa-apa.';
  }
  return 'Ritmenya sama seperti kemarin.';
}
