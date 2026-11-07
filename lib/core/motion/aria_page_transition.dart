import 'package:flutter/material.dart';

import 'aria_motion.dart';

/// Global page transition for ARIA.
///
/// Installed once via `PageTransitionsTheme` in `app_theme.dart`, so every
/// push — including the ones added in future features — gets the same gentle
/// slide-and-fade without any route-level configuration.
class AriaPageTransitionsBuilder extends PageTransitionsBuilder {
  const AriaPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return child;
    }

    final enter = CurvedAnimation(
      parent: animation,
      curve: AriaMotion.enter,
      reverseCurve: AriaMotion.exit,
    );
    final exit = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AriaMotion.enter,
      reverseCurve: AriaMotion.exit,
    );

    return SlideTransition(
      // The outgoing page drifts slightly left and dims, so the incoming page
      // reads as arriving on top rather than replacing in place.
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.06, 0),
      ).animate(exit),
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0.85).animate(exit),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0.02),
            end: Offset.zero,
          ).animate(enter),
          child: FadeTransition(opacity: enter, child: child),
        ),
      ),
    );
  }
}

/// Applies [AriaPageTransitionsBuilder] to every target platform.
const PageTransitionsTheme kAriaPageTransitionsTheme = PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: AriaPageTransitionsBuilder(),
    TargetPlatform.iOS: AriaPageTransitionsBuilder(),
    TargetPlatform.linux: AriaPageTransitionsBuilder(),
    TargetPlatform.macOS: AriaPageTransitionsBuilder(),
    TargetPlatform.windows: AriaPageTransitionsBuilder(),
    TargetPlatform.fuchsia: AriaPageTransitionsBuilder(),
  },
);
