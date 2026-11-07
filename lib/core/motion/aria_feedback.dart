import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'aria_haptics.dart';
import 'aria_motion.dart';

/// Consistent, quiet feedback for transient messages.
///
/// Uses a floating SnackBar with the ARIA radius and a light haptic, so
/// success/warning/info messages never feel like an alarm. Reach for these
/// instead of calling `ScaffoldMessenger` directly.
abstract final class AriaFeedback {
  /// Something worked. Light tap haptic.
  static void success(BuildContext context, String message) =>
      _show(context, message, _Tone.success);

  /// Something needs attention but is not an error. Light tap haptic.
  static void warning(BuildContext context, String message) =>
      _show(context, message, _Tone.warning);

  /// Neutral information. No haptic.
  static void info(BuildContext context, String message) =>
      _show(context, message, _Tone.info);

  static void _show(BuildContext context, String message, _Tone tone) {
    switch (tone) {
      case _Tone.success:
        AriaHaptics.success();
      case _Tone.warning:
        AriaHaptics.warning();
      case _Tone.info:
        AriaHaptics.silent();
    }

    final theme = Theme.of(context);
    final accent = switch (tone) {
      _Tone.success => theme.colorScheme.tertiary,
      _Tone.warning => theme.colorScheme.secondary,
      _Tone.info => theme.colorScheme.primary,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              // A thin accent stripe rather than a colored fill keeps the
              // message calm while still reading as success/warning/info.
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.colorScheme.inverseSurface,
          showCloseIcon: false,
          duration: AriaMotion.deliberate * 6,
          margin: const EdgeInsets.all(AppSpacing.lg),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.shellBorder,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      );
  }
}

enum _Tone { success, warning, info }
