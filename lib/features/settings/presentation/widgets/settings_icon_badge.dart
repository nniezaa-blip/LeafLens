import 'package:flutter/material.dart';
import 'package:lextari/core/theme/app_colors.dart';

/// Rounded tinted square holding the leading icon for a settings row.
class SettingsIconBadge extends StatelessWidget {
  /// Creates a [SettingsIconBadge].
  const SettingsIconBadge({required this.icon, super.key, this.color});

  /// Icon rendered inside the badge.
  final IconData icon;

  /// Accent colour for the icon and its tint. Defaults to brand green.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.mediumGreen;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: accent),
    );
  }
}
