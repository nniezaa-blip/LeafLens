import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart' as prism;

enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final AppButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = loading ? null : onPressed;
    final displayLabel = loading ? 'Loading...' : label;
    final Widget button = switch (variant) {
      AppButtonVariant.primary => prism.FilledButton(
        onPressed: effectiveOnPressed,
        child: Text(displayLabel),
      ),
      AppButtonVariant.secondary => prism.TonalButton(
        onPressed: effectiveOnPressed,
        label: displayLabel,
      ),
      AppButtonVariant.ghost => prism.TextButton(
        onPressed: effectiveOnPressed,
        child: Text(displayLabel),
      ),
    };

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
