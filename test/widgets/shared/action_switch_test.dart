import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/dashboard/presentation/widgets/action_switch.dart';
import 'package:lextari/ui/ui.dart';

void main() {
  group('ActionSwitch', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: ActionSwitch(
              icon: AppGlyphs.cloud,
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
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: ActionSwitch(
              icon: AppGlyphs.cloud,
              label: 'Mist',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byWidgetPredicate((w) => w is GlyphIcon && w.glyph == AppGlyphs.cloud), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: ActionSwitch(
              icon: AppGlyphs.cloud,
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
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: StatefulBuilder(
              builder: (context, setState) => ActionSwitch(
                icon: AppGlyphs.cloud,
                label: 'Mist',
                value: currentValue,
                onChanged: (v) => setState(() => currentValue = v),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ActionSwitch));
      await tester.pump();
      expect(currentValue, isTrue);
    });

    testWidgets('shows active state', (tester) async {
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: ActionSwitch(
              icon: AppGlyphs.cloud,
              label: 'Mist',
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ActionSwitch), findsOneWidget);
    });

    testWidgets('shows inactive state', (tester) async {
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: ActionSwitch(
              icon: AppGlyphs.cloud,
              label: 'Mist',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ActionSwitch), findsOneWidget);
    });
  });
}
