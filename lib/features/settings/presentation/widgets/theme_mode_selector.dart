import 'package:flutter/material.dart';

import '../../../../core/motion/aria_haptics.dart';
import '../../../../core/motion/aria_motion.dart';
import '../../../../core/motion/aria_tap.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// System / Light / Dark selector.
///
/// One travelling pill behind three cells instead of three separate toggles, so
/// the control reads as a single physical switch. Icons carry the meaning; the
/// labels sit underneath at micro size so the row still works at a glance.
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  static const List<(ThemeMode, String, IconData)> _options = [
    (ThemeMode.system, 'Sistem', Icons.brightness_auto_outlined),
    (ThemeMode.light, 'Terang', Icons.light_mode_outlined),
    (ThemeMode.dark, 'Gelap', Icons.dark_mode_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rawIndex = _options.indexWhere((o) => o.$1 == mode);
    final index = rawIndex < 0 ? 0 : rawIndex;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: AppRadius.pill,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final segmentWidth = constraints.maxWidth / _options.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: AriaMotion.medium,
                  curve: Curves.easeOutCubic,
                  left: index * segmentWidth,
                  width: segmentWidth,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: AppRadius.pill,
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < _options.length; i++)
                      Expanded(
                        child: AriaTap.button(
                          onTap: () {
                            if (mode == _options[i].$1) return;
                            AriaHaptics.selection();
                            onChanged(_options[i].$1);
                          },
                          borderRadius: AppRadius.pill,
                          semanticLabel: _options[i].$2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  _options[i].$3,
                                  size: 19,
                                  color: i == index
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _options[i].$2,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: i == index
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onSurfaceVariant,
                                    letterSpacing: 0.2,
                                    fontWeight: i == index
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
