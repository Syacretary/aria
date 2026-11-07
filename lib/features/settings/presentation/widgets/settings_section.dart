import 'package:flutter/material.dart';

import '../../../../core/motion/aria_tap.dart';
import '../../../../core/presentation/aria_card.dart';
import '../../../../core/presentation/aria_section_header.dart';
import '../../../../core/theme/app_spacing.dart';

/// A titled group of settings rows.
///
/// Rows stack inside one nested card with hairline dividers, so a section reads
/// as a single surface rather than a pile of separate cards.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.caption,
    this.icon,
  });

  final String title;
  final String? caption;
  final List<Widget> children;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AriaSectionHeader(title: title, caption: caption, icon: icon),
        AriaCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: AppSpacing.xl,
                    endIndent: AppSpacing.xl,
                    color: theme.colorScheme.outlineVariant,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A single label/value row with an optional trailing widget.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    this.value,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String? value;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return AriaTap.button(onTap: onTap, child: content);
  }
}
