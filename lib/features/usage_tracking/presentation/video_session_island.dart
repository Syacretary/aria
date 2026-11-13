import 'package:flutter/material.dart';

/// Small in-app floating island for an ARIA-owned shorts/feed experience.
/// It deliberately uses a Flutter [Overlay], not an Android system overlay:
/// external-app overlays require a separate, explicit user opt-in and must
/// never be used to infer private feed content.
class VideoSessionIsland extends StatelessWidget {
  const VideoSessionIsland({required this.videosAdvanced, super.key});

  final int videosAdvanced;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: '$videosAdvanced video telah dilewati pada sesi ini',
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xEE201D2B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.swipe_up_alt_rounded,
              color: Color(0xFFFFD36E),
              size: 19,
            ),
            const SizedBox(width: 8),
            Text(
              '$videosAdvanced video sesi ini',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
