import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lextari/shared/widgets/sensor_error_boundary.dart';

void main() {
  group('SensorErrorBoundary', () {
    testWidgets('renders child widget normally', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorErrorBoundary(
              label: 'Temperature',
              child: Text('28.5 °C'),
            ),
          ),
        ),
      );

      expect(find.text('28.5 °C'), findsOneWidget);
      expect(find.text('Temperature unavailable'), findsNothing);
    });

    testWidgets('renders with any label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorErrorBoundary(
              label: 'Humidity',
              child: Text('65%'),
            ),
          ),
        ),
      );

      expect(find.text('65%'), findsOneWidget);
    });

    testWidgets('custom label is not displayed in normal state', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorErrorBoundary(
              label: 'Soil Moisture',
              child: Text('54%'),
            ),
          ),
        ),
      );

      expect(find.text('Soil Moisture unavailable'), findsNothing);
    });
  });
}
