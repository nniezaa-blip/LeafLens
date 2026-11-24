import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/auth/data/user_profile_provider.dart';
import 'package:lextari/features/auth/domain/user_profile.dart';
import 'package:lextari/features/dashboard/domain/dashboard_action.dart';
import 'package:lextari/features/dashboard/domain/growth_health_score.dart';
import 'package:lextari/features/dashboard/domain/sensor_key.dart';
import 'package:lextari/features/dashboard/domain/sensor_reading.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_view_model.dart';
import 'package:lextari/features/dashboard/presentation/widgets/action_switch.dart';
import 'package:lextari/ui/ui.dart';

class FakeDashboardViewModel extends DashboardViewModel {
  FakeDashboardViewModel(this.initial);
  final DashboardViewState initial;
  final List<String> rpcCalls = [];

  @override
  DashboardViewState build() => initial;

  @override
  Future<void> sendAction(DashboardAction action) async {
    rpcCalls.add(action.rpcMethod);
  }
}

void main() {
  const testProfile = UserProfile(
    name: 'Aishah Abdul Aziz',
    email: 'aishah.abdulaziz@example.com',
  );

  DashboardViewState testState() {
    final now = DateTime.now();
    return DashboardViewState(
      telemetry: {
        SensorKey.temperature: SensorReading(value: 26, recordedAt: now, unit: '°C'),
        SensorKey.humidity: SensorReading(value: 64, recordedAt: now, unit: '%'),
        SensorKey.soilMoisture: SensorReading(value: 90, recordedAt: now, unit: '%'),
        SensorKey.waterLevel: SensorReading(value: 45, recordedAt: now, unit: '%'),
      },
      healthScore: HealthScoreResult(
        score: 62,
        status: HealthStatus.caution,
        componentScores: const {},
        computedAt: now,
      ),
      statusText: 'Environment is great but the soil is too wet!',
      waterLevelPercent: 45,
    );
  }

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        currentUserProfileProvider.overrideWithValue(testProfile),
        dashboardViewModelProvider.overrideWith(() => FakeDashboardViewModel(testState())),
      ],
      child: const PrismApp(
        home: PrismScaffold(bar: const EmptyBar(), body: DashboardScreen(),
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
      expect(find.byWidgetPredicate((w) => w is GlyphIcon && w.glyph == AppGlyphs.cloud), findsOneWidget);
      // water_drop_outlined appears in Water switch + Humidity sensor card
      expect(find.byWidgetPredicate((w) => w is GlyphIcon && w.glyph == AppGlyphs.waterDrop), findsNWidgets(2));
      expect(find.byWidgetPredicate((w) => w is GlyphIcon && w.glyph == AppGlyphs.autorenew), findsOneWidget);
    });

    testWidgets('renders visible sensor cards', (tester) async {
      await tester.pumpWidget(buildTestApp());

      // Temperature and Humidity fit in viewport; Soil Moisture needs scroll
      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Water Level'), findsNothing);
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
      expect(find.text('Environment is great but the soil is too wet!'), findsOneWidget);
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

    testWidgets('all sensor cards exist', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Soil Moisture'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Soil Moisture'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Water Level'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Water Level'), findsOneWidget);
    });
  });
}
