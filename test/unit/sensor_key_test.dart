import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/dashboard/domain/sensor_key.dart';

void main() {
  group('SensorKey', () {
    test('has 4 values', () {
      expect(SensorKey.values.length, 4);
    });

    test('soilMoisture has correct telemetryKey and unit', () {
      expect(SensorKey.soilMoisture.telemetryKey, 'soil_moisture');
      expect(SensorKey.soilMoisture.unit, '%');
    });

    test('temperature has correct telemetryKey and unit', () {
      expect(SensorKey.temperature.telemetryKey, 'temperature');
      expect(SensorKey.temperature.unit, '°C');
    });

    test('humidity has correct telemetryKey and unit', () {
      expect(SensorKey.humidity.telemetryKey, 'humidity');
      expect(SensorKey.humidity.unit, '%');
    });

    test('waterLevel has correct telemetryKey and unit', () {
      expect(SensorKey.waterLevel.telemetryKey, 'water_level');
      expect(SensorKey.waterLevel.unit, '%');
    });

    group('fromTelemetryKey', () {
      test('resolves soil_moisture', () {
        expect(
          SensorKey.fromTelemetryKey('soil_moisture'),
          SensorKey.soilMoisture,
        );
      });

      test('resolves temperature', () {
        expect(
          SensorKey.fromTelemetryKey('temperature'),
          SensorKey.temperature,
        );
      });

      test('resolves humidity', () {
        expect(
          SensorKey.fromTelemetryKey('humidity'),
          SensorKey.humidity,
        );
      });

      test('resolves water_level', () {
        expect(
          SensorKey.fromTelemetryKey('water_level'),
          SensorKey.waterLevel,
        );
      });

      test('throws StateError for unknown key', () {
        expect(
          () => SensorKey.fromTelemetryKey('unknown'),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
