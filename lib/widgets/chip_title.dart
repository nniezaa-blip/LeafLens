import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

/// A small chip showing an expiry date.
class ExpireChip extends StatelessWidget {
  /// Creates an [ExpireChip].
  const ExpireChip({required this.expire, super.key});

  /// The expiry moment.
  final DateTime expire;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = expire.isBefore(DateTime.now())
        ? colorScheme.error
        : colorScheme.primary;
    return Tooltip(
      message: 'Expires',
      child: TonalChip(
        label: _formatDate(expire),
        color: color.withValues(alpha: 0.15),
        foregroundColor: color,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

/// A title with an optional count chip and expiry chip.
class ChipTitle extends StatelessWidget {
  /// Creates a [ChipTitle].
  const ChipTitle({
    required this.title,
    this.chip,
    this.expire,
    this.style,
    super.key,
  });

  /// Title text.
  final String title;

  /// Optional count or status label.
  final String? chip;

  /// Optional expiry date.
  final DateTime? expire;

  /// Optional title style.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final chip = this.chip;
    final expire = this.expire;
    if (chip == null && expire == null) {
      return Text(
        title,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (chip != null) ...[
          const SizedBox(width: 8),
          TonalChip(
            label: chip,
            color: context.colorScheme.surfaceContainerHighest,
            foregroundColor: context.colorScheme.onSurfaceVariant,
          ),
        ],
        if (expire != null) ...[
          const SizedBox(width: 8),
          ExpireChip(expire: expire),
        ],
      ],
    );
  }
}
