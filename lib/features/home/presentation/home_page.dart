import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/aria_semantic_colors.dart';
import '../../../../core/utils/date_x.dart';
import '../domain/entities/daily_summary.dart';
import 'providers/home_providers.dart';
import 'widgets/aria_message_card.dart';
import 'widgets/daily_summary_card.dart';
import 'widgets/seven_day_trend_card.dart';
import 'widgets/todays_wins_card.dart';
import 'widgets/top_apps_card.dart';
import 'widgets/usage_period_card.dart';

/// Beranda — the mindful digital wellbeing home feed.
/// Designed for calm, visual-first clarity in under 3 seconds.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(_greetingProvider);
    final theme = Theme.of(context);
    final topInset = MediaQuery.of(context).padding.top;
    final topPadding = topInset + 48 + AppSpacing.xl;

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
            edgeOffset: topInset + 48,
            onRefresh: () async {
              ref
                ..invalidate(dailySummaryProvider)
                ..invalidate(periodBreakdownProvider)
                ..invalidate(weeklyTrendProvider)
                ..invalidate(topAppsProvider)
                ..invalidate(todaysWinsProvider)
                ..invalidate(ariaMessageProvider);
              await Future<void>.delayed(const Duration(milliseconds: 250));
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                topPadding,
                AppSpacing.pageGutter,
                AppSpacing.huge,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Quiet, grounding greeting
                Text(
                  greeting.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateTime.now().longDateId,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 1. Hero Summary Card
                const DailySummaryCard(),
                const SizedBox(height: AppSpacing.cardGap),

                // 2. ARIA Companion Message
                const AriaMessageCard(),
                const SizedBox(height: AppSpacing.cardGap),

                // 3. Today's Wins (Rewarded progress)
                const TodaysWinsCard(),
                const SizedBox(height: AppSpacing.cardGap),

                // 4. Social Open Frequency (Daily/Weekly/Monthly)
                const UsagePeriodCard(),
                const SizedBox(height: AppSpacing.cardGap),

                // 5. 7-Day Trend Chart
                const SevenDayTrendCard(),
                const SizedBox(height: AppSpacing.cardGap),

                // 6. Top 3 Apps by Screen Time
                const TopAppsCard(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.94),
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.72),
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
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
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
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
        elevation: 2,
        shadowColor: colors.win.withValues(alpha: .12),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 19, color: colors.win),
          ),
        ),
      ),
    );
  }
}

/// Soft light source on Beranda
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
          Color(0x66F5EBD9),
          Color(0x00F5EBD9),
        ],
        stops: [0, 0.32, 0.68, 1],
      ),
    ),
  );
}

/// Time-of-day greeting
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
