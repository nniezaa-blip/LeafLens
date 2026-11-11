import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/stats/presentation/trend_metric.dart';

/// Holds the metric currently selected on the 30-day trends screen.
///
/// Lets the dashboard's "More" links deep-link into the trends screen with
/// the matching metric already selected.
final selectedTrendMetricProvider =
    NotifierProvider<SelectedTrendMetricNotifier, TrendMetric>(
      SelectedTrendMetricNotifier.new,
    );

/// Notifier backing [selectedTrendMetricProvider].
class SelectedTrendMetricNotifier extends Notifier<TrendMetric> {
  @override
  TrendMetric build() => TrendMetric.temperature;

  /// Selects [metric] as the active trend metric.
  void select(TrendMetric metric) {
    if (metric == state) return;
    state = metric;
  }
}
