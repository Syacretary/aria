import 'package:flutter/material.dart';

import '../motion/aria_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Skeleton placeholder with a slow shimmer.
///
/// ARIA never shows a spinner in content areas; a skeleton that mirrors the
/// final layout keeps the page from jumping when data lands.
class AriaSkeleton extends StatefulWidget {
  const AriaSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = AppRadius.sm,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<AriaSkeleton> createState() => _AriaSkeletonState();
}

class _AriaSkeletonState extends State<AriaSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AriaMotion.shimmer,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    final highlight = theme.colorScheme.surfaceContainerLow;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 - 2 * (1 - t), 0),
              end: Alignment(1 - 2 * (1 - t), 0),
              colors: [base, highlight, base],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
  }
}

/// A stack of skeleton lines sized like a paragraph of text.
class AriaSkeletonLines extends StatelessWidget {
  const AriaSkeletonLines({
    super.key,
    this.lines = 3,
    this.lineHeight = 12,
    this.spacing = AppSpacing.sm,
    this.lastLineFraction = 0.6,
  });

  final int lines;
  final double lineHeight;
  final double spacing;
  final double lastLineFraction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < lines; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              AriaSkeleton(
                height: lineHeight,
                width: i == lines - 1
                    ? constraints.maxWidth * lastLineFraction
                    : constraints.maxWidth,
              ),
            ],
          ],
        );
      },
    );
  }
}
