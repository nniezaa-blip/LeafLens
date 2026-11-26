import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

/// Opens a form sheet that edits a single string.
Future<String?> showEntryDialog(
  BuildContext context, {
  required String title,
  String initialValue = '',
  FormFieldValidator<String>? validator,
  int? maxLength,
  TextInputType? keyboardType,
}) {
  return showFormSheet<String>(
    context: context,
    builder: (_) => EntryDialog(
      title: title,
      initialValue: initialValue,
      validator: validator,
      maxLength: maxLength,
      keyboardType: keyboardType,
    ),
  );
}

/// A form sheet with one text field, a cancel and a save action.
class EntryDialog extends StatefulWidget {
  /// Creates an [EntryDialog].
  const EntryDialog({
    required this.title,
    this.initialValue = '',
    this.validator,
    this.maxLength,
    this.keyboardType,
    super.key,
  });

  /// Dialog title and field hint.
  final String title;

  /// Value shown when the dialog opens.
  final String initialValue;

  /// Validates the value before saving.
  final FormFieldValidator<String>? validator;

  /// Maximum input length.
  final int? maxLength;

  /// Keyboard type for the field.
  final TextInputType? keyboardType;

  @override
  State<EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<EntryDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final error = widget.validator?.call(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: AppTextStyle.title3.of(context)),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: widget.keyboardType,
              maxLength: widget.maxLength,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(hintText: widget.title),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTextStyle.footnote
                    .of(context)
                    .copyWith(
                      color: context.colorScheme.error,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _submit,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
