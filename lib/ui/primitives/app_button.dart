import 'package:lextari/ui/ui.dart';

enum AppButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
    this.expand = false,
    this.height,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final AppButtonVariant variant;
  final bool expand;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = loading ? null : onPressed;
    final child = loading ? const ActivityIndicator() : Text(label);
    final style = height == null
        ? null
        : ButtonStyle(minimumSize: Size(0, height!));
    final button = switch (variant) {
      AppButtonVariant.secondary => FilledButton(
        style: style,
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.outline => OutlinedButton(
        style: style,
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        style: style,
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.primary => FilledButton(
        style: style,
        onPressed: effectiveOnPressed,
        child: child,
      ),
    };
    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
