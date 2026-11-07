import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// A microscopic label used above a group of cards or list items.
///
/// Uppercase with wide tracking — the one place in the app where all-caps is
/// appropriate, because at this size and weight it reads as a classification
/// tag rather than as shouting.
class AriaSectionHeader extends StatelessWidget {
  const AriaSectionHeader({
    super.key,
    required this.title,
    this.caption,
    this.trailing,
    this.icon,
  });

  final String title;
  final String? caption;
  final Widget? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        right: AppSpacing.xs,
        bottom: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '· $caption',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ),
          ] else
            const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

/// The pill-shaped micro badge that precedes a heading or labels a state.
///
/// Replaces the round "New"/"Beta" badges the audit flags as generic: this one
/// is a pill, sentence case, and only used where a state genuinely needs a
/// visible marker.
class AriaTag extends StatelessWidget {
  const AriaTag({super.key, required this.label, this.color, this.icon});

  final String label;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = color ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: tint),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: tint,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
