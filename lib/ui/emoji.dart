import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

/// Matches a single emoji, including joined and modifier sequences.
///
/// The pattern is intentionally compact: it covers pictographs, flags,
/// keycaps and the common joined forms without pulling in a Unicode table.
final RegExp emojiPattern = RegExp(
  r'[\u{1F1E6}-\u{1F1FF}]{2}'
  r'|[\u{1F300}-\u{1FAFF}]'
  r'|[\u{2600}-\u{27BF}]'
  r'|[\u{FE0F}\u{200D}\u{20E3}]',
  unicode: true,
);

final RegExp _letterPattern = RegExp(r'[\p{L}\p{N}]', unicode: true);

/// Returns the first emoji or letter of [text] for a compact monogram.
String firstEmojiOrLetter(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return '';
  final emoji = emojiPattern.firstMatch(trimmed);
  if (emoji != null && emoji.start == 0) {
    return emoji.group(0) ?? '';
  }
  final letter = _letterPattern.firstMatch(trimmed);
  return letter?.group(0)?.toUpperCase() ?? '';
}

/// A single emoji or letter shown in an icon-sized slot.
///
/// The mark animates with a short scale and fade whenever it changes, which
/// keeps profile and group icons from snapping between states.
class EmojiMonogram extends StatelessWidget {
  /// Creates an [EmojiMonogram] for [text].
  const EmojiMonogram(
    this.text, {
    super.key,
    this.size = 24,
    this.color,
  });

  /// Text whose first emoji or letter is shown.
  final String text;

  /// Side length of the monogram slot.
  final double size;

  /// Colour of the mark. Defaults to the icon theme colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final mark = firstEmojiOrLetter(text);
    final markColor = color ?? iconTheme.color;
    final style = AppTextStyle.custom(
      context,
      size: size * 0.62,
      leading: size * 0.62,
      weight: FontWeight.w600,
    ).copyWith(color: markColor);
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: _monogramTransition,
          child: EmojiText(
            mark,
            key: ValueKey<String>(mark),
            maxLines: 1,
            style: style,
          ),
        ),
      ),
    );
  }

  Widget _monogramTransition(Widget child, Animation<double> animation) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(scale: curved, child: child),
    );
  }
}
