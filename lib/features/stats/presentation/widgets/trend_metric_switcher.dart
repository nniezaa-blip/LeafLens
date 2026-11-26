import 'package:lextari/features/stats/presentation/trend_metric.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/frosted_card.dart';

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
      padding: const EdgeInsets.all(AppSpacing.s4),
      borderRadius: AppRadii.pill,
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
    final scheme = context.colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppMotionTokens.segment,
        curve: Curves.easeOutCubic,
        height: AppSizes.trendSwitcherHeight,
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: AppOpacity.soft),
                    blurRadius: AppSpacing.s10,
                    offset: const Offset(0, AppSpacing.s4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            metric.label,
            style: AppTextStyle.subheadline
                .of(context, emphasized: isSelected)
                .copyWith(
                  color: isSelected
                      ? scheme.onPrimary
                      : scheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }
}
