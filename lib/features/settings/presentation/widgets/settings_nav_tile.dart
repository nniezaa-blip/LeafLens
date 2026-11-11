import 'package:flutter/material.dart';
import 'package:lextari/core/theme/app_colors.dart';
import 'package:lextari/features/settings/presentation/widgets/settings_icon_badge.dart';

/// Tappable settings row with a leading icon, label, optional trailing value,
/// and a chevron arrow indicating navigation.
class SettingsNavTile extends StatelessWidget {
  /// Creates a [SettingsNavTile].
  const SettingsNavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.trailingText,
    this.iconColor,
  });

  /// Leading icon for the row.
  final IconData icon;

  /// Text label for the row.
  final String label;

  /// Called when the row is tapped.
  final VoidCallback onTap;

  /// Optional secondary text shown before the chevron (e.g. "English").
  final String? trailingText;

  /// Optional accent colour for the leading icon badge.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SettingsIconBadge(icon: icon, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.offBlack,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.offBlack.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: AppColors.mediumGrey,
            ),
          ],
        ),
      ),
    );
  }
}
