import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lextari/features/dashboard/presentation/widgets/sensor_card.dart';

void _noop() {}

void main() {
  group('SensorCard', () {
    testWidgets('renders sensor name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorCard(
              sensorName: 'Temperature',
              value: 26,
              unit: '°C',
              unitIcon: Icons.thermostat,
              statusText: 'Temperature is normal',
              gaugeColor: Colors.green,
              onMoreTap: _noop,
            ),
          ),
        ),
      );

      expect(find.text('Temperature'), findsOneWidget);
    });

    testWidgets('renders unit text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorCard(
              sensorName: 'Temperature',
              value: 26,
              unit: '°C',
              unitIcon: Icons.thermostat,
              statusText: 'Temperature is normal',
              gaugeColor: Colors.green,
              onMoreTap: _noop,
            ),
          ),
        ),
      );

      expect(find.text('°C'), findsOneWidget);
    });

    testWidgets('renders status text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorCard(
              sensorName: 'Temperature',
              value: 26,
              unit: '°C',
              unitIcon: Icons.thermostat,
              statusText: 'Temperature is normal',
              gaugeColor: Colors.green,
              onMoreTap: _noop,
            ),
          ),
        ),
      );

      expect(find.text('Temperature is normal'), findsOneWidget);
    });

    testWidgets('renders More link', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorCard(
              sensorName: 'Temperature',
              value: 26,
              unit: '°C',
              unitIcon: Icons.thermostat,
              statusText: 'Temperature is normal',
              gaugeColor: Colors.green,
              onMoreTap: _noop,
            ),
          ),
        ),
      );

      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('does not overflow on standard phone width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: SensorCard(
                sensorName: 'Soil Moisture',
                value: 90,
                unit: '%',
                unitIcon: Icons.water_drop,
                statusText: 'Saturated',
                gaugeColor: Colors.red,
                onMoreTap: _noop,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders gauge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorCard(
              sensorName: 'Humidity',
              value: 64,
              unit: '%',
              unitIcon: Icons.water_drop_outlined,
              statusText: 'Perfect Environment',
              gaugeColor: Colors.green,
              onMoreTap: _noop,
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsAtLeast(1));
    });

    testWidgets('hides More link when onMoreTap is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorCard(
              sensorName: 'Water Level',
              value: 45,
              unit: 'cm',
              unitIcon: Icons.waves,
              statusText: 'Water level is low',
              gaugeColor: Colors.orange,
            ),
          ),
        ),
      );

      expect(find.text('More'), findsNothing);
    });

    testWidgets('invokes onMoreTap when More is tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SensorCard(
              sensorName: 'Temperature',
              value: 26,
              unit: '°C',
              unitIcon: Icons.thermostat,
              statusText: 'Temperature is normal',
              gaugeColor: Colors.green,
              onMoreTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('More'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
