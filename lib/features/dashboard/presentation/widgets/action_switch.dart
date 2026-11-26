import 'package:lextari/ui/ui.dart';

/// Compact control tile used in the dashboard action row.
///
/// The tile carries the icon, label and current state. The icon fills and the
/// tile tints when the control is active, so the row reads like a set of
/// hardware buttons rather than a list of switches.
class ActionSwitch extends StatelessWidget {
  /// Creates an [ActionSwitch].
  const ActionSwitch({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Icon displayed above the label.
  final Glyph icon;

  /// Text label for this control.
  final String label;

  /// Whether the control is currently on.
  final bool value;

  /// Called when the tile is tapped.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Semantics(
      button: true,
      label: '$label ${value ? 'on' : 'off'}',
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.emphasized,
        decoration: ShapeDecoration(
          color: value
              ? scheme.primary.withValues(alpha: 0.14)
              : SurfaceLevel.block.colorOf(scheme),
          shape: AppShape.all(AppRadii.md),
        ),
        child: PressSurface(
          fill: Colors.transparent,
          shape: AppShape.all(AppRadii.md),
          onPressed: () => onChanged(!value),
          childFills: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedAppGlyph(
                  glyph: icon,
                  selected: value,
                  size: 26,
                  color: scheme.onSurfaceVariant,
                  selectedColor: scheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.caption1
                      .of(context, emphasized: true)
                      .copyWith(color: scheme.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  value ? 'On' : 'Off',
                  style: AppTextStyle.caption2
                      .of(context)
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
