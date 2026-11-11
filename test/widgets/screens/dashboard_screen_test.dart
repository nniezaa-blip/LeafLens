import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/auth/data/user_profile_provider.dart';
import 'package:lextari/features/auth/domain/user_profile.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lextari/features/dashboard/presentation/widgets/action_switch.dart';

void main() {
  const testProfile = UserProfile(
    name: 'Aishah Abdul Aziz',
    email: 'aishah.abdulaziz@example.com',
  );

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        currentUserProfileProvider.overrideWithValue(testProfile),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: DashboardScreen(),
        ),
      ),
    );
  }

  group('DashboardScreen', () {
    testWidgets('renders greeting header', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('Aishah Abdul Aziz'), findsOneWidget);

      final greetings = [
        'Good Morning',
        'Good Afternoon',
        'Good Evening',
        'Good Night',
      ];
      final foundGreeting = greetings.any(
        (g) => find.text(g).evaluate().isNotEmpty,
      );
      expect(foundGreeting, isTrue);
    });

    testWidgets('renders avatar', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('renders all three action switches', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('Mist'), findsOneWidget);
      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Refill'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
      // water_drop_outlined appears in Water switch + Humidity sensor card
      expect(find.byIcon(Icons.water_drop_outlined), findsNWidgets(2));
      expect(find.byIcon(Icons.autorenew), findsOneWidget);
    });

    testWidgets('renders visible sensor cards', (tester) async {
      await tester.pumpWidget(buildTestApp());

      // Temperature and Humidity fit in viewport; Soil Moisture needs scroll
      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
    });

    testWidgets('scrolls to reveal soil moisture card', (tester) async {
      await tester.pumpWidget(buildTestApp());

      // Soil Moisture is below the fold — scroll it into view
      final soilCard = find.text('Soil Moisture');
      await tester.scrollUntilVisible(
        soilCard,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(soilCard, findsOneWidget);
    });

    testWidgets('renders sensor gauge percentages', (tester) async {
      await tester.pumpWidget(buildTestApp());

      // MiniGauge renders value as XX% — first two cards visible
      expect(find.text('26%'), findsOneWidget);
      expect(find.text('64%'), findsOneWidget);

      // 90% is on the Soil Moisture card — scroll to it
      final gauge90 = find.text('90%');
      await tester.scrollUntilVisible(
        gauge90,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(gauge90, findsOneWidget);
    });

    testWidgets('renders health score card', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('Health Score'), findsOneWidget);
      expect(find.text('STOP WATERING!'), findsOneWidget);
    });

    testWidgets('toggles mist switch', (tester) async {
      await tester.pumpWidget(buildTestApp());

      final mistSwitch = find.byWidgetPredicate(
        (w) => w is ActionSwitch && w.label == 'Mist',
      );
      expect(mistSwitch, findsOneWidget);

      var widget = tester.widget<ActionSwitch>(mistSwitch);
      expect(widget.value, isFalse);

      await tester.tap(mistSwitch);
      await tester.pumpAndSettle();

      widget = tester.widget<ActionSwitch>(mistSwitch);
      expect(widget.value, isTrue);
    });

    testWidgets('toggles water switch', (tester) async {
      await tester.pumpWidget(buildTestApp());

      final waterSwitch = find.byWidgetPredicate(
        (w) => w is ActionSwitch && w.label == 'Water',
      );
      expect(waterSwitch, findsOneWidget);

      var widget = tester.widget<ActionSwitch>(waterSwitch);
      expect(widget.value, isFalse);

      await tester.tap(waterSwitch);
      await tester.pumpAndSettle();

      widget = tester.widget<ActionSwitch>(waterSwitch);
      expect(widget.value, isTrue);
    });

    testWidgets('toggles refill switch', (tester) async {
      await tester.pumpWidget(buildTestApp());

      final refillSwitch = find.byWidgetPredicate(
        (w) => w is ActionSwitch && w.label == 'Refill',
      );
      expect(refillSwitch, findsOneWidget);

      var widget = tester.widget<ActionSwitch>(refillSwitch);
      expect(widget.value, isFalse);

      await tester.tap(refillSwitch);
      await tester.pumpAndSettle();

      widget = tester.widget<ActionSwitch>(refillSwitch);
      expect(widget.value, isTrue);
    });

    testWidgets('all three sensor cards exist', (tester) async {
      await tester.pumpWidget(buildTestApp());

      // First two are visible without scroll
      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);

      // Scroll to reveal Soil Moisture
      await tester.scrollUntilVisible(
        find.text('Soil Moisture'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Soil Moisture'), findsOneWidget);
    });
  });
}
