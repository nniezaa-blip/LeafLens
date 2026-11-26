import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

const _minDesktopWidth = 640.0;
const _minStandardWidth = 1040.0;
const _minStandardHeight = 824.0;
const _maxMobileWidth = 560.0;

/// The horizontal side inset that keeps a mobile dashboard column centered.
double dashboardMobileSideOf(double width) =>
    math.max(16, (width - _maxMobileWidth) / 2);

/// How much room the dashboard has.
enum DashboardDensity {
  standard,
  compact,
  mobile;

  bool get isDesktop => this != mobile;

  bool get isCompact => this == compact;

  static DashboardDensity of(Size size) {
    if (size.width < _minDesktopWidth) return mobile;
    if (size.width < _minStandardWidth || size.height < _minStandardHeight) {
      return compact;
    }
    return standard;
  }
}

/// Carries the dashboard density and text scale to the cards.
class DashboardDensityScope extends InheritedWidget {
  const DashboardDensityScope({
    super.key,
    required this.density,
    required this.scale,
    required super.child,
  });

  final DashboardDensity density;
  final double scale;

  static DashboardDensityScope? _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DashboardDensityScope>();

  static DashboardDensity of(BuildContext context) =>
      _of(context)?.density ?? DashboardDensity.mobile;

  static double scaleOf(BuildContext context) => _of(context)?.scale ?? 1;

  @override
  bool updateShouldNotify(DashboardDensityScope oldWidget) =>
      density != oldWidget.density || scale != oldWidget.scale;
}

/// Semantic colours for dashboard surfaces.
class DashboardColors {
  const DashboardColors._({
    required this.page,
    required this.card,
    required this.tone,
    required this.tone2,
    required this.track,
    required this.thumb,
  });

  factory DashboardColors.of(BuildContext context) {
    final scheme = context.colorScheme;
    return DashboardColors._(
      page: SurfaceLevel.page.colorOf(scheme),
      card: SurfaceLevel.card.colorOf(scheme),
      tone: SurfaceLevel.block.colorOf(scheme),
      tone2: SurfaceLevel.inset.colorOf(scheme),
      track: scheme.surfaceContainerHighest,
      thumb: scheme.outline,
    );
  }

  final Color page;
  final Color card;
  final Color tone;
  final Color tone2;
  final Color track;
  final Color thumb;
}

/// The dashboard's two shadow levels.
abstract final class DashboardShadows {
  static List<BoxShadow> e1(BuildContext context) =>
      context.colorScheme.brightness == Brightness.dark ? _e1Dark : _e1Light;

  static List<BoxShadow> e2(BuildContext context) =>
      context.colorScheme.brightness == Brightness.dark ? _e2Dark : _e2Light;

  static BoxShadow _shadow(
    int alpha,
    double y,
    double blur, [
    double spread = 0,
  ]) {
    return BoxShadow(
      color: Color.fromARGB(alpha, 0, 0, 0),
      offset: Offset(0, y),
      blurRadius: blur,
      spreadRadius: spread,
    );
  }

  static final List<BoxShadow> _e1Light = [
    _shadow(0x0D, 0.5, 1),
    _shadow(0x0A, 2, 6),
    _shadow(0x17, 12, 32, -6),
  ];

  static final List<BoxShadow> _e1Dark = [
    _shadow(0x80, 1, 2),
    _shadow(0x8C, 10, 28, -6),
  ];

  static final List<BoxShadow> _e2Light = [
    _shadow(0x0F, 1, 3),
    _shadow(0x14, 10, 24),
    _shadow(0x38, 32, 64, -12),
  ];

  static final List<BoxShadow> _e2Dark = [
    _shadow(0x80, 2, 6),
    _shadow(0xB3, 32, 64, -12),
  ];
}

/// Dashboard corner radii, larger than the rest of the app's surfaces.
abstract final class DashboardCorner {
  static const double desktopCard = 32;
  static const double mobileCard = 34;
  static const double block = 20;
  static const double mobileBlock = 22;
  static const double tab = 16;
  static const double badge = 14;
}
