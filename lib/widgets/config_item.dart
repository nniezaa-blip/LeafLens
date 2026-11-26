import 'package:lextari/ui/ui.dart';

/// A settings row with a toggle.
class ConfigToggleItem extends StatelessWidget {
  /// Creates a [ConfigToggleItem].
  const ConfigToggleItem({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leading,
    this.enabled = true,
    super.key,
  });

  /// Row label.
  final String title;

  /// Optional row description.
  final String? subtitle;

  /// Optional leading widget.
  final Widget? leading;

  /// Current toggle value.
  final bool value;

  /// Called with the next value.
  final ValueChanged<bool> onChanged;

  /// Whether the row responds to input.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListItem<void>.toggle(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      leading: leading,
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }
}

/// A settings row that picks one value from a list.
class ConfigSelectionItem<T> extends StatelessWidget {
  /// Creates a [ConfigSelectionItem].
  const ConfigSelectionItem({
    required this.title,
    required this.options,
    required this.value,
    required this.textBuilder,
    required this.onChanged,
    this.subtitle,
    this.leading,
    this.enabled = true,
    super.key,
  });

  /// Row label.
  final String title;

  /// Optional row description.
  final String? subtitle;

  /// Optional leading widget.
  final Widget? leading;

  /// Available values.
  final List<T> options;

  /// Current value.
  final T value;

  /// Turns a value into its label.
  final String Function(T value) textBuilder;

  /// Called with the selected value.
  final ValueChanged<T> onChanged;

  /// Whether the row responds to input.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListItem<T>.options(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      leading: leading,
      options: options,
      value: value,
      textBuilder: textBuilder,
      onChanged: onChanged,
      enabled: enabled,
    );
  }
}
