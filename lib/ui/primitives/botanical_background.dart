import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';
import 'package:lextari/ui/tokens/app_colors.dart';
import 'package:lextari/ui/tokens/app_tokens.dart';
import 'package:prism_ui/prism_ui.dart';

/// The soft botanical page background used by the app shell.
///
/// A cream or black wash sits under three blurred glows. The glows are
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
                      AppColors.black,
                      Color.alphaBlend(
                        scheme.primary.withValues(
                          alpha: AppBotanical.washAlphaDark,
                        ),
                        AppColors.black,
                      ),
                    ]
                  : [
                      AppColors.cream,
                      Color.alphaBlend(
                        scheme.primary.withValues(
                          alpha: AppBotanical.washAlpha,
                        ),
                        AppColors.cream,
                      ),
                    ],
            ),
          ),
        ),
        Positioned(
          top: AppBotanical.glowTop,
          left: AppBotanical.glowLeft,
          child: _BotanicalGlow(
            size: AppBotanical.glowLarge,
            color: scheme.primary.withValues(
              alpha: dark ? AppBotanical.glowAlphaDark : AppBotanical.glowAlpha,
            ),
          ),
        ),
        Positioned(
          bottom: AppBotanical.glowBottom,
          right: AppBotanical.glowRight,
          child: _BotanicalGlow(
            size: AppBotanical.glowXLarge,
            color: scheme.secondary.withValues(
              alpha: dark
                  ? AppBotanical.glowAlphaSecondaryDark
                  : AppBotanical.glowAlphaSecondary,
            ),
          ),
        ),
        Positioned(
          top: AppBotanical.accentTop,
          right: AppBotanical.accentRight,
          child: _BotanicalGlow(
            size: AppBotanical.glowSmall,
            color: AppColors.lime.withValues(
              alpha: dark
                  ? AppBotanical.glowAlphaAccentDark
                  : AppBotanical.glowAlphaAccent,
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
        imageFilter: ImageFilter.blur(
          sigmaX: AppBotanical.glowBlur,
          sigmaY: AppBotanical.glowBlur,
        ),
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
