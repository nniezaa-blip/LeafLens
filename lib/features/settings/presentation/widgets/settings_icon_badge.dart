import 'package:lextari/ui/ui.dart';

/// Rounded tinted square holding the leading icon for a settings row.
class SettingsIconBadge extends StatelessWidget {
  /// Creates a [SettingsIconBadge].
  const SettingsIconBadge({required this.icon, super.key, this.color});

  /// Icon rendered inside the badge.
  final Glyph icon;

  /// Accent colour for the icon and its tint. Defaults to brand green.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.mediumGreen;

    return Container(
      width: AppSizes.badge,
      height: AppSizes.badge,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: AppOpacity.tint),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: GlyphIcon(icon, size: AppSizes.iconLg, color: accent),
    );
  }
}
