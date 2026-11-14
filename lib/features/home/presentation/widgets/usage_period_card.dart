import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/motion/aria_haptics.dart';
import '../../../../core/motion/aria_motion.dart';
import '../../../../core/motion/aria_tap.dart';
import '../../../../core/presentation/aria_card.dart';
import '../../../../core/presentation/aria_loading.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/aria_semantic_colors.dart';
import '../../domain/entities/period_stats.dart';
import '../providers/home_providers.dart';

/// Harian / Mingguan / Bulanan social-app open counts.
/// Clean, minimal, and instantly clear with visual comparisons.
class UsagePeriodCard extends ConsumerStatefulWidget {
  const UsagePeriodCard({super.key});

  @override
  ConsumerState<UsagePeriodCard> createState() => _UsagePeriodCardState();
}

class _UsagePeriodCardState extends ConsumerState<UsagePeriodCard> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final breakdown = ref.watch(periodBreakdownProvider);

    return breakdown.when(
      loading: () => const AriaCard(
        eyebrow: 'Frekuensi buka sosmed',
        child: AriaSkeletonLines(lines: 3),
      ),
      error: (error, _) => AriaCard(
        child: Text(
          failureMessage(error),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (data) => _Content(
        breakdown: data,
        selected: _selected,
        onSelect: (index) {
          if (index == _selected) return;
          AriaHaptics.selection();
          setState(() => _selected = index);
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.breakdown,
    required this.selected,
    required this.onSelect,
  });

  final PeriodBreakdown breakdown;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;
    final stat = breakdown.all[selected];
    final isUp = stat.deltaRatio > 0;
    final deltaColor = isUp ? colors.over : colors.win;

    return AriaCard(
      eyebrow: 'Frekuensi buka sosmed',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Switcher
          _SegmentedControl(
            labels: breakdown.all.map((s) => s.label).toList(growable: false),
            selected: selected,
            onSelect: onSelect,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Main Stat & Comparison Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${stat.opens}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'kali',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: deltaColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 13,
                      color: deltaColor,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${(stat.deltaRatio.abs() * 100).round()}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: deltaColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Periode sebelumnya: ${stat.previousOpens}×',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: AppRadius.pill,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / labels.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: AriaMotion.medium,
                curve: Curves.easeOutCubic,
                left: selected * segmentWidth,
                width: segmentWidth,
                top: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: AppRadius.pill,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: AriaTap.button(
                        onTap: () => onSelect(i),
                        borderRadius: AppRadius.pill,
                        semanticLabel: labels[i],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm - 2,
                          ),
                          child: Text(
                            labels[i],
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: i == selected
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: i == selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
