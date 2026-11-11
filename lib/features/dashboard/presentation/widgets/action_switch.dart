import 'package:flutter/material.dart';

import 'package:lextari/core/theme/app_colors.dart';

/// Toggle switch pill used in the dashboard action row.
///
/// Shows an icon, a label, and a toggle indicator.
/// The pill background is semi-transparent green; the toggle track
/// is dark teal with a white circle when active.
class ActionSwitch extends StatelessWidget {
  /// Creates an [ActionSwitch].
  const ActionSwitch({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Icon displayed on the left side of the pill.
  final IconData icon;

  /// Text label for this switch.
  final String label;

  /// Whether the switch is currently on.
  final bool value;

  /// Called when the user taps the switch.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 180,
        height: 62,
        decoration: BoxDecoration(
          color: AppColors.switchBackground,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            const SizedBox(width: 19),
            Icon(icon, size: 26, color: AppColors.offBlack),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.offBlack,
                ),
              ),
            ),
            _ToggleTrack(value: value),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }
}

//
// Private widgets
//

class _ToggleTrack extends StatelessWidget {
  const _ToggleTrack({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 59,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.switchTrack,
        borderRadius: BorderRadius.circular(25),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
