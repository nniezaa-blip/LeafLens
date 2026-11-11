import 'package:flutter/material.dart';

/// The three environmental metrics tracked on the 30-day trends screen.
enum TrendMetric {
  /// Air temperature in degrees Celsius.
  temperature,

  /// Relative humidity in percent.
  humidity,

  /// Soil moisture in percent.
  moisture,
}

/// Presentation metadata for each [TrendMetric].
///
/// Keeps the label, unit, axis bounds, and line colour for a metric in one
/// place so the switcher and chart stay in sync.
extension TrendMetricX on TrendMetric {
  /// Human readable name shown in headers and the segmented switcher.
  String get label => switch (this) {
    TrendMetric.temperature => 'Temperature',
    TrendMetric.humidity => 'Humidity',
    TrendMetric.moisture => 'Moisture',
  };

  /// Short unit rendered on the value axis and inside tooltips.
  String get unit => switch (this) {
    TrendMetric.temperature => '°C',
    TrendMetric.humidity => '%',
    TrendMetric.moisture => '%',
  };

  /// Full axis label including the unit, shown as the chart subtitle.
  String get axisLabel => switch (this) {
    TrendMetric.temperature => 'Temperature (°C)',
    TrendMetric.humidity => 'Relative Humidity (RH %)',
    TrendMetric.moisture => 'Moisture (%)',
  };

  /// Colour of the plotted line and its associated accents.
  Color get lineColor => switch (this) {
    TrendMetric.temperature => const Color(0xFF3B82F6),
    TrendMetric.humidity => const Color(0xFFA855F7),
    TrendMetric.moisture => const Color(0xFFEC4899),
  };

  /// Lower bound of the value axis.
  double get minY => switch (this) {
    TrendMetric.temperature => 5,
    TrendMetric.humidity => 0,
    TrendMetric.moisture => 0,
  };

  /// Upper bound of the value axis.
  double get maxY => switch (this) {
    TrendMetric.temperature => 40,
    TrendMetric.humidity => 100,
    TrendMetric.moisture => 100,
  };

  /// Spacing between value-axis grid lines and labels.
  double get yInterval => switch (this) {
    TrendMetric.temperature => 5,
    TrendMetric.humidity => 20,
    TrendMetric.moisture => 20,
  };

  /// Icon representing the metric.
  IconData get icon => switch (this) {
    TrendMetric.temperature => Icons.thermostat,
    TrendMetric.humidity => Icons.water_drop_outlined,
    TrendMetric.moisture => Icons.grass,
  };
}
