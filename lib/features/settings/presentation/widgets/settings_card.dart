import 'package:lextari/ui/ui.dart';

/// Frosted glass surface used to group settings rows into sections.
class SettingsCard extends StatelessWidget {
  /// Creates a [SettingsCard].
  const SettingsCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.s16,
      vertical: AppSpacing.s8,
    ),
  });

  /// Content placed inside the card.
  final Widget child;

  /// Inner padding applied around [child].
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GlassCard(padding: padding, child: child);
  }
}
