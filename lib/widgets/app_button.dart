import 'package:flutter/material.dart';

/// Visual variants for [AppButton].
enum AppButtonVariant {
  /// Filled primary button.
  primary,

  /// Tonal secondary button.
  secondary,

  /// Outlined button.
  outline,

  /// Text-only button.
  text,
}

/// Styled button using the app's FilledButton/OutlinedButton theme.
class AppButton extends StatelessWidget {
  /// Creates an [AppButton] with the given [label] and optional [variant].
  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.width,
  });

  /// The button text label.
  final String label;

  /// Called when the button is tapped. Null disables the button.
  final VoidCallback? onPressed;

  /// The visual style variant (primary, secondary, outline, or text).
  final AppButtonVariant variant;

  /// Optional icon to display before the label.
  final IconData? icon;

  /// Whether to show a loading spinner in place of the label.
  final bool loading;

  /// Optional fixed width for the button.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: loading ? null : onPressed,
        child: child,
      ),
      AppButtonVariant.secondary => FilledButton.tonal(
        onPressed: loading ? null : onPressed,
        child: child,
      ),
      AppButtonVariant.outline => OutlinedButton(
        onPressed: loading ? null : onPressed,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: loading ? null : onPressed,
        child: child,
      ),
    };

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}
