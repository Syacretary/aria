import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/motion/aria_motion.dart';
import '../../../../core/presentation/aria_card.dart';
import '../../../../core/presentation/aria_empty_state.dart';
import '../../../../core/presentation/aria_loading.dart';
import '../../../../core/presentation/aria_section_header.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/aria_semantic_colors.dart';
import '../../../../core/utils/duration_x.dart';
import '../../domain/entities/top_app_usage.dart';
import '../providers/home_providers.dart';

/// Screen time per app — exactly three rows, busiest first.
///
/// Capped at three on purpose: a longer list turns a nudge into a dashboard, and
/// the full picture lives in App Manager.
class TopAppsCard extends ConsumerWidget {
  const TopAppsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(topAppsProvider);

    return apps.when(
      loading: () => const AriaCard(
        eyebrow: 'Paling banyak dipakai',
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
      eyebrow: 'Paling banyak dipakai',
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
            if (i > 0) const SizedBox(height: AppSpacing.xl),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _AppMark(rank: rank),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          app.appName,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (app.isLimited) ...[
                        const SizedBox(width: AppSpacing.sm),
                        AriaTag(
                          label: 'dibatasi',
                          color: context.ariaColors.win,
                          icon: Icons.shield_outlined,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${app.sessionCount}× buka · rata-rata '
                    '${app.averageSession.compact}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(app.screenTime.compact, style: theme.textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _UsageBar(
          fraction: fraction,
          fillColor: fillColor,
          trackColor: trackColor,
        ),
      ],
    );
  }
}

/// The app mark: a squircle carrying the rank, so each row shows its own
/// ordering instead of a generic letter avatar.
class _AppMark extends StatelessWidget {
  const _AppMark({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFirst = rank == 1;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isFirst
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: theme.textTheme.titleMedium?.copyWith(
          color: isFirst
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
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
      borderRadius: AppRadius.pill,
      child: SizedBox(
        height: 5,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(color: trackColor),
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
