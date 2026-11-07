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

/// Today's accomplishments.
///
/// Framed as choices the user made ("Menunda TikTok") rather than scores, so the
/// card reinforces agency. The empty state is an invitation, not a failure.
class TodaysWinsCard extends ConsumerWidget {
  const TodaysWinsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wins = ref.watch(todaysWinsProvider);

    return wins.when(
      loading: () => const AriaCard(
        eyebrow: 'Kemenangan hari ini',
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
              icon: Icons.emoji_events_outlined,
              title: 'Belum ada kemenangan hari ini',
              message: 'Menahan satu godaan saja sudah dihitung.',
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
    final colors = context.ariaColors;
    return AriaCard(
      eyebrow: 'Kemenangan hari ini',
      title: '${wins.length} hal yang kamu jaga',
      child: Column(
        children: [
          for (var i = 0; i < wins.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(color: colors.hairline, height: 1),
              ),
            _WinRow(win: wins[i]),
          ],
        ],
      ),
    );
  }
}

class _WinRow extends StatelessWidget {
  const _WinRow({required this.win});

  final WinEntry win;

  IconData get _icon => switch (win.icon) {
    WinKind.delay => Icons.pause_circle_outline_rounded,
    WinKind.limitKept => Icons.verified_outlined,
    WinKind.offline => Icons.wifi_off_rounded,
    WinKind.focus => Icons.center_focus_strong_outlined,
    WinKind.prayer => Icons.self_improvement_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colors.win.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Icon(_icon, size: 17, color: colors.win),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                win.label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '${win.detail} · ${win.occurredAt.shortTimeId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
