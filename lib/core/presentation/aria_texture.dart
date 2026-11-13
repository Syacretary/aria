import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/aria_semantic_colors.dart';

/// A fixed, non-interactive texture layer painted over the whole app.
///
/// Two things happen here, both from the design brief:
///
/// 1. **Ambient gradient** — three very large, very soft radial washes in
///    sunrise yellow, sage, and a dusty lilac. This gives ARIA the warm,
///    optimistic atmosphere of a calm companion without turning the page into
///    a high-contrast mesh gradient.
/// 2. **Grain** — a sparse noise field at ~3% opacity. Pure vector surfaces
///    feel sterile; a hint of grain gives the screen the quality of paper.
///
/// Performance: the grain field is generated once into an [Image] and painted
/// as a tiled shader, so this costs no per-frame work. The layer is
/// `IgnorePointer` and sits above content, which is why the noise also covers
/// cards rather than only the page background.
class AriaTextureLayer extends StatefulWidget {
  const AriaTextureLayer({
    super.key,
    required this.child,
    this.grainOpacity = 1,
  });

  final Widget child;

  /// Multiplier on the theme's grain colour alpha. Set to 0 to disable grain.
  final double grainOpacity;

  @override
  State<AriaTextureLayer> createState() => _AriaTextureLayerState();
}

class _AriaTextureLayerState extends State<AriaTextureLayer> {
  ui.Image? _grainTile;

  @override
  void initState() {
    super.initState();
    _generateGrainTile();
  }

  Future<void> _generateGrainTile() async {
    const size = 128;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final random = math.Random(20261107);

    // Sparse dots rather than per-pixel noise: cheaper to rasterise, and the
    // result tiles without visible seams.
    final paint = Paint();
    for (var i = 0; i < size * 3; i++) {
      final x = random.nextDouble() * size;
      final y = random.nextDouble() * size;
      final lightness = random.nextBool();
      paint.color = (lightness ? Colors.white : Colors.black).withValues(
        alpha: 0.5 + random.nextDouble() * 0.5,
      );
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    if (!mounted) {
      image.dispose();
      return;
    }
    setState(() => _grainTile = image);
  }

  @override
  void dispose() {
    _grainTile?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _AriaTexturePainter(
                  grainTile: _grainTile,
                  grainColor: colors.grain.withValues(
                    alpha: colors.grain.a * widget.grainOpacity,
                  ),
                  ambient: isLight
                      ? const [
                          _AmbientOrb(
                            Alignment(-0.75, -1.05),
                            0.13,
                            Color(0xFFFFC95E),
                          ),
                          _AmbientOrb(
                            Alignment(1.15, 0.28),
                            0.09,
                            Color(0xFFB9ADE8),
                          ),
                          _AmbientOrb(
                            Alignment(-1.1, 0.95),
                            0.07,
                            Color(0xFF8FBFAD),
                          ),
                        ]
                      : const [
                          _AmbientOrb(
                            Alignment(-0.75, -1.05),
                            0.13,
                            Color(0xFFD3A13F),
                          ),
                          _AmbientOrb(
                            Alignment(1.15, 0.28),
                            0.12,
                            Color(0xFF7565A6),
                          ),
                          _AmbientOrb(
                            Alignment(-1.1, 0.95),
                            0.09,
                            Color(0xFF4A7C6F),
                          ),
                        ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AmbientOrb {
  const _AmbientOrb(this.alignment, this.opacity, this.color);

  final Alignment alignment;
  final double opacity;
  final Color color;
}

class _AriaTexturePainter extends CustomPainter {
  _AriaTexturePainter({
    required this.grainTile,
    required this.grainColor,
    required this.ambient,
  });

  final ui.Image? grainTile;
  final Color grainColor;
  final List<_AmbientOrb> ambient;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Ambient washes. Drawn first so everything above sits in that light.
    for (final orb in ambient) {
      final center = Alignment.lerp(Alignment.center, orb.alignment, 1)!;
      final focal = center.withinRect(Offset.zero & size);
      final radius = size.shortestSide * 0.95;

      final shader = RadialGradient(
        colors: [
          orb.color.withValues(alpha: orb.opacity),
          orb.color.withValues(alpha: 0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: focal, radius: radius));

      canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
    }

    // 2. Grain, tiled.
    final tile = grainTile;
    if (tile == null || grainColor.a == 0) return;

    final shader = ImageShader(
      tile,
      TileMode.repeated,
      TileMode.repeated,
      Matrix4.identity().storage,
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..color = grainColor,
    );
  }

  @override
  bool shouldRepaint(_AriaTexturePainter old) =>
      old.grainTile != grainTile ||
      old.grainColor != grainColor ||
      old.ambient != ambient;
}
