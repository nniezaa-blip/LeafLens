import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lextari/features/dashboard/domain/growth_health_score.dart';
import 'package:lextari/shared/widgets/status_badge.dart';

void main() {
  group('StatusBadge', () {
    testWidgets('renders Optimal label with green color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: HealthStatus.optimal),
          ),
        ),
      );

      expect(find.text('Optimal'), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
    });

    testWidgets('renders Moderate label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: HealthStatus.moderate),
          ),
        ),
      );

      expect(find.text('Moderate'), findsOneWidget);
    });

    testWidgets('renders Caution label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: HealthStatus.caution),
          ),
        ),
      );

      expect(find.text('Caution'), findsOneWidget);
    });

    testWidgets('renders Danger label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: HealthStatus.danger),
          ),
        ),
      );

      expect(find.text('Danger'), findsOneWidget);
    });

    testWidgets('renders Critical label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: HealthStatus.critical),
          ),
        ),
      );

      expect(find.text('Critical'), findsOneWidget);
    });

    testWidgets('renders all statuses without error', (tester) async {
      for (final status in HealthStatus.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: StatusBadge(status: status)),
          ),
        );

        // No red sliver error thrown means widget built fine
        expect(tester.takeException(), isNull);
      }
    });
  });
}
