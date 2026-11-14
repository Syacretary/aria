import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/presentation/aria_card.dart';
import '../../../../core/presentation/aria_empty_state.dart';
import '../../../../core/presentation/aria_loading.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/aria_semantic_colors.dart';
import '../../../../core/utils/date_x.dart';
import '../../domain/entities/win_entry.dart';
import '../providers/home_providers.dart';

/// Today's accomplishments card.
/// Minimalist celebration of user agency without clutter.
class TodaysWinsCard extends ConsumerWidget {
  const TodaysWinsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wins = ref.watch(todaysWinsProvider);

    return wins.when(
      loading: () => const AriaCard(
        eyebrow: 'Kemenangan hari ini',
        child: AriaSkeletonLines(lines: 2),
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
              icon: Icons.emoji_events_outlined,
              title: 'Belum ada kemenangan hari ini',
              message: 'Menahan satu godaan saja sudah dihitung sebagai langkah maju.',
            ),
          );
        }
        return _Content(wins: data);
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.wins});

  final List<WinEntry> wins;

  @override
  Widget build(BuildContext context) {
    final win = wins.first;
    final theme = Theme.of(context);
    final colors = context.ariaColors;

    return AriaCard(
      eyebrow: 'Kemenangan hari ini',
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.win.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              _iconFor(win.icon),
              size: 18,
              color: colors.win,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  win.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  win.detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              win.occurredAt.shortTimeId,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(WinKind kind) => switch (kind) {
    WinKind.delay => Icons.pause_circle_outline_rounded,
    WinKind.limitKept => Icons.verified_outlined,
    WinKind.offline => Icons.wifi_off_rounded,
    WinKind.focus => Icons.center_focus_strong_outlined,
    WinKind.prayer => Icons.self_improvement_rounded,
  };
}
