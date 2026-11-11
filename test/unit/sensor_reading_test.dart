import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/core/config/app_config.dart';
import 'package:lextari/features/dashboard/domain/sensor_reading.dart';

void main() {
  group('SensorReading', () {
    final now = DateTime.now();

    test('holds value, recordedAt, and unit', () {
      final reading = SensorReading(
        value: 42.5,
        recordedAt: now,
        unit: '%',
      );
      expect(reading.value, 42.5);
      expect(reading.recordedAt, now);
      expect(reading.unit, '%');
    });

    group('fromTelemetryJson', () {
      test('parses normalised telemetry entry', () {
        final ts = now.millisecondsSinceEpoch;
        final json = {
          'value': '55.3',
          'ts': ts,
        };
        final reading = SensorReading.fromTelemetryJson(json, '°C');
        expect(reading.value, 55.3);
        expect(
          reading.recordedAt.millisecondsSinceEpoch,
          ts,
        );
        expect(reading.unit, '°C');
      });

      test('parses integer-like value string', () {
        final json = {
          'value': '42',
          'ts': 1700000000000,
        };
        final reading = SensorReading.fromTelemetryJson(json, '%');
        expect(reading.value, 42.0);
      });
    });

    group('age', () {
      test('returns duration since recordedAt', () {
        final reading = SensorReading(
          value: 50,
          recordedAt: now.subtract(const Duration(minutes: 5)),
          unit: '%',
        );
        expect(reading.age.inMinutes, 5);
      });
    });

    group('isStale', () {
      test('returns true when older than staleThreshold', () {
        final staleMinutes = AppConfig.staleThreshold.inMinutes + 1;
        final reading = SensorReading(
          value: 50,
          recordedAt: now.subtract(Duration(minutes: staleMinutes)),
          unit: '%',
        );
        expect(reading.isStale, isTrue);
      });

      test('returns false when within staleThreshold', () {
        final reading = SensorReading(
          value: 50,
          recordedAt: now,
          unit: '%',
        );
        expect(reading.isStale, isFalse);
      });
    });

    group('ageLabel', () {
      test('shows "just now" for < 1 minute', () {
        final reading = SensorReading(
          value: 50,
          recordedAt: now,
          unit: '%',
        );
        expect(reading.ageLabel, 'just now');
      });

      test('shows "Xm ago" for < 60 minutes', () {
        final reading = SensorReading(
          value: 50,
          recordedAt: now.subtract(const Duration(minutes: 15)),
          unit: '%',
        );
        expect(reading.ageLabel, '15m ago');
      });

      test('shows "Xh ago" for < 24 hours', () {
        final reading = SensorReading(
          value: 50,
          recordedAt: now.subtract(const Duration(hours: 3)),
          unit: '%',
        );
        expect(reading.ageLabel, '3h ago');
      });

      test('shows "Xd ago" for >= 24 hours', () {
        final reading = SensorReading(
          value: 50,
          recordedAt: now.subtract(const Duration(days: 2)),
          unit: '%',
        );
        expect(reading.ageLabel, '2d ago');
      });
    });
  });
}
