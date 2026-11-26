import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:lextari/ui/tokens/app_colors.dart';
import 'package:lextari/ui/tokens/app_tokens.dart';
import 'package:prism_ui/prism_ui.dart';

/// A translucent surface that blurs the page behind it.
///
/// Every card in the app uses this surface so the Botanical Glass treatment
/// stays consistent between screens and between light and dark themes.
class GlassCard extends StatelessWidget {
  /// Creates a [GlassCard].
  const GlassCard({
    required this.child,
    super.key,
    this.padding = EdgeInsets.zero,
    this.borderRadius = AppRadii.card,
    this.blur = 20,
    this.tint,
    this.onTap,
    this.semanticLabel,
    this.shadows,
  });

  /// Content placed inside the glass.
  final Widget child;

  /// Inner padding applied around [child].
  final EdgeInsetsGeometry padding;

  /// Corner radius of the card.
  final double borderRadius;

  /// Blur strength applied to the backdrop behind the card.
  final double blur;

  /// Optional colour overlay replacing the theme fill.
  final Color? tint;

  /// Makes the whole card tappable when set.
  final VoidCallback? onTap;

  /// Screen-reader label for the card.
  final String? semanticLabel;

  /// Overrides the theme's card shadow.
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius);
    final content = Padding(padding: padding, child: child);
    final fill = tint ?? _fillOf(scheme, dark: dark);
    final topAlpha = (fill.a + 0.08).clamp(0.0, 1.0);
    final bottomAlpha = (fill.a - 0.10).clamp(0.0, 1.0);
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            fill.withValues(alpha: topAlpha),
            fill.withValues(alpha: bottomAlpha),
          ],
        ),
        borderRadius: radius,
        border: Border.all(color: _borderOf(scheme, dark: dark)),
      ),
      child: onTap == null
          ? content
          : PressSurface(
              fill: AppColors.transparent,
              shape: RoundedRectangleBorder(borderRadius: radius),
              onPressed: onTap,
              childFills: true,
              child: content,
            ),
    );
    final glass = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: surface,
      ),
    );
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow:
              shadows ?? (dark ? AppShadows.cardDark : AppShadows.cardLight),
        ),
        child: glass,
      ),
    );
  }

  static Color _fillOf(ColorScheme scheme, {required bool dark}) {
    return dark
        ? scheme.surfaceContainer.withValues(alpha: AppOpacity.glassDark)
        : AppColors.paper.withValues(alpha: AppOpacity.glass);
  }

  static Color _borderOf(ColorScheme scheme, {required bool dark}) {
    return dark
        ? AppColors.white.withValues(alpha: AppOpacity.thumb)
        : AppColors.white.withValues(alpha: AppOpacity.faded);
  }
}
