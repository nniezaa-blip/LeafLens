import 'package:lextari/ui/ui.dart';

/// Custom pill toggle used across the settings screen.
///
/// The track fills with brand green when [value] is true and the thumb
/// slides to the right; when false the track is light grey.
class SettingsSwitch extends StatelessWidget {
  /// Creates a [SettingsSwitch].
  const SettingsSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Whether the switch is currently on.
  final bool value;

  /// Called with the new value when the switch is tapped.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppMotionTokens.control,
        curve: AppCurves.emphasized,
        width: AppSizes.switchWidth,
        height: AppSizes.switchHeight,
        decoration: BoxDecoration(
          color: value
              ? context.colorScheme.primary
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: AnimatedAlign(
          duration: AppMotionTokens.control,
          curve: AppCurves.emphasized,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.switchInset,
            ),
            child: Container(
              width: AppSizes.switchThumb,
              height: AppSizes.switchThumb,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: AppShadows.thumb,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
