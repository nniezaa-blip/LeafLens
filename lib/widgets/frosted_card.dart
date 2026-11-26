import 'package:lextari/ui/ui.dart';

/// Translucent, frosted-glass surface used for cards and panels.
///
/// Kept as the feature-facing name for [GlassCard] so charts and existing
/// callers share the same Botanical Glass treatment as the dashboard.
class FrostedCard extends StatelessWidget {
  /// Creates a [FrostedCard].
  const FrostedCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.s18),
    this.borderRadius = AppRadii.md,
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

  /// Optional colour overlay replacing the default translucent fill.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      borderRadius: borderRadius,
      blur: blur,
      tint: tint,
      child: child,
    );
  }
}
