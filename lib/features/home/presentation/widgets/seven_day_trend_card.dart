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
///
/// Bars over target are tinted with the concern colour and a dashed hairline
/// marks the target itself, so the chart answers "am I trending better?" at a
/// glance without the user reading a single number.
class SevenDayTrendCard extends ConsumerWidget {
  const SevenDayTrendCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend = ref.watch(weeklyTrendProvider);

    return trend.when(
      loading: () => const AriaCard(
        eyebrow: 'Tren',
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

    // The target as a fraction of the chart ceiling (target * 1.4), matching
    // TrendPoint.fraction so bars and the line agree on scale.
    const targetFraction = 1 / 1.4;

    return AriaCard(
      eyebrow: 'Tren 7 hari',
      title: '$withinTarget dari ${points.length} hari sesuai target',
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
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _LegendDot(color: colors.usageFill, label: 'Sesuai target'),
              const SizedBox(width: AppSpacing.lg),
              _LegendDot(color: colors.over, label: 'Lewat target'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Rata-rata ${Duration(minutes: averageMinutes).inWordsId} per hari',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A tiny colour key. Replaces a full legend: two dots and two words.
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
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 0.2,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
