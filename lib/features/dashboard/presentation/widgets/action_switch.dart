import 'package:lextari/ui/ui.dart';

/// Compact care-control pill.
///
/// Off is a quiet outlined pill. On fills the whole pill with the brand colour.
/// Presses use the elastic press: the pill swells, tracks the finger and
/// springs back, with a hover/press overlay inside the shape.
class ActionSwitch extends StatelessWidget {
  /// Creates an [ActionSwitch].
  const ActionSwitch({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Icon shown before the label.
  final Glyph icon;

  /// Text label for this control.
  final String label;

  /// Whether the control is currently on.
  final bool value;

  /// Called when the pill is tapped.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    const shape = StadiumBorder();
    return Semantics(
      button: true,
      toggled: value,
      label: label,
      child: ElasticPress(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: value ? 1 : 0),
          duration: AppMotionTokens.control,
          curve: AppCurves.emphasized,
          builder: (context, amount, _) {
            final fill = Color.lerp(
              AppColors.transparent,
              scheme.primary,
              amount,
            )!;
            final content = Color.lerp(
              scheme.onSurfaceVariant,
              scheme.onPrimary,
              amount,
            )!;
            final border = Color.lerp(
              scheme.outlineVariant.withValues(alpha: AppOpacity.strong),
              scheme.primary,
              amount,
            )!;
            return Container(
              height: AppSizes.actionButtonHeight,
              decoration: ShapeDecoration(
                color: fill,
                shape: shape.copyWith(side: BorderSide(color: border)),
                shadows: amount > 0
                    ? [
                        BoxShadow(
                          color: scheme.primary.withValues(
                            alpha: AppOpacity.faint,
                          ),
                          blurRadius: AppSpacing.s12,
                          offset: const Offset(0, AppSpacing.s4),
                        ),
                      ]
                    : null,
              ),
              child: PressRegion(
                shape: shape,
                overlay: PressRegion.hoverOverlay,
                excludeFromSemantics: true,
                enableFeedback: false,
                onTap: () => onChanged(!value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedAppGlyph(
                        glyph: icon,
                        selected: value,
                        size: AppSizes.iconLg,
                        color: content,
                        selectedColor: content,
                      ),
                      const SizedBox(width: AppSpacing.s6),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: AppTextStyle.caption1
                              .of(context, emphasized: true)
                              .copyWith(color: content),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
