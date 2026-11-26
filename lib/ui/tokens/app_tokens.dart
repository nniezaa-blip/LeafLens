import 'package:flutter/widgets.dart';

class AppSpacing {
  const AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadii {
  const AppRadii._();
  static const double sm = 12;
  static const double md = 20;
  static const double lg = 28;
  static const double xl = 34;
}

class AppDurations {
  const AppDurations._();
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
}

class AppCurves {
  const AppCurves._();
  static const Curve emphasized = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve settle = Curves.easeOutCubic;
}
