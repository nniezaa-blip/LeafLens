import 'package:flutter_test/flutter_test.dart';

import 'package:lextari/features/dashboard/domain/growth_health_score.dart';
import 'package:lextari/features/dashboard/domain/sensor_key.dart';
import 'package:lextari/features/dashboard/domain/sensor_reading.dart';

void main() {
  group('GrowthHealthScore.compute', () {
    final now = DateTime.now();
    const defaultConfig = HealthConfig();

    SensorReading reading(double value) => SensorReading(
      value: value,
      recordedAt: now,
      unit: '%',
    );

    group('bell curve scoring', () {
      test('returns optimal score at midpoint of range', () {
        // Midpoint of soil moisture [40, 70] = 55
        final readings = {
          SensorKey.soilMoisture: reading(55),
          SensorKey.temperature: reading(23),
          SensorKey.humidity: reading(65),
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);

        expect(result.score, greaterThan(95));
        expect(result.status, HealthStatus.optimal);
      });

      test('returns 0 for reading below minimum', () {
        final readings = {
          SensorKey.soilMoisture: reading(30), // below 40
          SensorKey.temperature: reading(23),
          SensorKey.humidity: reading(65),
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);

        // soilMoisture scores 0, temp scores 1.0, humidity scores 1.0
        // weightedSum = 0×0.5 + 1.0×0.3 + 1.0×0.2 = 0.5
        // score = 0.5 / 1.0 × 100 = 50.0
        expect(result.score, closeTo(50.0, 0.01));
        expect(result.status, HealthStatus.caution);
      });

      test('returns 0 for reading above maximum', () {
        final readings = {
          SensorKey.soilMoisture: reading(75), // above 70
          SensorKey.temperature: reading(23),
          SensorKey.humidity: reading(65),
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);

        expect(result.score, closeTo(50.0, 0.01));
        expect(result.status, HealthStatus.caution);
      });

      test('returns 0 for reading at boundary minimum', () {
        final readings = {
          SensorKey.soilMoisture: reading(40), // exactly at min
          SensorKey.humidity: reading(65),
          SensorKey.temperature: reading(23),
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);

        // soilMoisture scores 0 at boundary
        expect(result.componentScores[SensorKey.soilMoisture], 0.0);
      });

      test('returns 0 for reading at boundary maximum', () {
        final readings = {
          SensorKey.soilMoisture: reading(70), // exactly at max
          SensorKey.humidity: reading(65),
          SensorKey.temperature: reading(23),
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);

        expect(result.componentScores[SensorKey.soilMoisture], 0.0);
      });

      test('scores 0.5 at quarter and three-quarter points', () {
        final readings = {
          SensorKey.soilMoisture: reading(47.5), // quarter way [40, 70]
          SensorKey.temperature: reading(30), // above max 28 → 0
          SensorKey.humidity: reading(65), // optimal
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);

        // soilMoisture: (55-47.5)/15 = 0.5
        expect(
          result.componentScores[SensorKey.soilMoisture],
          closeTo(0.5, 0.01),
        );
      });
    });

    group('weighted scoring', () {
      test('weights soil moisture at 50%', () {
        // Bad moisture, perfect others
        final readings = {
          SensorKey.soilMoisture: reading(30), // 0
          SensorKey.temperature: reading(23), // 1.0
          SensorKey.humidity: reading(65), // 1.0
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);

        // (0×0.5 + 1.0×0.3 + 1.0×0.2) / 1.0 × 100 = 50
        expect(result.score, closeTo(50.0, 0.01));
      });

      test('weights temperature at 30%', () {
        final readings = {
          SensorKey.soilMoisture: reading(55), // 1.0
          SensorKey.temperature: reading(12), // below 18 → 0
          SensorKey.humidity: reading(65), // 1.0
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);

        // (1.0×0.5 + 0×0.3 + 1.0×0.2) / 1.0 × 100 = 70
        expect(result.score, closeTo(70.0, 0.01));
      });

      test('weights humidity at 20%', () {
        final readings = {
          SensorKey.soilMoisture: reading(55), // 1.0
          SensorKey.temperature: reading(23), // 1.0
          SensorKey.humidity: reading(30), // below 50 → 0
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);

        // (1.0×0.5 + 1.0×0.3 + 0×0.2) / 1.0 × 100 = 80
        expect(result.score, closeTo(80.0, 0.01));
      });
    });

    group('partial data handling', () {
      test('handles missing soil moisture sensor', () {
        final readings = {
          SensorKey.temperature: reading(23),
          SensorKey.humidity: reading(65),
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);

        // Only 2 sensors: (1.0×0.3 + 1.0×0.2) / 0.5 × 100 = 100
        expect(result.score, closeTo(100.0, 0.01));
      });

      test('handles only one sensor available', () {
        final readings = {
          SensorKey.temperature: reading(12), // below 18 → 0
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);

        expect(result.score, 0.0);
      });

      test('returns 0 when no sensors available', () {
        final result = GrowthHealthScore.compute({}, defaultConfig);
        expect(result.score, 0.0);
        expect(result.status, HealthStatus.critical);
      });

      test('handles missing humidity', () {
        final readings = {
          SensorKey.soilMoisture: reading(55),
          SensorKey.temperature: reading(23),
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);

        // (1.0×0.5 + 1.0×0.3) / 0.8 × 100 = 100
        expect(result.score, closeTo(100.0, 0.01));
      });
    });

    group('status thresholds', () {
      test('optimal at score >= 80', () {
        final readings = {
          SensorKey.soilMoisture: reading(55),
          SensorKey.temperature: reading(23),
          SensorKey.humidity: reading(65),
        };
        final result = GrowthHealthScore.compute(readings, defaultConfig);

        expect(result.status, HealthStatus.optimal);
        expect(result.score, greaterThanOrEqualTo(80));
      });

      test('moderate at score 65-79', () {
        // Push score to ~75: moisture at 25th percentile (0.5), temp/humidity optimal
        final readings = {
          SensorKey.soilMoisture: reading(47.5), // 25th %ile → 0.5
          SensorKey.temperature: reading(23), // 1.0
          SensorKey.humidity: reading(65), // 1.0
        };
        final result = GrowthHealthScore.compute(readings, defaultConfig);

        // weightedSum = 0.5×0.5 + 1.0×0.3 + 1.0×0.2 = 0.75
        // score = 75.0
        expect(result.status, HealthStatus.moderate);
        expect(result.score, closeTo(75.0, 0.01));
      });

      test('caution at score 50-64', () {
        // moisture=30 (0), temp=23 (1.0), humidity=65 (1.0) → score=50
        final readings = {
          SensorKey.soilMoisture: reading(30), // below 40 → 0
          SensorKey.temperature: reading(23), // 1.0
          SensorKey.humidity: reading(65), // 1.0
        };
        final result = GrowthHealthScore.compute(readings, defaultConfig);

        expect(result.status, HealthStatus.caution);
        expect(result.score, closeTo(50.0, 0.01));
      });

      test('danger at score 30-49', () {
        // temp=20 scores 0.4, humidity optimal, moisture dead
        final readings = {
          SensorKey.soilMoisture: reading(30), // 0
          SensorKey.temperature: reading(20), // _bellScore(20,18,28)=0.4
          SensorKey.humidity: reading(65), // 1.0
        };
        final result = GrowthHealthScore.compute(readings, defaultConfig);

        // (0×0.5 + 0.4×0.3 + 1.0×0.2) / 1.0 × 100 = 32
        expect(result.status, HealthStatus.danger);
        expect(result.score, closeTo(32.0, 0.01));
      });

      test('critical at score < 30', () {
        final readings = {
          SensorKey.soilMoisture: reading(30), // 0
          SensorKey.temperature: reading(30), // above 28 → 0
          SensorKey.humidity: reading(30), // below 50 → 0
        };
        final result = GrowthHealthScore.compute(readings, defaultConfig);

        expect(result.status, HealthStatus.critical);
        expect(result.score, 0.0);
      });
    });

    group('custom config', () {
      test('uses species-specific thresholds', () {
        // Cactus: very dry soil range
        const cactusConfig = HealthConfig(
          soilMoistureMin: 5,
          soilMoistureMax: 25,
          temperatureMin: 20,
          temperatureMax: 35,
          humidityMin: 20,
          humidityMax: 40,
        );

        final readings = {
          SensorKey.soilMoisture: reading(15), // midpoint for cactus
          SensorKey.temperature: reading(27), // midpoint-ish
          SensorKey.humidity: reading(30), // midpoint
        };

        final result = GrowthHealthScore.compute(readings, cactusConfig);

        expect(result.status, HealthStatus.optimal);
        expect(result.score, greaterThan(95));
      });

      test('detects cactus in wet soil', () {
        const cactusConfig = HealthConfig(
          soilMoistureMin: 5,
          soilMoistureMax: 25,
          temperatureMin: 20,
          temperatureMax: 35,
          humidityMin: 20,
          humidityMax: 40,
        );

        // 55% moisture → way above 25 for cactus
        final readings = {
          SensorKey.soilMoisture: reading(55),
          SensorKey.temperature: reading(27),
          SensorKey.humidity: reading(30),
        };

        final result = GrowthHealthScore.compute(readings, cactusConfig);

        expect(result.componentScores[SensorKey.soilMoisture], 0.0);
      });
    });

    group('HealthScoreResult helpers', () {
      test('isCritical when score < 30', () {
        final result = HealthScoreResult(
          score: 20,
          status: HealthStatus.critical,
          componentScores: {},
          computedAt: now,
        );

        expect(result.isCritical, isTrue);
        expect(result.isDanger, isTrue); // also < 50
        expect(result.isOptimal, isFalse);
      });

      test('isDanger when score < 50 but >= 30', () {
        final result = HealthScoreResult(
          score: 40,
          status: HealthStatus.danger,
          componentScores: {},
          computedAt: now,
        );

        expect(result.isDanger, isTrue);
        expect(result.isCritical, isFalse);
        expect(result.isOptimal, isFalse);
      });

      test('isOptimal when score >= 80', () {
        final result = HealthScoreResult(
          score: 90,
          status: HealthStatus.optimal,
          componentScores: {},
          computedAt: now,
        );

        expect(result.isOptimal, isTrue);
        expect(result.isCritical, isFalse);
        expect(result.isDanger, isFalse);
      });
    });

    group('computedAt timestamp', () {
      test('sets computedAt to approximately now', () {
        final before = DateTime.now();
        final readings = {
          SensorKey.soilMoisture: reading(55),
          SensorKey.temperature: reading(23),
          SensorKey.humidity: reading(65),
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);
        final after = DateTime.now();

        expect(
          result.computedAt.isAfter(
            before.subtract(const Duration(seconds: 1)),
          ),
          isTrue,
        );
        expect(
          result.computedAt.isBefore(after.add(const Duration(seconds: 1))),
          isTrue,
        );
      });
    });

    group('score clamping', () {
      test('clamps score to 0 minimum', () {
        final readings = {
          SensorKey.soilMoisture: reading(10), // 0
          SensorKey.temperature: reading(50), // above 28 → 0
          SensorKey.humidity: reading(5), // below 50 → 0
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);

        expect(result.score, 0.0);
        expect(result.score.isNegative, isFalse);
      });

      test('clamps score to 100 maximum', () {
        final readings = {
          SensorKey.soilMoisture: reading(55),
          SensorKey.temperature: reading(23),
          SensorKey.humidity: reading(65),
        };

        final result = GrowthHealthScore.compute(readings, defaultConfig);

        expect(result.score, lessThanOrEqualTo(100));
      });
    });
  });
}
