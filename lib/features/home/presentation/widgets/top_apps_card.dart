import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/motion/aria_motion.dart';
import '../../../../core/presentation/aria_card.dart';
import '../../../../core/presentation/aria_empty_state.dart';
import '../../../../core/presentation/aria_loading.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/aria_semantic_colors.dart';
import '../../../../core/utils/duration_x.dart';
import '../../domain/entities/top_app_usage.dart';
import '../providers/home_providers.dart';

/// Screen time per app — exactly three rows, busiest first.
/// Streamlined and visually focused on duration and proportional usage.
class TopAppsCard extends ConsumerWidget {
  const TopAppsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(topAppsProvider);

    return apps.when(
      loading: () => const AriaCard(
        eyebrow: 'Aplikasi terbanyak digunakan',
        child: AriaSkeletonLines(lines: 3),
      ),
      error: (error, _) => AriaCard(
        child: Text(
          failureMessage(error),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (data) {
        if (data.isEmpty) {
          return const AriaCard(
            child: AriaEmptyState(
              compact: true,
              icon: Icons.apps_rounded,
              title: 'Belum ada data pemakaian',
              message: 'Aktifkan izin akses pemakaian di Pengaturan.',
            ),
          );
        }
        return _Content(apps: data);
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.apps});

  final List<TopAppUsage> apps;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final busiest = apps.first.screenTime;

    return AriaCard(
      eyebrow: 'Aplikasi terbanyak digunakan',
      trailing: TextButton(
        onPressed: () => context.go(Routes.appManager),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('Kelola'),
      ),
      child: Column(
        children: [
          for (var i = 0; i < apps.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md + 2),
            _AppRow(
              app: apps[i],
              rank: i + 1,
              fraction: apps[i].fractionAgainst(busiest),
              fillColor: colors.usageFill,
              trackColor: colors.usageTrack,
            ),
          ],
        ],
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow({
    required this.app,
    required this.rank,
    required this.fraction,
    required this.fillColor,
    required this.trackColor,
  });

  final TopAppUsage app;
  final int rank;
  final double fraction;
  final Color fillColor;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: rank == 1
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: rank == 1
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      app.appName,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (app.isLimited) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: colors.win,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              app.screenTime.compact,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _UsageBar(
          fraction: fraction,
          fillColor: fillColor,
          trackColor: trackColor,
        ),
      ],
    );
  }
}

class _UsageBar extends StatelessWidget {
  const _UsageBar({
    required this.fraction,
    required this.fillColor,
    required this.trackColor,
  });

  final double fraction;
  final Color fillColor;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 5,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(color: trackColor.withValues(alpha: 0.4)),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: fraction),
                  duration: AriaMotion.chartEnter,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => Container(
                    width: constraints.maxWidth * value,
                    color: fillColor,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
