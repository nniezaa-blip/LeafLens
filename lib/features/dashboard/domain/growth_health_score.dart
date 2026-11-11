import 'package:lextari/features/dashboard/domain/sensor_key.dart';
import 'package:lextari/features/dashboard/domain/sensor_reading.dart';

/// Threshold ranges for Growth Health Score computation.
/// Defaults are for fragile indoor plants. User-configurable per species.
class HealthConfig {
  /// Creates a [HealthConfig] with per-sensor min/max ranges.
  const HealthConfig({
    this.soilMoistureMin = 40,
    this.soilMoistureMax = 70,
    this.temperatureMin = 18,
    this.temperatureMax = 28,
    this.humidityMin = 50,
    this.humidityMax = 80,
  });

  /// Minimum acceptable soil moisture percentage.
  final double soilMoistureMin;

  /// Maximum acceptable soil moisture percentage.
  final double soilMoistureMax;

  /// Minimum acceptable temperature in Celsius.
  final double temperatureMin;

  /// Maximum acceptable temperature in Celsius.
  final double temperatureMax;

  /// Minimum acceptable humidity percentage.
  final double humidityMin;

  /// Maximum acceptable humidity percentage.
  final double humidityMax;
}

/// Categorised health level used throughout the UI for colour-coding.
enum HealthStatus {
  /// Plant health is in the best possible range.
  optimal,

  /// Plant health is acceptable but could improve.
  moderate,

  /// Plant health is declining and needs attention.
  caution,

  /// Plant health is at a dangerous low.
  danger,

  /// Plant health is critically low and requires immediate action.
  critical,
}

/// Result of a single Growth Health Score computation.
class HealthScoreResult {
  /// Creates a [HealthScoreResult] with the computed [score], [status],
  /// per-component [componentScores], and the [computedAt] timestamp.
  const HealthScoreResult({
    required this.score,
    required this.status,
    required this.componentScores,
    required this.computedAt,
  });

  /// Overall health score as a percentage (0–100).
  final double score;

  /// Categorised health level derived from the score.
  final HealthStatus status;

  /// Individual scores for each tracked [SensorKey].
  final Map<SensorKey, double> componentScores;

  /// Timestamp when this score was computed.
  final DateTime computedAt;

  /// Whether the score is critically low (below 30).
  bool get isCritical => score < 30;

  /// Whether the score is in danger range (below 50).
  bool get isDanger => score < 50;

  /// Whether the score is optimal (80 or above).
  bool get isOptimal => score >= 80;
}

/// Pure domain logic — zero Flutter imports, fully testable.
/// Computes an overall plant health score from sensor readings.
class GrowthHealthScore {
  static const Map<SensorKey, double> _weights = {
    SensorKey.soilMoisture: 0.50,
    SensorKey.temperature: 0.30,
    SensorKey.humidity: 0.20,
  };

  /// Computes a [HealthScoreResult] from the given [readings] and [config].
  /// Uses a bell-curve scoring model weighted by each sensor's importance.
  static HealthScoreResult compute(
    Map<SensorKey, SensorReading> readings,
    HealthConfig config,
  ) {
    final scores = <SensorKey, double>{};

    final moisture = readings[SensorKey.soilMoisture]?.value;
    if (moisture != null) {
      scores[SensorKey.soilMoisture] = _bellScore(
        moisture,
        config.soilMoistureMin,
        config.soilMoistureMax,
      );
    }

    final temp = readings[SensorKey.temperature]?.value;
    if (temp != null) {
      scores[SensorKey.temperature] = _bellScore(
        temp,
        config.temperatureMin,
        config.temperatureMax,
      );
    }

    final humidity = readings[SensorKey.humidity]?.value;
    if (humidity != null) {
      scores[SensorKey.humidity] = _bellScore(
        humidity,
        config.humidityMin,
        config.humidityMax,
      );
    }

    var totalWeight = 0.0;
    var weightedSum = 0.0;
    for (final entry in scores.entries) {
      final weight = _weights[entry.key] ?? 0.0;
      weightedSum += entry.value * weight;
      totalWeight += weight;
    }

    final score = totalWeight > 0 ? (weightedSum / totalWeight) * 100 : 0.0;

    return HealthScoreResult(
      score: score.clamp(0.0, 100.0),
      status: _statusFrom(score),
      componentScores: scores,
      computedAt: DateTime.now(),
    );
  }

  /// Bell curve: 1.0 at midpoint, 0.0 at or beyond bounds.
  static double _bellScore(double value, double min, double max) {
    if (value < min || value > max) return 0;
    final mid = (min + max) / 2;
    final range = (max - min) / 2;
    return 1.0 - (value - mid).abs() / range;
  }

  static HealthStatus _statusFrom(double score) => switch (score) {
    >= 80 => HealthStatus.optimal,
    >= 65 => HealthStatus.moderate,
    >= 50 => HealthStatus.caution,
    >= 30 => HealthStatus.danger,
    _ => HealthStatus.critical,
  };
}
