import 'package:flutter/widgets.dart';
import 'package:lextari/ui/tokens/app_tokens.dart';
import 'package:prism_ui/context.dart';

/// A small dot that breathes in and out.
class PulsingDot extends StatefulWidget {
  /// Creates a [PulsingDot].
  const PulsingDot({super.key, this.size = AppSpacing.s10, this.color});

  /// Diameter of the dot.
  final double size;

  /// Dot colour. Defaults to the theme primary.
  final Color? color;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotionTokens.pulse,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Opacity(
          opacity: 0.45 + 0.55 * t,
          child: Transform.scale(
            scale: 0.75 + 0.25 * t,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color ?? context.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
