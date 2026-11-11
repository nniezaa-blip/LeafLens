import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lextari/features/dashboard/presentation/widgets/mini_gauge.dart';

void main() {
  group('MiniGauge', () {
    testWidgets('renders percentage text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniGauge(value: 0.62, color: Colors.green),
          ),
        ),
      );

      expect(find.text('62%'), findsOneWidget);
    });

    testWidgets('renders 0% for zero value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniGauge(value: 0, color: Colors.green),
          ),
        ),
      );

      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('renders 100% for full value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniGauge(value: 1, color: Colors.red),
          ),
        ),
      );

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('uses custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniGauge(value: 0.5, color: Colors.blue, size: 100),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).first,
      );
      expect(sizedBox.width, 100);
      expect(sizedBox.height, 100);
    });

    testWidgets('contains CustomPaint for arc', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniGauge(value: 0.75, color: Colors.orange),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsAtLeast(1));
    });

    testWidgets('clamps value above 1.0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniGauge(value: 1.5, color: Colors.green),
          ),
        ),
      );

      // Should display 100% after clamping
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('clamps negative value to 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniGauge(value: -0.3, color: Colors.green),
          ),
        ),
      );

      expect(find.text('0%'), findsOneWidget);
    });
  });
}
