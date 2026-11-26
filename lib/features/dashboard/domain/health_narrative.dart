import 'package:lextari/features/dashboard/domain/growth_health_score.dart';
import 'package:lextari/features/dashboard/domain/sensor_key.dart';
import 'package:lextari/features/dashboard/domain/sensor_reading.dart';

/// One sentence describing the plant's condition and the next action.
///
/// The backend's AI recommendation replaces this text later; the card only
/// ever shows one sentence, so the contract stays the same.
String healthNarrative({
  required HealthStatus status,
  required Map<SensorKey, SensorReading> telemetry,
}) {
  if (telemetry.isEmpty) {
    return 'Waiting for the first reading.';
  }

  final soil = telemetry[SensorKey.soilMoisture];
  final water = telemetry[SensorKey.waterLevel];

  if (soil != null && soil.value < 20) {
    return 'Soil is dry. Water the plant.';
  }
  if (soil != null && soil.value > 80) {
    return 'Soil is too wet. Pause watering.';
  }
  if (water != null && water.value > 100) {
    return 'Water level is raw. Check the sensor calibration.';
  }
  if (water != null && water.value < 20) {
    return 'Water tank is low. Refill soon.';
  }

  return switch (status) {
    HealthStatus.optimal => 'Conditions are stable. Keep the current schedule.',
    HealthStatus.moderate =>
      'Conditions are mostly stable. Watch the soil moisture.',
    HealthStatus.caution =>
      'The plant needs attention. Check soil and water.',
    HealthStatus.danger =>
      'The plant is stressed. Adjust watering and check the sensors.',
    HealthStatus.critical =>
      'Immediate action needed. Check the tank and soil sensor.',
  };
}
