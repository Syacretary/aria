import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'aria_haptics.dart';
import 'aria_motion.dart';

/// The only sanctioned way to open a bottom sheet in ARIA.
///
/// Calling `showModalBottomSheet` directly is caught by the
/// `no_raw_bottom_sheet` lint rule, which is what makes the interaction
/// principle impossible to forget: every sheet in the app — present and
/// future — slides up the same gentle way.
///
/// Behaviour:
/// - Slides in from the bottom with a soft spring landing ([AriaMotion.softSpring]).
/// - Leaves faster than it enters ([AriaMotion.sheetExit]) so dismissal feels
///   responsive.
/// - Height is content-driven, never a fixed slab, so it reads as "light".
/// - Generous top radius, soft scrim, drag-to-dismiss enabled.
/// - Fires a light haptic on open.
class AriaSheet {
  AriaSheet._();

  /// Opens a sheet and resolves with whatever the sheet pops.
  ///
  /// [builder] receives a context whose `Navigator` root is the sheet itself,
  /// so use the provided `sheetContext` for any nested navigation.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool enableDrag = true,
    bool isDismissible = true,
    bool useSafeArea = true,
    bool haptic = true,
    Color? barrierColor,
  }) {
    if (haptic) {
      unawaited(AriaHaptics.tap());
    }

    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.42),
      transitionDuration: reduceMotion ? Duration.zero : AriaMotion.slow,
      pageBuilder: (dialogContext, _, _) {
        return _AriaSheetSurface(
          isScrollControlled: isScrollControlled,
          enableDrag: enableDrag,
          useSafeArea: useSafeArea,
          child: Builder(builder: builder),
        );
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        if (reduceMotion) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: AriaMotion.softSpring,
          reverseCurve: AriaMotion.exit,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              // Fade completes early so the surface is fully opaque while the
              // spring is still settling — avoids a "ghost" mid-flight.
              curve: const Interval(0, 0.5, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Convenience for a sheet that is just a list of choices.
  static Future<T?> showOptions<T>({
    required BuildContext context,
    required String title,
    required List<AriaSheetOption<T>> options,
  }) {
    return show<T>(
      context: context,
      builder: (sheetContext) =>
          _OptionsSheet<T>(title: title, options: options),
    );
  }
}

/// A single row in an [AriaSheet.showOptions] sheet.
class AriaSheetOption<T> {
  const AriaSheetOption({
    required this.value,
    required this.label,
    this.icon,
    this.subtitle,
    this.isDestructive = false,
  });

  final T value;
  final String label;
  final IconData? icon;
  final String? subtitle;
  final bool isDestructive;
}

// -----------------------------------------------------------------------------
// Internals
// -----------------------------------------------------------------------------

class _AriaSheetSurface extends StatelessWidget {
  const _AriaSheetSurface({
    required this.child,
    required this.isScrollControlled,
    required this.enableDrag,
    required this.useSafeArea,
  });

  final Widget child;
  final bool isScrollControlled;
  final bool enableDrag;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget surface = ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        clipBehavior: Clip.antiAlias,
        borderRadius: AppRadius.sheetTop,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetGrabber(),
            Flexible(child: child),
          ],
        ),
      ),
    );

    if (isScrollControlled) {
      surface = Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: surface,
      );
    }

    surface = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: surface,
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + AppSpacing.lg,
        ),
        child: Material(
          color: Colors.transparent,
          child: enableDrag ? _DragDismiss(child: surface) : surface,
        ),
      ),
    );
  }
}

/// The little handle at the top of a sheet. Purely affordance — it tells the
/// user the sheet can be dragged without any text.
class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _DragDismiss extends StatefulWidget {
  const _DragDismiss({required this.child});

  final Widget child;

  @override
  State<_DragDismiss> createState() => _DragDismissState();
}

class _DragDismissState extends State<_DragDismiss> {
  double _dragOffset = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        final next = _dragOffset + details.delta.dy;
        setState(() => _dragOffset = next < 0 ? 0 : next);
      },
      onVerticalDragEnd: (details) {
        final shouldDismiss =
            _dragOffset > 90 ||
            details.primaryVelocity != null && details.primaryVelocity! > 700;
        if (shouldDismiss) {
          Navigator.of(context).maybePop();
        } else {
          setState(() => _dragOffset = 0);
        }
      },
      child: AnimatedContainer(
        duration: AriaMotion.fast,
        curve: AriaMotion.press,
        transform: Matrix4.translationValues(0, _dragOffset, 0),
        child: widget.child,
      ),
    );
  }
}

class _OptionsSheet<T> extends StatelessWidget {
  const _OptionsSheet({required this.title, required this.options});

  final String title;
  final List<AriaSheetOption<T>> options;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Text(title, style: theme.textTheme.titleLarge),
          ),
          for (final option in options)
            ListTile(
              leading: option.icon == null ? null : Icon(option.icon),
              title: Text(
                option.label,
                style: TextStyle(
                  color: option.isDestructive ? theme.colorScheme.error : null,
                ),
              ),
              subtitle: option.subtitle == null ? null : Text(option.subtitle!),
              onTap: () => Navigator.of(context).pop(option.value),
            ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
