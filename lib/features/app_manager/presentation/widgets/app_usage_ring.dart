import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/motion/aria_motion.dart';
import '../../../../core/theme/aria_semantic_colors.dart';

/// Circular usage indicator for one app.
///
/// Reads at a glance: the arc fills clockwise in the sage accent, turns ochre at
/// 80%, and terracotta once over quota. A hairline inner circle gives the ring
/// depth without introducing a second colour.
class AppUsageRing extends StatelessWidget {
  const AppUsageRing({
    super.key,
    required this.fraction,
    this.size = 54,
    this.strokeWidth = 5,
    this.label,
    this.overQuota = false,
  });

  /// Usage as a fraction of quota; may exceed 1.0 when over.
  final double fraction;
  final double size;
  final double strokeWidth;
  final String? label;
  final bool overQuota;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ariaColors;

    final color = overQuota
        ? colors.over
        : fraction >= 0.8
        ? theme.colorScheme.secondary
        : colors.usageFill;

    // Cap the drawn arc at one full turn; overflow is communicated by colour
    // and the label rather than by wrapping the ring around again.
    final swept = fraction.clamp(0.0, 1.0) * 2 * math.pi;

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: swept),
        duration: AriaMotion.chartEnter,
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => CustomPaint(
          painter: _RingPainter(
            progress: value,
            trackColor: colors.usageTrack,
            fillColor: color,
            strokeWidth: strokeWidth,
          ),
          child: Center(
            child: Text(
              label ?? '${(fraction.clamp(0.0, 9.99) * 100).round()}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: size < 48 ? 9 : 10,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2 - 1;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final inner = Paint()
      ..color = trackColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - strokeWidth, inner);

    if (progress <= 0) return;

    final fill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, progress, false, fill);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.fillColor != fillColor ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
