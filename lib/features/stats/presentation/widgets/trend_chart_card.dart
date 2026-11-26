import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/dashboard/domain/telemetry_history_point.dart';
import 'package:lextari/features/dashboard/providers/telemetry_providers.dart';
import 'package:lextari/features/stats/presentation/trend_metric.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/frosted_card.dart';

const double _gridStroke = AppSizes.line;
const double _indicatorStroke = 1.5;
const double _lineWidth = 3;
const double _dotRadius = 2.5;
const double _dotStroke = 1.5;
const double _touchDotRadius = 4.5;
const double _curveSmoothness = 0.25;
const double _areaAlpha = 0.28;

/// Rounded frosted card containing the 30-day line chart for a [TrendMetric].
///
/// Renders horizontal grid lines, labelled value and day axes, and a coloured
/// line with a soft gradient fill that updates when [metric] changes.
///
/// The plot is initially zoomed so roughly ten days fill the width and can be
/// dragged horizontally to slide between day 1 and day 30, while the value axis
/// stays pinned in place.
class TrendChartCard extends ConsumerStatefulWidget {
  /// Creates a [TrendChartCard].
  const TrendChartCard({required this.metric, super.key});

  /// The metric whose 30-day trend is plotted.
  final TrendMetric metric;

  @override
  ConsumerState<TrendChartCard> createState() => _TrendChartCardState();
}

class _TrendChartCardState extends ConsumerState<TrendChartCard> {
  /// How many times wider than the viewport the plot is laid out, i.e. how far
  /// the chart is zoomed in. A value of 3 shows about 10 days per screen.
  static const _initialScale = 3.0;

  late final TransformationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController(_initialTransform);
  }

  @override
  void didUpdateWidget(TrendChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.metric != widget.metric) {
      _controller.value = _initialTransform;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static Matrix4 get _initialTransform =>
      Matrix4.diagonal3Values(_initialScale, 1, 1);

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(
      telemetryHistoryProvider(widget.metric.apiKey),
    );
    return FrostedCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChartHeader(metric: widget.metric),
          const SizedBox(height: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6, top: 4),
              child: historyAsync.when(
                loading: _buildLoading,
                error: _buildError,
                data: (points) =>
                    points.isEmpty ? _buildEmpty() : _buildChart(points),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SkeletonPill(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var index = 0; index < 5; index++)
              const SkeletonPill(width: 26, height: 8),
          ],
        ),
      ],
    );
  }

  Widget _buildError(Object error, StackTrace stackTrace) {
    return const Center(
      child: ErrorState(
        label: 'Could not load trend',
        description: 'Check your connection and try again.',
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: EmptyState(
        label: 'No telemetry yet',
        description: 'Readings from the last 30 days will appear here.',
      ),
    );
  }

  Widget _buildChart(List<TelemetryHistoryPoint> points) {
    return LineChart(
      _buildChartData(
        widget.metric,
        _spotsFromHistory(widget.metric, points),
        context,
      ),
      duration: AppMotionTokens.chart,
      curve: Curves.easeInOutCubic,
      transformationConfig: FlTransformationConfig(
        scaleAxis: FlScaleAxis.horizontal,
        maxScale: _initialScale,
        scaleEnabled: false,
        transformationController: _controller,
      ),
    );
  }
}

//
// Chart data
//

List<FlSpot> _spotsFromHistory(
  TrendMetric metric,
  List<TelemetryHistoryPoint> points,
) {
  if (points.isEmpty) return const <FlSpot>[];
  final sorted = [...points]
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  final sliced = sorted.length > 30
      ? sorted.sublist(sorted.length - 30)
      : sorted;
  return [
    for (var i = 0; i < sliced.length; i++)
      FlSpot(
        (i + 1).toDouble(),
        sliced[i].value.clamp(metric.minY, metric.maxY),
      ),
  ];
}

/// Builds the full [LineChartData] configuration for [metric].
LineChartData _buildChartData(
  TrendMetric metric,
  List<FlSpot> spots,
  BuildContext context,
) {
  final scheme = context.colorScheme;
  final lineColor = metric.lineColor;

  return LineChartData(
    minX: 1,
    maxX: 30,
    minY: metric.minY,
    maxY: metric.maxY,
    clipData: const FlClipData.all(),
    gridData: FlGridData(
      drawVerticalLine: false,
      horizontalInterval: metric.yInterval,
      getDrawingHorizontalLine: (value) => FlLine(
        color: scheme.outlineVariant.withValues(alpha: AppOpacity.soft),
        strokeWidth: _gridStroke,
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border(
        left: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: AppOpacity.strong),
        ),
        bottom: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: AppOpacity.strong),
        ),
      ),
    ),
    titlesData: _titlesData(metric, context),
    lineBarsData: [_lineBar(metric, lineColor, spots, scheme)],
    lineTouchData: _touchData(metric, lineColor, context),
  );
}

FlTitlesData _titlesData(TrendMetric metric, BuildContext context) {
  final scheme = context.colorScheme;
  return FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: AxisTitles(
      axisNameWidget: Text(
        metric.unit,
        style: AppTextStyle.caption1
            .of(context, emphasized: true)
            .copyWith(
              color: scheme.onSurfaceVariant,
            ),
      ),
      axisNameSize: AppSpacing.s24,
      sideTitles: SideTitles(
        showTitles: true,
        interval: metric.yInterval,
        reservedSize: 34,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          meta: meta,
          space: 6,
          child: Text(
            value.toStringAsFixed(0),
            style: AppTextStyle.caption2
                .of(context)
                .copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: 1,
        reservedSize: 30,
        getTitlesWidget: (value, meta) {
          final day = value.round();
          final isBoundary = day == 1 || day == 30;
          final isInterval = day > 1 && day < 30 && day % 5 == 0;
          if (day < 1 || day > 30 || (!isBoundary && !isInterval)) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            meta: meta,
            space: 6,
            child: Text(
              'Day $day',
              style: AppTextStyle.caption2
                  .of(context, emphasized: true)
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          );
        },
      ),
    ),
  );
}

LineChartBarData _lineBar(
  TrendMetric metric,
  Color lineColor,
  List<FlSpot> spots,
  ColorScheme scheme,
) {
  return LineChartBarData(
    spots: spots,
    isCurved: true,
    curveSmoothness: _curveSmoothness,
    preventCurveOverShooting: true,
    color: lineColor,
    barWidth: _lineWidth,
    isStrokeCapRound: true,
    isStrokeJoinRound: true,
    dotData: FlDotData(
      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
        radius: _dotRadius,
        color: lineColor,
        strokeWidth: _dotStroke,
        strokeColor: scheme.surface,
      ),
    ),
    belowBarData: BarAreaData(
      show: true,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: _areaAlpha),
          lineColor.withValues(alpha: 0),
        ],
      ),
    ),
  );
}

LineTouchData _touchData(
  TrendMetric metric,
  Color lineColor,
  BuildContext context,
) {
  final scheme = context.colorScheme;
  return LineTouchData(
    touchTooltipData: LineTouchTooltipData(
      getTooltipColor: (_) => scheme.inverseSurface,
      tooltipBorderRadius: BorderRadius.circular(AppRadii.sm),
      tooltipPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
      getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
        return LineTooltipItem(
          'Day ${spot.x.round()}\n'
          '${spot.y.toStringAsFixed(1)} ${metric.unit}',
          TextStyle(
            color: scheme.onInverseSurface,
            fontSize: AppTextStyle.caption1.size,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    ),
    getTouchedSpotIndicator: (bar, indexes) => indexes.map((index) {
      return TouchedSpotIndicatorData(
        FlLine(
          color: lineColor.withValues(alpha: AppOpacity.muted),
          strokeWidth: _indicatorStroke,
        ),
        FlDotData(
          getDotPainter: (spot, percent, bar, i) => FlDotCirclePainter(
            radius: _touchDotRadius,
            color: lineColor,
            strokeColor: scheme.surface,
          ),
        ),
      );
    }).toList(),
  );
}

//
// Private widgets
//

class _ChartHeader extends StatelessWidget {
  const _ChartHeader({required this.metric});

  final TrendMetric metric;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final lineColor = metric.lineColor;

    return Row(
      children: [
        Container(
          width: AppSizes.trendHeaderIcon,
          height: AppSizes.trendHeaderIcon,
          decoration: BoxDecoration(
            color: lineColor.withValues(alpha: AppOpacity.tint),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: GlyphIcon(metric.icon, color: lineColor),
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.label,
                style: AppTextStyle.headline
                    .of(context, emphasized: true)
                    .copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                metric.axisLabel,
                style: AppTextStyle.caption1
                    .of(context)
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s10,
            vertical: AppSpacing.s6,
          ),
          decoration: BoxDecoration(
            color: lineColor.withValues(alpha: AppOpacity.tint),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(
            '30 Days',
            style: AppTextStyle.caption2
                .of(context, emphasized: true)
                .copyWith(color: lineColor),
          ),
        ),
      ],
    );
  }
}
