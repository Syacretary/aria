import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Shown when a list or card has nothing to display.
///
/// Calm and non-apologetic: an empty state in ARIA is an invitation, not an
/// error. Optional [action] renders a single button beneath the copy.
class AriaEmptyState extends StatelessWidget {
  const AriaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  /// Tighter layout for use inside a card rather than a full page.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = compact ? AppSpacing.md : AppSpacing.xxl;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: spacing,
        horizontal: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: compact ? 20 : 26,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}
