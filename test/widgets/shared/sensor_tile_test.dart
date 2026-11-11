import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lextari/features/dashboard/domain/sensor_key.dart';
import 'package:lextari/features/dashboard/domain/sensor_reading.dart';
import 'package:lextari/shared/widgets/sensor_tile.dart';

void main() {
  group('SensorTile', () {
    final now = DateTime.now();

    SensorReading reading({
      double value = 28.5,
      String unit = '°C',
      Duration age = const Duration(minutes: 2),
    }) {
      return SensorReading(
        value: value,
        recordedAt: now.subtract(age),
        unit: unit,
      );
    }

    testWidgets('renders sensor name and value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SensorTile(
              sensor: SensorKey.temperature,
              reading: reading(),
            ),
          ),
        ),
      );

      expect(find.text('temperature'), findsOneWidget);
      expect(find.textContaining('28.5'), findsOneWidget);
      expect(find.textContaining('°C'), findsOneWidget);
    });

    testWidgets('renders humidity value with % symbol', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SensorTile(
              sensor: SensorKey.humidity,
              reading: reading(value: 65, unit: '%'),
            ),
          ),
        ),
      );

      expect(find.textContaining('65.0'), findsOneWidget);
      expect(find.textContaining('%'), findsOneWidget);
    });

    testWidgets('shows skeleton when reading is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorTile(sensor: SensorKey.temperature),
          ),
        ),
      );

      // Skeleton shows placeholder containers, not real text
      expect(find.text('temperature'), findsNothing);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('shows stale warning for old readings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SensorTile(
              sensor: SensorKey.soilMoisture,
              reading: reading(
                value: 55,
                unit: '%',
                age: const Duration(hours: 2),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('shows age label for recent readings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SensorTile(
              sensor: SensorKey.soilMoisture,
              reading: reading(
                value: 55,
                unit: '%',
                age: const Duration(minutes: 5),
              ),
            ),
          ),
        ),
      );

      // "just now" for < 1 min, "5m ago" for 5 min
      expect(find.textContaining('m ago'), findsOneWidget);
    });

    testWidgets('renders water level sensor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SensorTile(
              sensor: SensorKey.waterLevel,
              reading: reading(value: 80, unit: '%'),
            ),
          ),
        ),
      );

      expect(find.text('waterLevel'), findsOneWidget);
    });
  });
}
