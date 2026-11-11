import 'package:flutter/material.dart';
import 'package:lextari/core/theme/app_colors.dart';

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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          color: value ? AppColors.mediumGreen : AppColors.greyLighter,
          borderRadius: BorderRadius.circular(25),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.offBlack.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
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
