import 'package:lextari/features/settings/presentation/widgets/settings_icon_badge.dart';
import 'package:lextari/features/settings/presentation/widgets/settings_switch.dart';
import 'package:lextari/ui/ui.dart';

/// Settings row with a leading icon, a label, and a custom [SettingsSwitch].
///
/// Tapping anywhere on the row toggles the switch.
class SettingsSwitchTile extends StatelessWidget {
  /// Creates a [SettingsSwitchTile].
  const SettingsSwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Leading icon for the row.
  final Glyph icon;

  /// Text label for the row.
  final String label;

  /// Whether the switch is currently on.
  final bool value;

  /// Called with the new value when the row or switch is tapped.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        child: Row(
          children: [
            SettingsIconBadge(icon: icon),
            const SizedBox(width: AppSpacing.s14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyle.callout
                    .of(context, emphasized: true)
                    .copyWith(color: context.colorScheme.onSurface),
              ),
            ),
            SettingsSwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
