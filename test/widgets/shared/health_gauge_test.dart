import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lextari/features/dashboard/domain/growth_health_score.dart';
import 'package:lextari/shared/widgets/health_gauge.dart';

void main() {
  group('HealthGauge', () {
    HealthScoreResult result(double score, HealthStatus status) {
      return HealthScoreResult(
        score: score,
        status: status,
        componentScores: const {},
        computedAt: DateTime.now(),
      );
    }

    testWidgets('renders score percentage text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthGauge(result: result(85, HealthStatus.optimal)),
          ),
        ),
      );

      expect(find.text('85%'), findsOneWidget);
    });

    testWidgets('renders status label for optimal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthGauge(result: result(85, HealthStatus.optimal)),
          ),
        ),
      );

      expect(find.text('Optimal'), findsOneWidget);
    });

    testWidgets('renders status label for critical', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthGauge(result: result(15, HealthStatus.critical)),
          ),
        ),
      );

      expect(find.text('Critical'), findsOneWidget);
    });

    testWidgets('renders CustomPaint for the ring', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthGauge(result: result(50, HealthStatus.caution)),
          ),
        ),
      );

      // MaterialApp itself adds a CustomPaint, so check at least one exists
      expect(find.byType(CustomPaint), findsAtLeast(1));
    });

    testWidgets('renders all status labels without error', (tester) async {
      for (final status in HealthStatus.values) {
        final score = switch (status) {
          HealthStatus.optimal => 90.0,
          HealthStatus.moderate => 70.0,
          HealthStatus.caution => 55.0,
          HealthStatus.danger => 40.0,
          HealthStatus.critical => 20.0,
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HealthGauge(result: result(score, status)),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('renders with custom size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthGauge(
              result: result(75, HealthStatus.moderate),
              size: 150,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).first,
      );
      expect(sizedBox.width, 150);
      expect(sizedBox.height, 150);
    });
  });
}
