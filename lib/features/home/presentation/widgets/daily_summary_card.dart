import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/presentation/aria_card.dart';
import '../../../../core/presentation/aria_loading.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/aria_semantic_colors.dart';
import '../../../../core/utils/duration_x.dart';
import '../../domain/entities/daily_summary.dart';
import '../providers/home_providers.dart';

/// Headline card: how many short videos were opened today, plus the daily
/// screen-time total.
///
/// The number is set at display size with tight tracking — it is the single most
/// important figure on the screen, so it earns the largest type in the app. The
/// delta badge is the emotional payload: is today calmer than yesterday?
class DailySummaryCard extends ConsumerWidget {
  const DailySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dailySummaryProvider);

    return summary.when(
      loading: () => const _Skeleton(),
      error: (error, _) => _Error(message: failureMessage(error)),
      data: (data) => _Content(data: data),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.data});

  final DailySummary data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;
    final calmer = data.isCalmerThanYesterday;

    return CustomPaint(
      foregroundPainter: _GradientOutlinePainter(
        radius: AppRadius.shell,
        strokeWidth: 3,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.shellBorder,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFD36E), Color(0xFFFFFFFF), Color(0xFFC4B7EE)],
              stops: [0, 0.58, 1],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('HARI INI', style: theme.textTheme.labelSmall),
                  const Spacer(),
                  _DeltaBadge(ratio: data.videoDeltaRatio, lowerIsBetter: true),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${data.videosOpened}',
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'scroll video*',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '*perkiraan dari aplikasi yang didukung',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'Total layar',
                      value: data.totalScreenTime.compact,
                    ),
                  ),
                  Container(width: 1, height: 34, color: colors.hairline),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.lg),
                      child: _MiniStat(
                        label: 'Buka sosmed',
                        value: '${data.socialAppOpens}×',
                      ),
                    ),
                  ),
                ],
              ),
              if (calmer) ...[
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Icon(
                      Icons.trending_down_rounded,
                      size: 15,
                      color: colors.win,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Lebih tenang dari kemarin. Pertahankan ritmenya.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.win,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientOutlinePainter extends CustomPainter {
  const _GradientOutlinePainter({
    required this.radius,
    required this.strokeWidth,
  });

  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD8A638), Color(0xFF9476C2)],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(strokeWidth / 2),
        Radius.circular(radius),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GradientOutlinePainter oldDelegate) =>
      radius != oldDelegate.radius || strokeWidth != oldDelegate.strokeWidth;
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: theme.textTheme.titleLarge),
      ],
    );
  }
}

/// "21% lebih sedikit dari kemarin" compressed into a pill badge.
class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.ratio, required this.lowerIsBetter});

  final double ratio;
  final bool lowerIsBetter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;

    if (ratio == 0) {
      return Text('Sama seperti kemarin', style: theme.textTheme.bodySmall);
    }

    final isUp = ratio > 0;
    final isGood = lowerIsBetter ? !isUp : isUp;
    final color = isGood ? colors.win : colors.over;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            '${(ratio.abs() * 100).round()}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return const AriaCard(
      eyebrow: 'Hari ini',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AriaSkeleton(width: 120, height: 40, radius: 12),
          SizedBox(height: AppSpacing.xl),
          AriaSkeletonLines(lines: 2),
          SizedBox(height: AppSpacing.md),
          Text('Menyiapkan ringkasan penggunaanmu…'),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AriaCard(
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: theme.colorScheme.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
