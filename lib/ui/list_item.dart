import 'package:flutter/widgets.dart';
import 'package:lextari/ui/entry_dialog.dart';
import 'package:prism_ui/prism_ui.dart';

sealed class _ListItemAction {
  const _ListItemAction();
}

final class _DefaultAction extends _ListItemAction {
  const _DefaultAction();
}

final class _ToggleAction extends _ListItemAction {
  const _ToggleAction({required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;
}

final class _CheckboxAction extends _ListItemAction {
  const _CheckboxAction({required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool?>? onChanged;
}

final class _OpenAction extends _ListItemAction {
  const _OpenAction({
    required this.widget,
    required this.forceFull,
    required this.enabled,
    this.onChanged,
  });

  final Widget widget;
  final ValueChanged<dynamic>? onChanged;
  final bool forceFull;
  final bool enabled;
}

final class _OptionsAction<T> extends _ListItemAction {
  const _OptionsAction({
    required this.options,
    required this.value,
    required this.textBuilder,
    required this.onChanged,
    required this.enabled,
  });

  final List<T> options;
  final T value;
  final String Function(T value) textBuilder;
  final ValueChanged<T> onChanged;
  final bool enabled;
}

final class _InputAction extends _ListItemAction {
  const _InputAction({
    required this.title,
    required this.value,
    required this.onChanged,
    this.suffixText,
    this.validator,
    this.maxLength,
    this.keyboardType,
  });

  final String title;
  final String value;
  final ValueChanged<String?> onChanged;
  final String? suffixText;
  final FormFieldValidator<String>? validator;
  final int? maxLength;
  final TextInputType? keyboardType;
}

/// A single row in a grouped list.
///
/// The named constructors cover the state row variants the design system uses:
/// a plain
/// row, one that opens a widget, one that picks an option, one that edits a
/// value, a toggle and a checkbox.
class ListItem<T> extends StatelessWidget {
  /// Creates a plain list row.
  const ListItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.horizontalTitleGap,
    this.minVerticalPadding = 10,
    this.minTileHeight,
    this.alignment = ListRowAlignment.center,
    super.key,
  }) : _action = const _DefaultAction();

  /// Creates a row that opens [widget] in a sheet.
  ListItem.open({
    required this.title,
    required Widget widget,
    this.subtitle,
    this.leading,
    this.trailing,
    ValueChanged<dynamic>? onChanged,
    bool forceFull = true,
    bool enabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.horizontalTitleGap,
    this.minVerticalPadding = 10,
    this.minTileHeight,
    this.alignment = ListRowAlignment.center,
    super.key,
  }) : _action = _OpenAction(
         widget: widget,
         onChanged: onChanged,
         forceFull: forceFull,
         enabled: enabled,
       ),
       onTap = null;

  /// Creates a row that picks one of [options].
  ListItem.options({
    required this.title,
    required List<T> options,
    required T value,
    required String Function(T value) textBuilder,
    required ValueChanged<T> onChanged,
    this.subtitle,
    this.leading,
    this.trailing,
    bool enabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.horizontalTitleGap,
    this.minVerticalPadding = 10,
    this.minTileHeight,
    this.alignment = ListRowAlignment.center,
    super.key,
  }) : _action = _OptionsAction<T>(
         options: options,
         value: value,
         textBuilder: textBuilder,
         onChanged: onChanged,
         enabled: enabled,
       ),
       onTap = null;

  /// Creates a row that edits a string in a sheet.
  ListItem.input({
    required this.title,
    required String dialogTitle,
    required String value,
    required ValueChanged<String?> onChanged,
    this.subtitle,
    this.leading,
    this.trailing,
    String? suffixText,
    FormFieldValidator<String>? validator,
    int? maxLength,
    TextInputType? keyboardType,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.horizontalTitleGap,
    this.minVerticalPadding = 10,
    this.minTileHeight,
    this.alignment = ListRowAlignment.center,
    super.key,
  }) : _action = _InputAction(
         title: dialogTitle,
         value: value,
         onChanged: onChanged,
         suffixText: suffixText,
         validator: validator,
         maxLength: maxLength,
         keyboardType: keyboardType,
       ),
       onTap = null;

  /// Creates a row with a checkbox.
  ListItem.checkbox({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.only(left: 16, right: 8),
    bool value = false,
    ValueChanged<bool?>? onChanged,
    this.horizontalTitleGap,
    this.minVerticalPadding = 10,
    this.minTileHeight,
    this.alignment = ListRowAlignment.center,
    super.key,
  }) : _action = _CheckboxAction(value: value, onChanged: onChanged),
       onTap = null;

  /// Creates a row with a toggle.
  ListItem.toggle({
    required this.title,
    required bool value,
    this.subtitle,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.only(left: 16, right: 8),
    ValueChanged<bool>? onChanged,
    this.horizontalTitleGap,
    this.minVerticalPadding = 10,
    this.minTileHeight,
    this.alignment = ListRowAlignment.center,
    super.key,
  }) : _action = _ToggleAction(value: value, onChanged: onChanged),
       onTap = null;

  /// Leading widget for the row.
  final Widget? leading;

  /// Primary label.
  final Widget title;

  /// Secondary label under [title].
  final Widget? subtitle;

  /// Padding around the row content.
  final EdgeInsets padding;

  /// Alignment of the row content.
  final ListRowAlignment alignment;

  /// Trailing widget for the row.
  final Widget? trailing;

  /// Called when the row is tapped for the plain and open variants.
  final VoidCallback? onTap;

  /// Gap between the leading widget and the title.
  final double? horizontalTitleGap;

  /// Minimum vertical padding of the row.
  final double minVerticalPadding;

  /// Minimum height of the row.
  final double? minTileHeight;

  final _ListItemAction _action;

  @override
  Widget build(BuildContext context) {
    return switch (_action) {
      _DefaultAction() => _buildDefault(),
      _ToggleAction(:final value, :final onChanged) => _buildToggle(
        value,
        onChanged,
      ),
      _CheckboxAction(:final value, :final onChanged) => _buildCheckbox(
        value,
        onChanged,
      ),
      _OpenAction() => _buildOpen(context),
      _OptionsAction<T>() => _buildOptions(context),
      _InputAction() => _buildInput(context),
      _ => _buildDefault(),
    };
  }

  Widget _buildDefault() {
    return DecorationListItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onPressed: onTap,
      contentPadding: padding,
      horizontalTitleGap: horizontalTitleGap,
      minVerticalPadding: minVerticalPadding,
      minHeight: minTileHeight,
      alignment: alignment,
    );
  }

  Widget _buildToggle(bool value, ValueChanged<bool>? onChanged) {
    return DecorationListItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: Switch(value: value, onChanged: onChanged),
      onPressed: onChanged == null ? onTap : () => onChanged(!value),
      contentPadding: padding,
      horizontalTitleGap: horizontalTitleGap,
      minVerticalPadding: minVerticalPadding,
      minHeight: minTileHeight,
      alignment: alignment,
    );
  }

  Widget _buildCheckbox(bool value, ValueChanged<bool?>? onChanged) {
    return DecorationListItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: Checkbox(value: value, onChanged: onChanged),
      onPressed: onChanged == null ? onTap : () => onChanged(!value),
      contentPadding: padding,
      horizontalTitleGap: horizontalTitleGap,
      minVerticalPadding: minVerticalPadding,
      minHeight: minTileHeight,
      alignment: alignment,
    );
  }

  Widget _buildOpen(BuildContext context) {
    final action = _action;
    if (action is! _OpenAction) return _buildDefault();
    return DecorationListItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing ?? const GlyphIcon(Glyphs.chevronForward, size: 18),
      onPressed: action.enabled ? () => _openWidget(context, action) : null,
      contentPadding: padding,
      horizontalTitleGap: horizontalTitleGap,
      minVerticalPadding: minVerticalPadding,
      minHeight: minTileHeight,
      alignment: alignment,
    );
  }

  Widget _buildOptions(BuildContext context) {
    final action = _action;
    if (action is! _OptionsAction<T>) return _buildDefault();
    return DecorationListItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(action.textBuilder(action.value)),
          const SizedBox(width: 6),
          const GlyphIcon(Glyphs.chevronDown, size: 16),
        ],
      ),
      onPressed: action.enabled ? () => _openOptions(context, action) : null,
      contentPadding: padding,
      horizontalTitleGap: horizontalTitleGap,
      minVerticalPadding: minVerticalPadding,
      minHeight: minTileHeight,
      alignment: alignment,
    );
  }

  Widget _buildInput(BuildContext context) {
    final action = _action;
    if (action is! _InputAction) return _buildDefault();
    return DecorationListItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(action.value),
          if (action.suffixText != null) ...[
            const SizedBox(width: 4),
            Text(action.suffixText!),
          ],
          const SizedBox(width: 6),
          const GlyphIcon(Glyphs.chevronDown, size: 16),
        ],
      ),
      onPressed: () => _openInput(context, action),
      contentPadding: padding,
      horizontalTitleGap: horizontalTitleGap,
      minVerticalPadding: minVerticalPadding,
      minHeight: minTileHeight,
      alignment: alignment,
    );
  }

  Future<void> _openWidget(BuildContext context, _OpenAction action) async {
    await showFormSheet<void>(
      context: context,
      builder: (_) => action.widget,
    );
    action.onChanged?.call(null);
  }

  Future<void> _openOptions(
    BuildContext context,
    _OptionsAction<T> action,
  ) async {
    final selected = await showFormSheet<T>(
      context: context,
      builder: (_) => _OptionsSheet<T>(
        title: title,
        options: action.options,
        value: action.value,
        textBuilder: action.textBuilder,
      ),
    );
    if (selected != null) action.onChanged(selected);
  }

  Future<void> _openInput(BuildContext context, _InputAction action) async {
    final value = await showEntryDialog(
      context,
      title: action.title,
      initialValue: action.value,
      validator: action.validator,
      maxLength: action.maxLength,
      keyboardType: action.keyboardType,
    );
    if (value != null) action.onChanged(value);
  }
}

class _OptionsSheet<T> extends StatelessWidget {
  const _OptionsSheet({
    required this.title,
    required this.options,
    required this.value,
    required this.textBuilder,
  });

  final Widget title;
  final List<T> options;
  final T value;
  final String Function(T value) textBuilder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DefaultTextStyle.merge(
              style: AppTextStyle.title3.of(context),
              child: title,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final option in options)
                    ListItem<void>(
                      title: Text(textBuilder(option)),
                      trailing: option == value
                          ? const GlyphIcon(Glyphs.check, size: 18)
                          : null,
                      onTap: () => Navigator.of(context).pop(option),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
