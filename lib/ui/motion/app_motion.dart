import 'package:flutter/widgets.dart';
import 'package:lextari/ui/tokens/app_tokens.dart';
import 'package:prism_ui/prism_ui.dart' as prism;

class AppMotion {
  const AppMotion._();

  static Widget visibility({
    required bool visible,
    required Widget child,
  }) {
    return prism.AnimatedVisibility.bottomNavigation(
      visible: visible,
      child: child,
    );
  }

  static Widget switcher({
    required Widget child,
    Duration duration = AppDurations.normal,
  }) {
    return prism.PageTransitionSwitcher(
      duration: duration,
      transitionBuilder: (child, primary, secondary) {
        return prism.FadeThroughTransition(
          animation: primary,
          secondaryAnimation: secondary,
          child: child,
        );
      },
      child: child,
    );
  }
}
