import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/aria_semantic_colors.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/routing/routes.dart';
import '../domain/entities/daily_summary.dart';
import 'providers/home_providers.dart';
import 'widgets/aria_message_card.dart';
import 'widgets/daily_summary_card.dart';
import 'widgets/seven_day_trend_card.dart';
import 'widgets/todays_wins_card.dart';
import 'widgets/top_apps_card.dart';
import 'widgets/usage_period_card.dart';
import '../../../../core/routing/routes.dart';

/// Beranda — the home feed.
///
/// Six blocks, each owning its own loading and error state:
/// 1. today's video count,
/// 2. ARIA's message with the "Ngobrol" follow-up,
/// 3. today's wins,
/// 4. daily/weekly/monthly social opens,
/// 5. the 7-day trend,
/// 6. top-3 apps by screen time.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(_greetingProvider);

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned(
            top: -255,
            left: -70,
            right: -70,
            child: _WelcomeLightCircle(),
          ),
          RefreshIndicator(
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
                AppSpacing.lg + 48,
                AppSpacing.pageGutter,
                AppSpacing.huge,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const DailySummaryCard(),
                const SizedBox(height: AppSpacing.xxl),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [const Color(0xFFB08232), const Color(0xFF8E73B8)],
                  ).createShader(bounds),
                  child: Text(
                    greeting.title,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DateTime.now().longDateId,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xl),
                const AriaMessageCard(),
                const SizedBox(height: AppSpacing.cardGap),
                const TodaysWinsCard(),
                const SizedBox(height: AppSpacing.cardGap),
                const UsagePeriodCard(),
                const SizedBox(height: AppSpacing.cardGap),
                const SevenDayTrendCard(),
                const SizedBox(height: AppSpacing.cardGap),
                const TopAppsCard(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      _HeaderAction(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Pencapaian',
                        onTap: () => context.push(Routes.achievements),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Aria',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                      ),
                      _HeaderAction(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Ngobrol dengan ARIA',
                        onTap: () => context.push(Routes.companionChat),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: .95),
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: colors.win.withValues(alpha: .16),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 20, color: colors.win),
          ),
        ),
      ),
    );
  }
}

/// Soft light source on Beranda; it becomes the visual origin for ARIA's
/// smiley face when the companion route opens.
class _WelcomeLightCircle extends StatelessWidget {
  const _WelcomeLightCircle();

  @override
  Widget build(BuildContext context) => Container(
    height: 560,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        center: Alignment(0, -0.35),
        colors: [
          Color(0xB3FFFFFF),
          Color(0x99FFD36E),
          Color(0x55C4B7EE),
          Color(0x00C4B7EE),
        ],
        stops: [0, 0.32, 0.68, 1],
      ),
    ),
  );
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
