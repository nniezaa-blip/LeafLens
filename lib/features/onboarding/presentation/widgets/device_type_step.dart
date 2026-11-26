import 'package:lextari/ui/ui.dart';

/// First onboarding step: choose the kind of device being linked.
class DeviceTypeStep extends StatelessWidget {
  /// Creates a [DeviceTypeStep].
  const DeviceTypeStep({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  /// Currently selected device type key.
  final String selected;

  /// Called with the chosen device type key.
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DeviceTypeOption(
          glyph: AppGlyphs.sprout,
          title: 'Environment sensors',
          description: 'Temperature, humidity and soil moisture.',
          selected: selected == 'lextari-env',
          onTap: () => onSelected('lextari-env'),
        ),
        const SizedBox(height: AppSpacing.s10),
        _DeviceTypeOption(
          glyph: AppGlyphs.waterTank,
          title: 'Water system',
          description: 'Tank level and refill control.',
          selected: selected == 'lextari-water',
          onTap: () => onSelected('lextari-water'),
        ),
      ],
    );
  }
}

class _DeviceTypeOption extends StatelessWidget {
  const _DeviceTypeOption({
    required this.glyph,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final Glyph glyph;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $description',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppMotionTokens.control,
          curve: AppCurves.emphasized,
          constraints: const BoxConstraints(
            minHeight: AppSizes.deviceTypeOptionHeight,
          ),
          padding: const EdgeInsets.all(AppSpacing.s14),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: AppOpacity.whisper)
                : AppColors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: selected
                  ? scheme.primary.withValues(alpha: AppOpacity.soft)
                  : scheme.outlineVariant.withValues(alpha: AppOpacity.strong),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppMotionTokens.control,
                curve: AppCurves.emphasized,
                width: AppSizes.badge,
                height: AppSizes.badge,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? scheme.primary
                      : scheme.primary.withValues(alpha: AppOpacity.faint),
                ),
                child: GlyphIcon(
                  glyph,
                  size: AppSizes.iconLg,
                  color: selected ? scheme.onPrimary : scheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.callout
                          .of(context, emphasized: true)
                          .copyWith(color: scheme.onSurface),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.caption1
                          .of(context)
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              AnimatedContainer(
                duration: AppMotionTokens.control,
                curve: AppCurves.emphasized,
                width: AppSizes.selectionMark,
                height: AppSizes.selectionMark,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? scheme.primary : AppColors.transparent,
                  border: Border.all(
                    color: selected
                        ? scheme.primary
                        : scheme.outlineVariant.withValues(
                            alpha: AppOpacity.strong,
                          ),
                  ),
                ),
                child: selected
                    ? GlyphIcon(
                        AppGlyphs.check,
                        size: AppSizes.iconXs,
                        color: scheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
