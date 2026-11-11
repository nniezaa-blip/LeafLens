import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/core/theme/app_colors.dart';
import 'package:lextari/features/stats/presentation/trend_metric_provider.dart';
import 'package:lextari/features/stats/presentation/widgets/trend_chart_card.dart';
import 'package:lextari/features/stats/presentation/widgets/trend_metric_switcher.dart';

/// Stats / Graphs tab — shows 30-day trends for each sensor metric.
///
/// A segmented switcher at the top selects between temperature, humidity, and
/// moisture, and the frosted chart card below plots the chosen metric. The
/// selected metric lives in [selectedTrendMetricProvider] so the dashboard can
/// deep-link here with a specific metric preselected.
class StatsScreen extends ConsumerWidget {
  /// Creates a [StatsScreen].
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTrendMetricProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Header(),
          const SizedBox(height: 20),
          TrendMetricSwitcher(
            selected: selected,
            onChanged: (metric) =>
                ref.read(selectedTrendMetricProvider.notifier).select(metric),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: TrendChartCard(metric: selected),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '30-Day Trends',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Average readings across the last month',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}
