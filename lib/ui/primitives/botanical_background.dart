import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';
import 'package:lextari/ui/tokens/app_colors.dart';
import 'package:prism_ui/prism_ui.dart';

/// The soft botanical page background used by the app shell.
///
/// A cream or forest wash sits under three blurred glows. The glows are
/// decorative, so they never receive pointer events.
class BotanicalBackground extends StatelessWidget {
  /// Creates a [BotanicalBackground].
  const BotanicalBackground({super.key, this.child});

  /// Content painted over the background.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [
                      AppColors.forest,
                      Color.alphaBlend(
                        scheme.primary.withValues(alpha: 0.12),
                        AppColors.forest,
                      ),
                    ]
                  : [
                      AppColors.cream,
                      Color.alphaBlend(
                        scheme.primary.withValues(alpha: 0.08),
                        AppColors.cream,
                      ),
                    ],
            ),
          ),
        ),
        Positioned(
          top: -140,
          left: -90,
          child: _BotanicalGlow(
            size: 380,
            color: scheme.primary.withValues(alpha: dark ? 0.38 : 0.22),
          ),
        ),
        Positioned(
          bottom: -160,
          right: -110,
          child: _BotanicalGlow(
            size: 460,
            color: scheme.secondary.withValues(alpha: dark ? 0.28 : 0.18),
          ),
        ),
        Positioned(
          top: 190,
          right: -80,
          child: _BotanicalGlow(
            size: 260,
            color: (dark ? AppColors.sky : AppColors.lime).withValues(
              alpha: dark ? 0.18 : 0.28,
            ),
          ),
        ),
        ?child,
      ],
    );
  }
}

class _BotanicalGlow extends StatelessWidget {
  const _BotanicalGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color,
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
