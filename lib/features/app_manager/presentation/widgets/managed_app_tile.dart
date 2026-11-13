import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/aria_semantic_colors.dart';
import '../../../../core/utils/duration_x.dart';
import '../../domain/entities/managed_app.dart';
import 'app_usage_ring.dart';

/// One row in the App Manager list.
///
/// The ring shows usage at a glance; the two-line subtitle answers "how much
/// left?" and "how many times opened?" without needing a detail screen.
class ManagedAppTile extends StatelessWidget {
  const ManagedAppTile({
    super.key,
    required this.app,
    required this.onTap,
    this.onToggle,
  });

  final ManagedApp app;
  final VoidCallback onTap;

  /// Called when the inline switch is flipped. Null hides the switch.
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = app.fractionOfQuota;

    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              _AppTileIcon(app: app),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      app.appName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    _Subtitle(app: app, fraction: fraction),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (fraction != null)
                AppUsageRing(fraction: fraction, overQuota: app.isOverQuota)
              else
                Text(
                  app.usedToday.compact,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (onToggle != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Switch.adaptive(
                  value: app.isLimitActive,
                  onChanged: app.hasLimit ? onToggle : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.app, required this.fraction});

  final ManagedApp app;
  final double? fraction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;

    if (!app.hasLimit) {
      return Text(
        '${app.usedToday.compact} · belum ada batas',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final (String text, Color color) = app.isOverQuota
        ? (
            'Lewat ${(app.usedToday - app.quota!).compact} dari batas',
            colors.over,
          )
        : app.isNearQuota
        ? ('Sisa ${app.remaining!.compact} lagi', theme.colorScheme.secondary)
        : (
            'Sisa ${app.remaining!.compact} dari ${app.quota!.compact}',
            theme.colorScheme.onSurfaceVariant,
          );

    return Row(
      children: [
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
        if (!app.isLimitActive) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            '· nonaktif',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}

class _AppTileIcon extends StatelessWidget {
  const _AppTileIcon({required this.app});

  final ManagedApp app;

  IconData get _icon => switch (app.category) {
    AppCategory.social => Icons.groups_outlined,
    AppCategory.video => Icons.play_circle_outline_rounded,
    AppCategory.game => Icons.sports_esports_outlined,
    AppCategory.productivity => Icons.checklist_rounded,
    AppCategory.messaging => Icons.chat_outlined,
    AppCategory.other => Icons.apps_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = app.iconPng;
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: SizedBox(
        width: 48,
        height: 48,
        child: icon == null
            ? ColoredBox(
                color: theme.colorScheme.surfaceContainerHigh,
                child: Icon(
                  _icon,
                  size: 22,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : Image.memory(
                icon,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: theme.colorScheme.surfaceContainerHigh,
                  child: Icon(
                    _icon,
                    size: 22,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
      ),
    );
  }
}
