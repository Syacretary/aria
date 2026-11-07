import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Page-level scaffold used by every tab.
///
/// The header is deliberately asymmetric: the title block sits left, actions
/// sit right, and the subtitle is small and muted. There is no app bar chrome —
/// the title is part of the page, which is what makes the layout feel editorial
/// rather than like a stock Material screen.
class AriaScaffold extends StatelessWidget {
  const AriaScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.bottomBar,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget child;
  final Widget? floatingActionButton;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // Transparent so the texture layer underneath shows through.
      backgroundColor: Colors.transparent,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.xl,
                AppSpacing.pageGutter,
                AppSpacing.lg,
              ),
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
                        Text(title, style: theme.textTheme.headlineMedium),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
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
                  if (actions != null)
                    Row(mainAxisSize: MainAxisSize.min, children: actions!),
                ],
              ),
            ),
            Expanded(child: child),
            ?bottomBar,
          ],
        ),
      ),
    );
  }
}
