import 'package:flutter/material.dart';

import '../motion/aria_tap.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/aria_semantic_colors.dart';

/// The base surface for every block of content in ARIA.
///
/// Built with the **Double-Bezel** technique: a nested outer shell holding an
/// inner core, the way a glass plate sits in a machined aluminium tray. The two
/// curves are concentric — the inner radius is derived from the outer radius
/// minus the shell inset, so the gap is visually even all the way round.
///
/// Three details do the heavy lifting:
/// - the outer shell is a *whisper* of tint ([AriaSemanticColors.shellWash]),
///   not a border, so the card reads as depth rather than as a box;
/// - the inner core carries a 1px top highlight, which is what makes the
///   surface look lit from above instead of painted flat;
/// - the shadow is tinted and wide, never black and tight.
class AriaCard extends StatelessWidget {
  const AriaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.color,
    this.onTap,
    this.trailing,
    this.leading,
    this.title,
    this.eyebrow,
    this.accent,
    this.inset = AppSpacing.shellInset,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Inner core colour. Defaults to the raised surface for the theme.
  final Color? color;

  /// Makes the whole card tappable with the standard ARIA press feel.
  final VoidCallback? onTap;

  final Widget? trailing;
  final Widget? leading;

  /// Card title, rendered in the title style.
  final String? title;

  /// Micro-label above the title. Sentence case, tracked out.
  final String? eyebrow;

  /// Optional accent used for the inner core's fill. Passing this switches the
  /// card into its "highlighted" variant.
  final Color? accent;

  /// Shell inset thickness. Larger values read as a thicker tray.
  final double inset;

  /// When true, clips content to the inner radius. Use for cards whose child
  /// paints to its own edges (charts, images).
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;

    final core = DecoratedBox(
      decoration: BoxDecoration(
        color: accent ?? color ?? theme.colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.inner(shellPadding: inset),
        boxShadow: AppShadows.innerHighlight(theme.brightness),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (eyebrow != null ||
                title != null ||
                trailing != null ||
                leading != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: AppSpacing.md),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (eyebrow != null) ...[
                            Text(
                              eyebrow!.toUpperCase(),
                              style: theme.textTheme.labelSmall,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                          ],
                          if (title != null)
                            Text(title!, style: theme.textTheme.titleMedium),
                        ],
                      ),
                    ),
                    ?trailing,
                  ],
                ),
              ),
            child,
          ],
        ),
      ),
    );

    final innerRadius = AppRadius.inner(shellPadding: inset);

    final shell = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.shellWash,
        borderRadius: AppRadius.shellBorder,
        // Only the first, daily summary card owns a visible outline. Other
        // cards rely on surface contrast and spacing for grouping.
        border: eyebrow == 'Hari ini'
            ? Border.all(color: colors.hairline)
            : null,
        boxShadow: AppShadows.raised(theme.brightness),
      ),
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: clip
            ? ClipRRect(borderRadius: innerRadius, child: core)
            : DecoratedBox(
                decoration: BoxDecoration(borderRadius: innerRadius),
                child: core,
              ),
      ),
    );

    if (onTap == null) return shell;
    return AriaTap.card(onTap: onTap, child: shell);
  }
}

/// A quieter sibling of [AriaCard] for content that should not compete with the
/// data cards — used inside sheets and for secondary groupings.
class AriaInsetPanel extends StatelessWidget {
  const AriaInsetPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadius.inner(),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
