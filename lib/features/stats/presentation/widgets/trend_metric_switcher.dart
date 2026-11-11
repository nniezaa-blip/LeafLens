import 'package:flutter/material.dart';
import 'package:lextari/core/theme/app_colors.dart';
import 'package:lextari/features/stats/presentation/trend_metric.dart';
import 'package:lextari/shared/widgets/frosted_card.dart';

/// Pill-shaped segmented control for choosing the active [TrendMetric].
///
/// The selected segment is filled with a solid vibrant green pill and bold
/// text, while inactive segments render as plain text on the frosted track.
class TrendMetricSwitcher extends StatelessWidget {
  /// Creates a [TrendMetricSwitcher].
  const TrendMetricSwitcher({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// The currently active metric.
  final TrendMetric selected;

  /// Called when the user taps a different segment.
  final ValueChanged<TrendMetric> onChanged;

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      padding: const EdgeInsets.all(4),
      borderRadius: 50,
      blur: 10,
      child: Row(
        children: [
          for (final metric in TrendMetric.values)
            Expanded(
              child: _Segment(
                metric: metric,
                isSelected: metric == selected,
                onTap: () => onChanged(metric),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.metric,
    required this.isSelected,
    required this.onTap,
  });

  final TrendMetric metric;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 46,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mediumGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.mediumGreen.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            metric.label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
              color: isSelected
                  ? AppColors.white
                  : AppColors.offBlack.withValues(alpha: 0.65),
            ),
          ),
        ),
      ),
    );
  }
}
