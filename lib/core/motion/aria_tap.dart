import 'dart:async';

import 'package:flutter/material.dart';

import 'aria_haptics.dart';
import 'aria_motion.dart';

/// The only sanctioned way to make something tappable in ARIA.
///
/// Wrapping a gesture in [AriaTap] guarantees all three house rules at once:
/// 1. a light, paper-tap haptic ([AriaHaptics.tap]),
/// 2. a barely-perceptible press scale, and
/// 3. a ripple consistent with the theme.
///
/// The `no_raw_gesture_tap` lint rule flags bare `GestureDetector`/`InkWell`
/// with an `onTap` inside `lib/features/**`, so future features inherit this
/// automatically.
class AriaTap extends StatefulWidget {
  const AriaTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = AriaMotion.pressedScale,
    this.haptic = true,
    this.ripple = false,
    this.borderRadius,
    this.enabled = true,
    this.semanticLabel,
  });

  /// A tap target for cards and large surfaces: even subtler press scale and a
  /// slightly softer feel.
  const AriaTap.card({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.haptic = true,
    this.enabled = true,
    this.semanticLabel,
  }) : scale = AriaMotion.pressedScaleCard,
       ripple = false,
       borderRadius = null;

  /// A tap target for buttons and list rows: standard press scale with a
  /// theme ripple.
  const AriaTap.button({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.haptic = true,
    this.enabled = true,
    this.borderRadius,
    this.semanticLabel,
  }) : scale = AriaMotion.pressedScale,
       ripple = true;

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final bool haptic;
  final bool ripple;
  final BorderRadius? borderRadius;
  final bool enabled;
  final String? semanticLabel;

  @override
  State<AriaTap> createState() => _AriaTapState();
}

class _AriaTapState extends State<AriaTap> {
  bool _pressed = false;

  bool get _isInteractive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _setPressed(bool value) {
    if (!_isInteractive || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    if (!_isInteractive) return;
    if (widget.haptic) unawaited(AriaHaptics.tap());
    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (!_isInteractive) return;
    if (widget.haptic) unawaited(AriaHaptics.confirm());
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    Widget content = widget.child;

    if (widget.ripple) {
      content = Material(
        color: Colors.transparent,
        borderRadius: widget.borderRadius,
        child: InkWell(
          onTap: _isInteractive ? _handleTap : null,
          onLongPress: _isInteractive ? _handleLongPress : null,
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      );
      // InkWell already gives press feedback via the ripple, so we only apply
      // the scale on the outer wrapper without double-handling the gesture.
      return _ScaleWrap(
        scale: widget.scale,
        pressed: _pressed && _isInteractive,
        reduceMotion: reduceMotion,
        child: _PressTracker(
          onChanged: _setPressed,
          onTap: _handleTap,
          onLongPress: _handleLongPress,
          enabled: _isInteractive,
          child: content,
        ),
      );
    }

    return _ScaleWrap(
      scale: widget.scale,
      pressed: _pressed && _isInteractive,
      reduceMotion: reduceMotion,
      child: Semantics(
        button: true,
        enabled: _isInteractive,
        label: widget.semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: _isInteractive ? _handleTap : null,
          onLongPress: _isInteractive ? _handleLongPress : null,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Applies the press scale. Split out so both the ripple and non-ripple paths
/// animate identically.
class _ScaleWrap extends StatelessWidget {
  const _ScaleWrap({
    required this.child,
    required this.pressed,
    required this.scale,
    required this.reduceMotion,
  });

  final Widget child;
  final bool pressed;
  final double scale;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: pressed && !reduceMotion ? scale : 1.0,
      duration: reduceMotion ? Duration.zero : AriaMotion.fast,
      curve: AriaMotion.press,
      child: child,
    );
  }
}

/// Feeds press state to the scale wrapper while letting the ripple handle the
/// actual gesture.
class _PressTracker extends StatelessWidget {
  const _PressTracker({
    required this.child,
    required this.onChanged,
    required this.onTap,
    required this.onLongPress,
    required this.enabled,
  });

  final Widget child;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onChanged(true),
      onPointerUp: (_) => onChanged(false),
      onPointerCancel: (_) => onChanged(false),
      child: child,
    );
  }
}
