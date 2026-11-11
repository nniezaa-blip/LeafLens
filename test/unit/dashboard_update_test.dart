import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/dashboard/domain/dashboard_update.dart';

void main() {
  group('DashboardUpdate', () {
    group('fromJson', () {
      test('parses telemetry update', () {
        final json = {
          'type': 'telemetry',
          'soilMoisture': 55.3,
          'temperature': 23.1,
          'humidity': 65.0,
          'waterLevel': 80.0,
        };
        final update = DashboardUpdate.fromJson(json);
        expect(update, isA<TelemetryUpdate>());
        final telemetry = update as TelemetryUpdate;
        expect(telemetry.soilMoisture, 55.3);
        expect(telemetry.temperature, 23.1);
        expect(telemetry.humidity, 65.0);
        expect(telemetry.waterLevel, 80.0);
      });

      test('parses telemetry with null fields', () {
        final json = {
          'type': 'telemetry',
        };
        final update = DashboardUpdate.fromJson(json);
        expect(update, isA<TelemetryUpdate>());
        final telemetry = update as TelemetryUpdate;
        expect(telemetry.soilMoisture, isNull);
        expect(telemetry.temperature, isNull);
      });

      test('parses GHS update', () {
        final json = {
          'type': 'ghs',
          'score': 85.0,
          'status': 'optimal',
        };
        final update = DashboardUpdate.fromJson(json);
        expect(update, isA<GHSUpdate>());
        final ghs = update as GHSUpdate;
        expect(ghs.score, 85.0);
        expect(ghs.status, 'optimal');
      });

      test('parses water system update', () {
        final json = {
          'type': 'waterSystem',
          'water_level': 45.0,
          'refill_active': true,
          'safety_lockout': false,
        };
        final update = DashboardUpdate.fromJson(json);
        expect(update, isA<WaterSystemUpdate>());
        final ws = update as WaterSystemUpdate;
        expect(ws.tankLevelPercent, 45.0);
        expect(ws.refillActive, isTrue);
        expect(ws.safetyLockout, isFalse);
      });

      test('parses ack update', () {
        final json = {
          'type': 'ack',
          'success': true,
        };
        final update = DashboardUpdate.fromJson(json);
        expect(update, isA<AckUpdate>());
        final ack = update as AckUpdate;
        expect(ack.success, isTrue);
      });

      test('falls back to ack for unknown type', () {
        final json = {
          'type': 'unknown_type',
          'success': false,
        };
        final update = DashboardUpdate.fromJson(json);
        expect(update, isA<AckUpdate>());
      });
    });
  });
}
