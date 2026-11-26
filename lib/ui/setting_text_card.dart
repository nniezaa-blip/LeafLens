import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

/// A compact text card used for choices and settings.
class SettingTextCard extends StatelessWidget {
  /// Creates a [SettingTextCard].
  const SettingTextCard(
    this.text, {
    required this.onPressed,
    super.key,
    this.isSelected,
  });

  /// Text shown in the card.
  final String text;

  /// Whether the card is selected.
  final bool? isSelected;

  /// Called when the card is pressed.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final selected = isSelected == true;
    return Card(
      onPressed: onPressed,
      isSelected: isSelected,
      fillsSelection: true,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: AppTextStyle.subheadline
              .of(context)
              .copyWith(
                color: selected ? context.colorScheme.onPrimary : null,
              ),
        ),
      ),
    );
  }
}
