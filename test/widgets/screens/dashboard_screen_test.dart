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
import 'package:lextari/widgets/user_avatar.dart';

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
        SensorKey.temperature: SensorReading(
          value: 26,
          recordedAt: now,
          unit: '°C',
        ),
        SensorKey.humidity: SensorReading(
          value: 64,
          recordedAt: now,
          unit: '%',
        ),
        SensorKey.soilMoisture: SensorReading(
          value: 90,
          recordedAt: now,
          unit: '%',
        ),
        SensorKey.waterLevel: SensorReading(
          value: 45,
          recordedAt: now,
          unit: '%',
        ),
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
        dashboardViewModelProvider.overrideWith(
          () => FakeDashboardViewModel(testState()),
        ),
      ],
      child: const PrismApp(
        home: PrismScaffold(
          bar: EmptyBar(),
          body: DashboardScreen(),
        ),
      ),
    );
  }

  group('DashboardScreen', () {
    testWidgets('renders the page title and profile avatar', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byType(UserAvatar), findsOneWidget);
    });

    testWidgets('renders avatar', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('renders all three action switches', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(
        find.byWidgetPredicate(
          (w) => w is ActionSwitch && w.label == 'Mist',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is ActionSwitch && w.label == 'Water',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is ActionSwitch && w.label == 'Refill',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders all four sensor tiles', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Soil Moisture'), findsOneWidget);
      expect(find.text('Water Level'), findsOneWidget);
    });

    testWidgets('renders sensor values with units', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('26 °C'), findsOneWidget);
      expect(find.text('64 %'), findsOneWidget);
      expect(find.text('90 %'), findsOneWidget);
      expect(find.text('45%'), findsOneWidget);
    });

    testWidgets('renders health score card', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('Health Score'), findsOneWidget);
      expect(
        find.text('Environment is great but the soil is too wet!'),
        findsOneWidget,
      );
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

    testWidgets('confirming refill turns the refill control on', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());

      final refillSwitch = find.byWidgetPredicate(
        (w) => w is ActionSwitch && w.label == 'Refill',
      );
      expect(refillSwitch, findsOneWidget);

      await tester.tap(refillSwitch);
      await tester.pumpAndSettle();
      expect(find.text('Refill water tank?'), findsOneWidget);

      await tester.tap(find.text('Start refill'));
      await tester.pumpAndSettle();

      final widget = tester.widget<ActionSwitch>(refillSwitch);
      expect(widget.value, isTrue);
    });

    testWidgets('all sensor tiles exist', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Soil Moisture'), findsOneWidget);
      expect(find.text('Water Level'), findsOneWidget);
    });
  });
}
