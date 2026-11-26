import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/stats/presentation/trend_metric_provider.dart';
import 'package:lextari/features/stats/presentation/widgets/trend_chart_card.dart';
import 'package:lextari/features/stats/presentation/widgets/trend_metric_switcher.dart';
import 'package:lextari/ui/ui.dart';

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

    return Scaffold(
      title: 'Stats',
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, context.contentTopPadding, 20, 0),
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
        Text(
          '30-Day Trends',
          style: AppTypography.headlineMedium.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Average readings across the last month',
          style: AppTypography.bodyMedium.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
