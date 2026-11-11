import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lextari/core/theme/app_colors.dart';

/// Translucent, frosted-glass surface used for cards and panels.
///
/// Blurs whatever sits behind it and overlays a light translucent white
/// fill, a subtle highlight border, and a soft drop shadow to create a
/// glassmorphism effect.
class FrostedCard extends StatelessWidget {
  /// Creates a [FrostedCard].
  const FrostedCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 20,
    this.blur = 14,
    this.tint,
  });

  /// Content placed inside the card.
  final Widget child;

  /// Inner padding applied around [child].
  final EdgeInsetsGeometry padding;

  /// Corner radius of the card.
  final double borderRadius;

  /// Blur strength applied to the backdrop behind the card.
  final double blur;

  /// Optional colour overlay replacing the default translucent white fill.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.offBlack.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tint ?? AppColors.white.withValues(alpha: 0.55),
              borderRadius: radius,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.6),
              ),
            ),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
