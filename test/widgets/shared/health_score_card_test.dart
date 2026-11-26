import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/dashboard/presentation/widgets/health_score_card.dart';
import 'package:lextari/ui/ui.dart';

void main() {
  group('HealthScoreCard', () {
    testWidgets('renders Health Score title', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: HealthScoreCard(
              score: 62,
              statusText: 'Soil is too wet',
              gaugeColor: AppColors.yellowAlert,
            ),
          ),
        ),
      );

      expect(find.text('Health Score'), findsOneWidget);
    });

    testWidgets('renders status text', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: HealthScoreCard(
              score: 62,
              statusText: 'Soil is too wet',
              gaugeColor: AppColors.yellowAlert,
            ),
          ),
        ),
      );

      expect(find.text('Soil is too wet'), findsOneWidget);
    });

    testWidgets('renders warning text when provided', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: HealthScoreCard(
              score: 62,
              statusText: 'Soil is too wet',
              gaugeColor: AppColors.yellowAlert,
              warningText: 'STOP WATERING!',
            ),
          ),
        ),
      );

      expect(find.text('STOP WATERING!'), findsOneWidget);
    });

    testWidgets('hides warning text when null', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: HealthScoreCard(
              score: 85,
              statusText: 'Perfect',
              gaugeColor: AppColors.deepGreen,
            ),
          ),
        ),
      );

      expect(find.text('STOP WATERING!'), findsNothing);
    });

    testWidgets('marks a stale score as last known', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: HealthScoreCard(
              score: 80,
              statusText: 'Last known 41d ago. Health cannot be confirmed.',
              gaugeColor: AppColors.leaf,
              isStale: true,
            ),
          ),
        ),
      );

      expect(find.text('Last known'), findsOneWidget);
      expect(
        find.text('Last known 41d ago. Health cannot be confirmed.'),
        findsOneWidget,
      );
    });

    testWidgets('marks a score without readings as no data', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: HealthScoreCard(
              score: 0,
              statusText:
                  'Waiting for soil, temperature and humidity readings.',
              gaugeColor: AppColors.leaf,
              hasData: false,
            ),
          ),
        ),
      );

      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('renders gauge with score', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: HealthScoreCard(
              score: 62,
              statusText: 'Soil is too wet',
              gaugeColor: AppColors.yellowAlert,
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsAtLeast(1));
    });
  });
}
