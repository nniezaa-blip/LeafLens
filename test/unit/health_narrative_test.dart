import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/dashboard/domain/growth_health_score.dart';
import 'package:lextari/features/dashboard/domain/health_narrative.dart';
import 'package:lextari/features/dashboard/domain/sensor_key.dart';
import 'package:lextari/features/dashboard/domain/sensor_reading.dart';

void main() {
  SensorReading reading(SensorKey key, double value) {
    return SensorReading(
      value: value,
      recordedAt: DateTime(2026),
      unit: key.unit,
    );
  }

  test('tells the reader to water dry soil', () {
    final telemetry = {
      SensorKey.soilMoisture: reading(SensorKey.soilMoisture, 12),
      SensorKey.temperature: reading(SensorKey.temperature, 23),
      SensorKey.humidity: reading(SensorKey.humidity, 55),
    };
    expect(
      healthNarrative(status: HealthStatus.danger, telemetry: telemetry),
      'Soil is dry. Water the plant.',
    );
  });

  test('tells the reader to pause watering wet soil', () {
    final telemetry = {
      SensorKey.soilMoisture: reading(SensorKey.soilMoisture, 90),
    };
    expect(
      healthNarrative(status: HealthStatus.caution, telemetry: telemetry),
      'Soil is too wet. Pause watering.',
    );
  });

  test('warns about a raw water level', () {
    final telemetry = {
      SensorKey.waterLevel: reading(SensorKey.waterLevel, 409),
    };
    expect(
      healthNarrative(status: HealthStatus.caution, telemetry: telemetry),
      'Water level is raw. Check the sensor calibration.',
    );
  });

  test('keeps a stable plant on the current schedule', () {
    final telemetry = {
      SensorKey.soilMoisture: reading(SensorKey.soilMoisture, 48),
      SensorKey.temperature: reading(SensorKey.temperature, 23),
      SensorKey.humidity: reading(SensorKey.humidity, 58),
    };
    expect(
      healthNarrative(status: HealthStatus.optimal, telemetry: telemetry),
      'Conditions are stable. Keep the current schedule.',
    );
  });

  test('waits when there is no telemetry', () {
    expect(
      healthNarrative(
        status: HealthStatus.critical,
        telemetry: const {},
      ),
      'Waiting for the first reading.',
    );
  });
}
