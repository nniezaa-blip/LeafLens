import 'package:lextari/features/settings/presentation/widgets/settings_icon_badge.dart';
import 'package:lextari/ui/ui.dart';

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
    this.loading = false,
  });

  /// Leading icon for the row.
  final Glyph icon;

  /// Text label for the row.
  final String label;

  /// Called when the row is tapped.
  final VoidCallback onTap;

  /// Optional secondary text shown before the chevron (e.g. "English").
  final String? trailingText;

  /// Optional accent colour for the leading icon badge.
  final Color? iconColor;

  /// Shows a spinner instead of the chevron and blocks taps.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return GestureDetector(
      onTap: loading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        child: Row(
          children: [
            SettingsIconBadge(icon: icon, color: iconColor),
            const SizedBox(width: AppSpacing.s14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyle.callout
                    .of(context, emphasized: true)
                    .copyWith(color: scheme.onSurface),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: AppTextStyle.subheadline
                    .of(context)
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(width: AppSpacing.s6),
            ],
            if (loading)
              const PulsingDot()
            else
              GlyphIcon(
                AppGlyphs.chevronRight,
                size: AppSizes.iconAction,
                color: scheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
