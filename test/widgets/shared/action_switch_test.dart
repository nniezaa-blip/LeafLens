import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lextari/features/dashboard/presentation/widgets/action_switch.dart';

void main() {
  group('ActionSwitch', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionSwitch(
              icon: Icons.cloud_outlined,
              label: 'Mist',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Mist'), findsOneWidget);
    });

    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionSwitch(
              icon: Icons.cloud_outlined,
              label: 'Mist',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionSwitch(
              icon: Icons.cloud_outlined,
              label: 'Mist',
              value: false,
              onChanged: (_) => called = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ActionSwitch));
      expect(called, isTrue);
    });

    testWidgets('toggles value on tap', (tester) async {
      var currentValue = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => ActionSwitch(
                icon: Icons.water_drop_outlined,
                label: 'Water',
                value: currentValue,
                onChanged: (v) => setState(() => currentValue = v),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ActionSwitch));
      await tester.pumpAndSettle();
      expect(currentValue, isTrue);

      await tester.tap(find.byType(ActionSwitch));
      await tester.pumpAndSettle();
      expect(currentValue, isFalse);
    });

    testWidgets('toggle knob aligns right when on', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionSwitch(
              icon: Icons.cloud_outlined,
              label: 'Mist',
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final align = tester.widget<AnimatedAlign>(
        find.byType(AnimatedAlign),
      );
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('toggle knob aligns left when off', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionSwitch(
              icon: Icons.cloud_outlined,
              label: 'Mist',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final align = tester.widget<AnimatedAlign>(
        find.byType(AnimatedAlign),
      );
      expect(align.alignment, Alignment.centerLeft);
    });
  });
}
