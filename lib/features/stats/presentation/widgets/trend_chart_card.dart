import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lextari/core/theme/app_colors.dart';
import 'package:lextari/features/stats/presentation/trend_metric.dart';
import 'package:lextari/shared/widgets/frosted_card.dart';

/// Rounded frosted card containing the 30-day line chart for a [TrendMetric].
///
/// Renders horizontal grid lines, labelled value and day axes, and a coloured
/// line with a soft gradient fill that updates when [metric] changes.
///
/// The plot is initially zoomed so roughly ten days fill the width and can be
/// dragged horizontally to slide between day 1 and day 30, while the value axis
/// stays pinned in place.
class TrendChartCard extends StatefulWidget {
  /// Creates a [TrendChartCard].
  const TrendChartCard({required this.metric, super.key});

  /// The metric whose 30-day trend is plotted.
  final TrendMetric metric;

  @override
  State<TrendChartCard> createState() => _TrendChartCardState();
}

class _TrendChartCardState extends State<TrendChartCard> {
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
              child: LineChart(
                _buildChartData(widget.metric),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOutCubic,
                transformationConfig: FlTransformationConfig(
                  scaleAxis: FlScaleAxis.horizontal,
                  maxScale: _initialScale,
                  scaleEnabled: false,
                  transformationController: _controller,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// Chart data
//

/// Builds the full [LineChartData] configuration for [metric].
LineChartData _buildChartData(TrendMetric metric) {
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
        color: AppColors.offBlack.withValues(alpha: 0.08),
        strokeWidth: 1,
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border(
        left: BorderSide(color: AppColors.offBlack.withValues(alpha: 0.15)),
        bottom: BorderSide(color: AppColors.offBlack.withValues(alpha: 0.15)),
      ),
    ),
    titlesData: _titlesData(metric),
    lineBarsData: [_lineBar(metric, lineColor)],
    lineTouchData: _touchData(metric, lineColor),
  );
}

FlTitlesData _titlesData(TrendMetric metric) {
  return FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: AxisTitles(
      axisNameWidget: Text(
        metric.unit,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textGrey,
        ),
      ),
      axisNameSize: 26,
      sideTitles: SideTitles(
        showTitles: true,
        interval: metric.yInterval,
        reservedSize: 34,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          meta: meta,
          space: 6,
          child: Text(
            value.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
            ),
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
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
          );
        },
      ),
    ),
  );
}

LineChartBarData _lineBar(TrendMetric metric, Color lineColor) {
  return LineChartBarData(
    spots: _trendSpots(metric),
    isCurved: true,
    curveSmoothness: 0.25,
    preventCurveOverShooting: true,
    color: lineColor,
    barWidth: 3,
    isStrokeCapRound: true,
    isStrokeJoinRound: true,
    dotData: FlDotData(
      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
        radius: 2.5,
        color: lineColor,
        strokeWidth: 1.5,
        strokeColor: AppColors.white,
      ),
    ),
    belowBarData: BarAreaData(
      show: true,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.28),
          lineColor.withValues(alpha: 0),
        ],
      ),
    ),
  );
}

LineTouchData _touchData(TrendMetric metric, Color lineColor) {
  return LineTouchData(
    touchTooltipData: LineTouchTooltipData(
      getTooltipColor: (_) => AppColors.offBlack.withValues(alpha: 0.88),
      tooltipBorderRadius: BorderRadius.circular(12),
      tooltipPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
        return LineTooltipItem(
          'Day ${spot.x.round()}\n'
          '${spot.y.toStringAsFixed(1)} ${metric.unit}',
          const TextStyle(
            color: AppColors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        );
      }).toList(),
    ),
    getTouchedSpotIndicator: (bar, indexes) => indexes.map((index) {
      return TouchedSpotIndicatorData(
        FlLine(
          color: lineColor.withValues(alpha: 0.5),
          strokeWidth: 1.5,
        ),
        FlDotData(
          getDotPainter: (spot, percent, bar, i) => FlDotCirclePainter(
            radius: 4.5,
            color: lineColor,
            strokeWidth: 2,
            strokeColor: AppColors.white,
          ),
        ),
      );
    }).toList(),
  );
}

/// Generates deterministic sample spots for [metric] across 30 days.
///
/// A sine wave provides the seasonal shape and a smaller ripple adds texture,
/// so the placeholder data reads like a real monthly trend. Replace with
/// telemetry once historical sensor data is wired up.
List<FlSpot> _trendSpots(TrendMetric metric) {
  final (baseline, amplitude) = switch (metric) {
    TrendMetric.temperature => (22.0, 7.0),
    TrendMetric.humidity => (62.0, 15.0),
    TrendMetric.moisture => (55.0, 24.0),
  };

  return [
    for (var day = 1; day <= 30; day++)
      FlSpot(
        day.toDouble(),
        _valueFor(
          day,
          baseline,
          amplitude,
        ).clamp(metric.minY, metric.maxY),
      ),
  ];
}

double _valueFor(int day, double baseline, double amplitude) {
  final wave = math.sin(day / 30 * 2 * math.pi) * amplitude;
  final ripple = math.sin(day * 1.6) * amplitude * 0.25;
  return baseline + wave + ripple;
}

//
// Private widgets
//

class _ChartHeader extends StatelessWidget {
  const _ChartHeader({required this.metric});

  final TrendMetric metric;

  @override
  Widget build(BuildContext context) {
    final lineColor = metric.lineColor;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: lineColor.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(metric.icon, size: 20, color: lineColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.offBlack,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                metric.axisLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.offBlack.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: lineColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            '30 Days',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: lineColor,
            ),
          ),
        ),
      ],
    );
  }
}
