import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/stats/presentation/stats_screen.dart';

void main() {
  Widget buildTestApp() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: StatsScreen(),
        ),
      ),
    );
  }

  group('StatsScreen', () {
    testWidgets('renders the 30-day trends header', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('30-Day Trends'), findsOneWidget);
      expect(
        find.text('Average readings across the last month'),
        findsOneWidget,
      );
    });

    testWidgets('renders all segmented switcher options', (tester) async {
      await tester.pumpWidget(buildTestApp());

      // Temperature appears in both the switcher and the chart header.
      expect(find.text('Temperature'), findsNWidgets(2));
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Moisture'), findsOneWidget);
    });

    testWidgets('defaults to the temperature chart', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text('Temperature (°C)'), findsOneWidget);
    });

    testWidgets('switches to the humidity chart when tapped', (tester) async {
      await tester.pumpWidget(buildTestApp());

      await tester.tap(find.text('Humidity'));
      await tester.pumpAndSettle();

      expect(find.text('Relative Humidity (RH %)'), findsOneWidget);
      expect(find.text('Temperature (°C)'), findsNothing);
    });

    testWidgets('switches to the moisture chart when tapped', (tester) async {
      await tester.pumpWidget(buildTestApp());

      await tester.tap(find.text('Moisture'));
      await tester.pumpAndSettle();

      expect(find.text('Moisture (%)'), findsOneWidget);
    });

    testWidgets('chart is zoomed in for horizontal panning', (tester) async {
      await tester.pumpWidget(buildTestApp());

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final config = chart.transformationConfig;
      final controller = config.transformationController!;

      expect(config.scaleAxis, FlScaleAxis.horizontal);
      expect(config.panEnabled, isTrue);
      expect(config.scaleEnabled, isFalse);
      expect(controller.value.getMaxScaleOnAxis(), greaterThan(1));
    });

    testWidgets('dragging horizontally pans the chart', (tester) async {
      await tester.pumpWidget(buildTestApp());

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final controller = chart.transformationConfig.transformationController!;
      final beforeTx = controller.value.getTranslation().x;

      await tester.drag(find.byType(LineChart), const Offset(-120, 0));
      await tester.pumpAndSettle();

      expect(controller.value.getTranslation().x, isNot(beforeTx));
    });

    testWidgets('switching metric resets the chart zoom', (tester) async {
      await tester.pumpWidget(buildTestApp());

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
