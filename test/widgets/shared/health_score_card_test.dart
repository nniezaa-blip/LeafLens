import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lextari/features/dashboard/presentation/widgets/health_score_card.dart';

void main() {
  group('HealthScoreCard', () {
    testWidgets('renders Health Score title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthScoreCard(
              score: 62,
              statusText: 'Soil is too wet',
              gaugeColor: Colors.orange,
            ),
          ),
        ),
      );

      expect(find.text('Health Score'), findsOneWidget);
    });

    testWidgets('renders status text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthScoreCard(
              score: 62,
              statusText: 'Soil is too wet',
              gaugeColor: Colors.orange,
            ),
          ),
        ),
      );

      expect(find.text('Soil is too wet'), findsOneWidget);
    });

    testWidgets('renders warning text when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthScoreCard(
              score: 62,
              statusText: 'Soil is too wet',
              gaugeColor: Colors.orange,
              warningText: 'STOP WATERING!',
            ),
          ),
        ),
      );

      expect(find.text('STOP WATERING!'), findsOneWidget);
    });

    testWidgets('hides warning text when null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthScoreCard(
              score: 85,
              statusText: 'Perfect',
              gaugeColor: Colors.green,
            ),
          ),
        ),
      );

      expect(find.text('STOP WATERING!'), findsNothing);
    });

    testWidgets('renders gauge with score', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthScoreCard(
              score: 62,
              statusText: 'Soil is too wet',
              gaugeColor: Colors.orange,
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsAtLeast(1));
    });
  });
}
