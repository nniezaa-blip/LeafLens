import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

/// A glyph that animates its fill and colour when its selected state changes.
///
/// Prism's [AnimatedGlyph] supplies the fill and pop; this wrapper adds the
/// colour transition used by navigation and selection controls.
class AnimatedAppGlyph extends StatelessWidget {
  /// Creates an [AnimatedAppGlyph].
  const AnimatedAppGlyph({
    required this.glyph,
    required this.selected,
    this.size = 24,
    this.color,
    this.selectedColor,
    super.key,
  });

  /// Glyph to draw.
  final Glyph glyph;

  /// Whether the glyph is selected.
  final bool selected;

  /// Icon size.
  final double size;

  /// Colour at rest.
  final Color? color;

  /// Colour when selected.
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final idle = color ?? colorScheme.onSurfaceVariant;
    final active = selectedColor ?? colorScheme.primary;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: selected ? 1 : 0),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return IconTheme(
          data: IconThemeData(
            size: size,
            color: Color.lerp(idle, active, value),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      child: AnimatedGlyph(glyph: glyph, filled: selected),
    );
  }
}
