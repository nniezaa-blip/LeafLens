import 'package:lextari/ui/ui.dart';

/// Full-screen progress state shown above every route.
class AppLoadingOverlay extends StatelessWidget {
  /// Creates an [AppLoadingOverlay].
  const AppLoadingOverlay({
    super.key,
    this.message = 'Logging out...',
    this.description = 'Ending this session',
    this.icon = AppGlyphs.logout,
  });

  /// Primary line.
  final String message;

  /// Secondary line.
  final String description;

  /// Glyph shown in the leading illustration.
  final Glyph icon;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Semantics(
      label: message,
      liveRegion: true,
      child: AbsorbPointer(
        child: ColoredBox(
          color: AppColors.black.withValues(alpha: AppOpacity.soft),
          child: Center(
            child: GlassCard(
              padding: const EdgeInsets.all(AppSpacing.s20),
              borderRadius: AppRadii.lg,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: AppSpacing.s48,
                    height: AppSpacing.s48,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: AppSpacing.s48,
                          height: AppSpacing.s48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scheme.primary.withValues(
                              alpha: AppOpacity.faint,
                            ),
                          ),
                          child: GlyphIcon(
                            icon,
                            size: AppSizes.iconXl,
                            color: scheme.primary,
                          ),
                        ),
                        Positioned(
                          right: -AppSpacing.s2,
                          bottom: -AppSpacing.s2,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.s4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.surface,
                            ),
                            child: const PulsingDot(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        style: AppTextStyle.callout
                            .of(context, emphasized: true)
                            .copyWith(color: scheme.onSurface),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        description,
                        style: AppTextStyle.caption1
                            .of(context)
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
