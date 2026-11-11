import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/dashboard/domain/water_system_state.dart';

void main() {
  group('WaterSystemState', () {
    group('isLow', () {
      test('returns true when tank level is below 20%', () {
        const state = WaterSystemState(
          tankLevelPercent: 15,
          refillActive: false,
          safetyLockout: false,
        );
        expect(state.isLow, isTrue);
      });

      test('returns false when tank level is at 20%', () {
        const state = WaterSystemState(
          tankLevelPercent: 20,
          refillActive: false,
          safetyLockout: false,
        );
        expect(state.isLow, isFalse);
      });

      test('returns false when tank level is above 20%', () {
        const state = WaterSystemState(
          tankLevelPercent: 80,
          refillActive: false,
          safetyLockout: false,
        );
        expect(state.isLow, isFalse);
      });
    });

    group('isCritical', () {
      test('returns true when tank level is below 10%', () {
        const state = WaterSystemState(
          tankLevelPercent: 5,
          refillActive: false,
          safetyLockout: false,
        );
        expect(state.isCritical, isTrue);
      });

      test('returns false when tank level is at 10%', () {
        const state = WaterSystemState(
          tankLevelPercent: 10,
          refillActive: false,
          safetyLockout: false,
        );
        expect(state.isCritical, isFalse);
      });

      test('returns false when tank level is above 10%', () {
        const state = WaterSystemState(
          tankLevelPercent: 50,
          refillActive: true,
          safetyLockout: false,
        );
        expect(state.isCritical, isFalse);
      });
    });

    group('properties', () {
      test('holds refillActive state', () {
        const state = WaterSystemState(
          tankLevelPercent: 80,
          refillActive: true,
          safetyLockout: false,
        );
        expect(state.refillActive, isTrue);
        expect(state.safetyLockout, isFalse);
      });

      test('holds safetyLockout state', () {
        const state = WaterSystemState(
          tankLevelPercent: 5,
          refillActive: false,
          safetyLockout: true,
        );
        expect(state.safetyLockout, isTrue);
        expect(state.refillActive, isFalse);
      });

      test('holds optional lastRefillAt', () {
        final now = DateTime.now();
        final state = WaterSystemState(
          tankLevelPercent: 80,
          refillActive: false,
          safetyLockout: false,
          lastRefillAt: now,
        );
        expect(state.lastRefillAt, now);
      });

      test('lastRefillAt is null by default', () {
        const state = WaterSystemState(
          tankLevelPercent: 80,
          refillActive: false,
          safetyLockout: false,
        );
        expect(state.lastRefillAt, isNull);
      });
    });
  });
}
