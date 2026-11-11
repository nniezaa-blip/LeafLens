import 'package:lextari/core/config/app_config.dart';

/// Single telemetry data point with staleness tracking.
class SensorReading {
  /// Creates a [SensorReading] with the sensor [value],
  /// when it was [recordedAt], and the [unit] of measurement.
  const SensorReading({
    required this.value,
    required this.recordedAt,
    required this.unit,
  });

  /// Creates a [SensorReading] from a normalised telemetry entry
  /// (`{ ts, value }`) as sent by the FastAPI gateway.
  factory SensorReading.fromTelemetryJson(
    Map<String, dynamic> json,
    String unit,
  ) {
    return SensorReading(
      value: double.parse(json['value'] as String),
      recordedAt: DateTime.fromMillisecondsSinceEpoch(json['ts'] as int),
      unit: unit,
    );
  }

  /// The sensor reading value in [unit] units.
  final double value;

  /// The timestamp when this reading was recorded by the ESP32.
  final DateTime recordedAt;

  /// The unit of measurement (e.g. '%', '°C').
  final String unit;

  /// How long ago this reading was recorded.
  Duration get age => DateTime.now().difference(recordedAt);

  /// Whether this reading is older than [AppConfig.staleThreshold].
  bool get isStale => age > AppConfig.staleThreshold;

  /// Human-readable label describing how old this reading is.
  String get ageLabel {
    if (age.inMinutes < 1) return 'just now';
    if (age.inMinutes < 60) return '${age.inMinutes}m ago';
    if (age.inHours < 24) return '${age.inHours}h ago';
    return '${age.inDays}d ago';
  }
}
