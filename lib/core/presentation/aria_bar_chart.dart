import 'package:flutter/material.dart';

import '../motion/aria_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// A single bar in an [AriaBarChart].
class AriaBarDatum {
  const AriaBarDatum({
    required this.label,
    required this.value,
    this.isHighlighted = false,
    this.isOverTarget = false,
  });

  /// Short axis label, e.g. "Sen".
  final String label;

  /// Normalised value in `[0, 1]`.
  final double value;

  /// Today. Gets the accent and a slightly wider bar.
  final bool isHighlighted;

  /// Days over the screentime target render in the concern tint, so the chart
  /// answers "am I trending better?" without the user reading numbers.
  final bool isOverTarget;
}

/// Minimal bar chart drawn with plain widgets.
///
/// Dependency-free on purpose: seven bars need none of `fl_chart`'s weight, and
/// this keeps the growth animation on the shared house curve. Bars grow from the
/// baseline on first paint; the target line is drawn as a hairline behind them
/// so context is available without a legend.
class AriaBarChart extends StatelessWidget {
  const AriaBarChart({
    super.key,
    required this.data,
    this.height = 104,
    this.barWidth = 16,
    this.accentColor,
    this.mutedColor,
    this.overColor,
    this.targetFraction,
  });

  final List<AriaBarDatum> data;
  final double height;
  final double barWidth;
  final Color? accentColor;
  final Color? mutedColor;
  final Color? overColor;

  /// Where the daily target sits, as a fraction of the chart height. Drawn as a
  /// dashed hairline when provided.
  final double? targetFraction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? theme.colorScheme.primary;
    final muted =
        mutedColor ?? theme.colorScheme.primary.withValues(alpha: 0.22);
    final over = overColor ?? theme.colorScheme.error;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      letterSpacing: 0.2,
      fontWeight: FontWeight.w500,
    );

    // Reserved space for the axis labels, so bars and the target line use the
    // same coordinate space.
    const labelBand = 26.0;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          if (targetFraction != null)
            Positioned(
              left: 0,
              right: 0,
              top: (height - labelBand) * (1 - targetFraction!),
              child: CustomPaint(
                painter: _DashedLinePainter(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.30,
                  ),
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final datum in data)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: height - labelBand,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: _Bar(
                            fraction: datum.value.clamp(0.05, 1.0),
                            maxHeight: height - labelBand,
                            width: datum.isHighlighted
                                ? barWidth + 3
                                : barWidth,
                            color: datum.isOverTarget
                                ? over.withValues(alpha: 0.55)
                                : datum.isHighlighted
                                ? accent
                                : muted,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        datum.label,
                        style: datum.isHighlighted
                            ? labelStyle?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              )
                            : labelStyle,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.fraction,
    required this.maxHeight,
    required this.width,
    required this.color,
  });

  final double fraction;
  final double maxHeight;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction),
      duration: AriaMotion.chartEnter,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Container(
        width: width,
        height: maxHeight * value,
        decoration: BoxDecoration(
          color: color,
          // Fully rounded columns rather than squared-off bars: it matches the
          // pill language used everywhere else.
          borderRadius: AppRadius.pill,
        ),
      ),
    );
  }
}

/// Hairline dashed rule used for the target reference line.
class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
