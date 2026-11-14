import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/presentation/aria_bar_chart.dart';
import '../../../../core/presentation/aria_card.dart';
import '../../../../core/presentation/aria_loading.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/aria_semantic_colors.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/duration_x.dart';
import '../../domain/entities/trend_point.dart';
import '../providers/home_providers.dart';

/// Seven-day screen-time trend against the daily target.
/// Minimalist visual-first presentation.
class SevenDayTrendCard extends ConsumerWidget {
  const SevenDayTrendCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend = ref.watch(weeklyTrendProvider);

    return trend.when(
      loading: () => const AriaCard(
        eyebrow: 'Tren 7 hari',
        child: AriaSkeleton(height: 104, radius: 12),
      ),
      error: (error, _) => AriaCard(
        child: Text(
          failureMessage(error),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (points) => _Content(points: points),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.points});

  final List<TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;
    final today = DateTime.now();

    final withinTarget = points.where((p) => p.isWithinTarget).length;
    final averageMinutes = points.isEmpty
        ? 0
        : points.map((p) => p.screenTime.inMinutes).reduce((a, b) => a + b) ~/
              points.length;

    const targetFraction = 1 / 1.4;

    return AriaCard(
      eyebrow: 'Tren 7 hari',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colors.win.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$withinTarget/${points.length} hari terkendali',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.win,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AriaBarChart(
            data: [
              for (final point in points)
                AriaBarDatum(
                  label: point.date.shortWeekdayId,
                  value: point.fraction,
                  isHighlighted: point.date.isSameDayAs(today),
                  isOverTarget: !point.isWithinTarget,
                ),
            ],
            accentColor: colors.usageFill,
            mutedColor: colors.usageFill.withValues(alpha: 0.22),
            overColor: colors.over,
            targetFraction: targetFraction,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _LegendDot(color: colors.usageFill, label: 'Sesuai target'),
              const SizedBox(width: AppSpacing.md),
              _LegendDot(color: colors.over, label: 'Lewat target'),
              const Spacer(),
              Text(
                'Rata-rata ${Duration(minutes: averageMinutes).compact}/hari',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
