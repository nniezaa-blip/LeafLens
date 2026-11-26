import 'dart:math' as math;

import 'package:lextari/ui/ui.dart';

/// The horizontal side inset that keeps a mobile dashboard column centered.
double dashboardMobileSideOf(double width) => math.max(
      AppSpacing.s16,
      (width - AppBreakpoints.dashboardMaxWidth) / 2,
    );

/// How much room the dashboard has.
enum DashboardDensity {
  standard,
  compact,
  mobile;

  bool get isDesktop => this != mobile;

  bool get isCompact => this == compact;

  static DashboardDensity of(Size size) {
    if (size.width < AppBreakpoints.dashboardDesktop) return mobile;
    if (size.width < AppBreakpoints.dashboardStandard ||
        size.height < AppBreakpoints.dashboardStandardHeight) {
      return compact;
    }
    return standard;
  }
}

/// Carries the dashboard density and text scale to the cards.
class DashboardDensityScope extends InheritedWidget {
  const DashboardDensityScope({
    required this.density,
    required this.scale,
    required super.child,
    super.key,
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
      context.colorScheme.brightness == Brightness.dark
          ? AppShadows.cardDark
          : AppShadows.cardLight;

  static List<BoxShadow> e2(BuildContext context) =>
      context.colorScheme.brightness == Brightness.dark
          ? AppShadows.raisedDark
          : AppShadows.raisedLight;
}

/// Dashboard corner radii, larger than the rest of the app's surfaces.
abstract final class DashboardCorner {
  static const double desktopCard = AppRadii.xl;
  static const double mobileCard = AppRadii.xxl;
  static const double block = AppRadii.md;
  static const double mobileBlock = AppRadii.block;
  static const double tab = AppSpacing.s16;
  static const double badge = AppSpacing.s14;
}
