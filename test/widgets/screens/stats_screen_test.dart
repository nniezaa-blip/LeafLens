import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/dashboard/domain/telemetry_history_point.dart';
import 'package:lextari/features/dashboard/providers/telemetry_providers.dart';
import 'package:lextari/features/stats/presentation/stats_screen.dart';
import 'package:lextari/ui/ui.dart';

void main() {
  List<TelemetryHistoryPoint> testPoints() {
    return [
      for (var index = 0; index < 10; index++)
        TelemetryHistoryPoint(
          timestamp: DateTime(2026, 1, index + 1),
          value: 22 + (index % 3),
        ),
    ];
  }

  Widget buildTestApp({List<TelemetryHistoryPoint>? points}) {
    return ProviderScope(
      overrides: [
        if (points != null)
          telemetryHistoryProvider.overrideWith(
            (ref, key) async => points,
          ),
      ],
      child: const PrismApp(
        home: PrismScaffold(
          bar: EmptyBar(),
          body: StatsScreen(),
        ),
      ),
    );
  }

  group('StatsScreen', () {
    testWidgets('renders the 30-day trends header', (tester) async {
      await tester.pumpWidget(buildTestApp(points: testPoints()));
      await tester.pump();

      expect(find.text('30-Day Trends'), findsOneWidget);
      expect(
        find.text('Average readings across the last month'),
        findsOneWidget,
      );
    });

    testWidgets('renders all segmented switcher options', (tester) async {
      await tester.pumpWidget(buildTestApp(points: testPoints()));
      await tester.pump();

      // Temperature appears in both the switcher and the chart header.
      expect(find.text('Temperature'), findsNWidgets(2));
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Moisture'), findsOneWidget);
    });

    testWidgets('defaults to the temperature chart', (tester) async {
      await tester.pumpWidget(buildTestApp(points: testPoints()));
      await tester.pump();

      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text('Temperature (°C)'), findsOneWidget);
    });

    testWidgets('switches to the humidity chart when tapped', (tester) async {
      await tester.pumpWidget(buildTestApp(points: testPoints()));
      await tester.pump();

      await tester.tap(find.text('Humidity'));
      await tester.pumpAndSettle();

      expect(find.text('Relative Humidity (RH %)'), findsOneWidget);
      expect(find.text('Temperature (°C)'), findsNothing);
    });

    testWidgets('switches to the moisture chart when tapped', (tester) async {
      await tester.pumpWidget(buildTestApp(points: testPoints()));
      await tester.pump();

      await tester.tap(find.text('Moisture'));
      await tester.pumpAndSettle();

      expect(find.text('Moisture (%)'), findsOneWidget);
    });

    testWidgets('shows an empty state when there is no history', (tester) async {
      await tester.pumpWidget(buildTestApp(points: const []));
      await tester.pump();

      expect(find.text('No telemetry yet'), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('chart is zoomed in for horizontal panning', (tester) async {
      await tester.pumpWidget(buildTestApp(points: testPoints()));
      await tester.pump();

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final config = chart.transformationConfig;
      final controller = config.transformationController!;

      expect(config.scaleAxis, FlScaleAxis.horizontal);
      expect(config.panEnabled, isTrue);
      expect(config.scaleEnabled, isFalse);
      expect(controller.value.getMaxScaleOnAxis(), greaterThan(1));
    });

    testWidgets('dragging horizontally pans the chart', (tester) async {
      await tester.pumpWidget(buildTestApp(points: testPoints()));
      await tester.pump();

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final controller = chart.transformationConfig.transformationController!;
      final beforeTx = controller.value.getTranslation().x;

      await tester.drag(find.byType(LineChart), const Offset(-120, 0));
      await tester.pumpAndSettle();

      expect(controller.value.getTranslation().x, isNot(beforeTx));
    });

    testWidgets('switching metric resets the chart zoom', (tester) async {
      await tester.pumpWidget(buildTestApp(points: testPoints()));
      await tester.pump();

      await tester.drag(find.byType(LineChart), const Offset(-120, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Humidity'));
      await tester.pumpAndSettle();

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final controller = chart.transformationConfig.transformationController!;

      expect(controller.value.getTranslation().x, 0);
      expect(controller.value.getMaxScaleOnAxis(), greaterThan(1));
    });
  });
}
