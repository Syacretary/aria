import 'package:flutter/material.dart';

import '../../../../core/motion/aria_tap.dart';
import '../../../../core/presentation/aria_card.dart';
import '../../../../core/presentation/aria_section_header.dart';
import '../../../../core/theme/app_spacing.dart';

/// A clean, minimalist icon container for settings rows.
class SettingsIcon extends StatelessWidget {
  const SettingsIcon({
    super.key,
    required this.icon,
    this.color,
    this.backgroundColor,
  });

  final IconData icon;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.primary;
    final bgColor = backgroundColor ?? iconColor.withValues(alpha: 0.12);

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: iconColor),
    );
  }
}

/// A titled group of settings rows with clean dividers.
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
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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

/// A single minimalist label/value row with an optional trailing widget.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    this.value,
    this.subtitle,
    this.labelColor,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String? value;
  final String? subtitle;
  final Color? labelColor;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 12,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: labelColor ?? theme.colorScheme.onSurface,
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
          if (value != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              value!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.xs),
            trailing!,
          ] else if (onTap != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return AriaTap.button(onTap: onTap, child: content);
  }
}
