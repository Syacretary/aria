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

/// Headline card: video scroll count, screen time, and app opens.
/// Framed with a warm gold-to-cream gradient & deeper contour outline
/// to stand out as the primary focal point on the home feed.
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
      foregroundPainter: const _GradientOutlinePainter(
        radius: AppRadius.shell,
        strokeWidth: 2.8,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.shellBorder,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFD778), // Warm radiant golden amber
                Color(0xFFFFFFFF), // Crisp center reflection
                Color(0xFFEFE5CF), // Warm cream / ivory
              ],
              stops: [0.0, 0.52, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Label & Delta
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      'HARI INI',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _DeltaBadge(ratio: data.videoDeltaRatio, lowerIsBetter: true),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Main Metric: Video Scroll Count
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${data.videosOpened}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'scroll video',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Secondary Metrics: Screen Time & Social Opens
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.access_time_rounded,
                      label: 'Total layar',
                      value: data.totalScreenTime.compact,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.touch_app_outlined,
                      label: 'Buka sosmed',
                      value: '${data.socialAppOpens}×',
                    ),
                  ),
                ],
              ),

              // Calmer acknowledgment badge
              if (calmer) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.win.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_down_rounded,
                        size: 16,
                        color: colors.win,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Lebih tenang dari kemarin. Pertahankan ritmenya.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.win,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Outline painter with deeper golden-bronze gradient for high contrast focus.
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
        colors: [
          Color(0xFFD8A638), // Darker golden amber
          Color(0xFF9A783E), // Deep warm bronze / sage
        ],
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact pill badge indicating comparison with yesterday.
class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.ratio, required this.lowerIsBetter});

  final double ratio;
  final bool lowerIsBetter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;

    if (ratio == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Sama spt kemarin',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final isUp = ratio > 0;
    final isGood = lowerIsBetter ? !isUp : isUp;
    final color = isGood ? colors.win : colors.over;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.8,
        ),
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
            '${(ratio.abs() * 100).round()}% ${isGood ? 'lebih tenang' : 'lebih ramai'}',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AriaSkeleton(width: 80, height: 20, radius: 6),
          SizedBox(height: AppSpacing.lg),
          AriaSkeleton(width: 140, height: 38, radius: 10),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: AriaSkeleton(height: 48, radius: 8)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: AriaSkeleton(height: 48, radius: 8)),
            ],
          ),
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
