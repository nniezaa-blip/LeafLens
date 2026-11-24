import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Decorative SVG positioned with fractional sizing.
///
/// Always occupies [widthFactor] × [heightFactor] of the parent,
/// anchored at [alignment]. Defaults to bottom-right, 60% × 50%.
class BackgroundEllipse extends StatelessWidget {
  /// Creates a [BackgroundEllipse] with the given sizing and alignment.
  const BackgroundEllipse({
    super.key,
    this.assetPath = 'assets/images/splash_ellipse.svg',
    this.widthFactor = 0.9,
    this.heightFactor = 0.9,
    this.alignment = Alignment.bottomRight,
    this.fit = BoxFit.contain,
  });

  /// Path to the SVG asset.
  final String assetPath;

  /// Fraction of parent width the SVG should occupy.
  final double widthFactor;

  /// Fraction of parent height the SVG should occupy.
  final double heightFactor;

  /// Alignment anchor within the parent.
  final Alignment alignment;

  /// How the SVG should be fitted inside its box.
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: SvgPicture.asset(assetPath, fit: fit),
      ),
    );
  }
}
