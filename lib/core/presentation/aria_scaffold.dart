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
    this.backgroundColor,
    this.withAmbientGlow = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget child;
  final Widget? floatingActionButton;
  final Widget? bottomBar;
  final Color? backgroundColor;
  final bool withAmbientGlow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          if (withAmbientGlow)
            const Positioned(
              top: -280,
              left: -70,
              right: -70,
              child: IgnorePointer(
                child: _AriaScaffoldAmbientGlow(),
              ),
            ),
          SafeArea(
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
                      ] else if (canPop) ...[
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
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
        ],
      ),
    );
  }
}

class _AriaScaffoldAmbientGlow extends StatelessWidget {
  const _AriaScaffoldAmbientGlow();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      height: 540,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(0, -0.35),
          colors: isLight
              ? const [
                  Color(0xB3FFFFFF),
                  Color(0x99FFD36E),
                  Color(0x55C4B7EE),
                  Color(0x00C4B7EE),
                ]
              : const [
                  Color(0x22FFFFFF),
                  Color(0x18FFD36E),
                  Color(0x15C4B7EE),
                  Color(0x00C4B7EE),
                ],
          stops: const [0, 0.32, 0.68, 1],
        ),
      ),
    );
  }
}
