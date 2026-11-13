import 'package:flutter/material.dart';

import '../../../../core/theme/aria_semantic_colors.dart';

/// The friendly visual anchor shared by Beranda and the conversation page.
class AriaOrb extends StatelessWidget {
  const AriaOrb({super.key, this.size = 112, this.showFace = true});

  final double size;
  final bool showFace;

  @override
  Widget build(BuildContext context) {
    final companion = context.ariaColors.companion;
    return Semantics(
      image: true,
      label: 'ARIA, pendamping digital',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.32, -0.45),
            radius: 0.9,
            colors: [
              Colors.white.withValues(alpha: 0.98),
              const Color(0xFFFFD36E).withValues(alpha: 0.8),
              companion.withValues(alpha: 0.74),
              const Color(0xFFC1B2EC).withValues(alpha: 0.72),
            ],
            stops: const [0, 0.32, 0.68, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: companion.withValues(alpha: 0.2),
              blurRadius: size * 0.32,
              spreadRadius: size * 0.02,
            ),
          ],
        ),
        child: showFace
            ? Icon(
                Icons.sentiment_satisfied_alt_rounded,
                size: size * 0.42,
                color: Theme.of(context).colorScheme.onSurface,
              )
            : null,
      ),
    );
  }
}
