import 'package:lextari/ui/ui.dart';

enum AppButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final AppButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = loading ? null : onPressed;
    final child = loading ? const ActivityIndicator() : Text(label);
    final button = switch (variant) {
      AppButtonVariant.secondary => FilledButton(onPressed: effectiveOnPressed, child: child),
      AppButtonVariant.outline => OutlinedButton(onPressed: effectiveOnPressed, child: child),
      AppButtonVariant.text => TextButton(onPressed: effectiveOnPressed, child: child),
      AppButtonVariant.primary => FilledButton(onPressed: effectiveOnPressed, child: child),
    };
    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
