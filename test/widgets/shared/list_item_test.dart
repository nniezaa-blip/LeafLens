import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/ui/ui.dart';

void main() {
  group('ListItem', () {
    testWidgets('plain row calls onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: ListItem<void>(
              title: const Text('Plain row'),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Plain row'));
      expect(tapped, isTrue);
    });

    testWidgets('toggle row calls onChanged', (tester) async {
      var value = false;
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: ListItem<void>.toggle(
              title: const Text('Pause notifications'),
              value: value,
              onChanged: (next) => value = next,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      expect(value, isTrue);
    });

    testWidgets('checkbox row calls onChanged', (tester) async {
      var value = false;
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: ListItem<void>.checkbox(
              title: const Text('Select'),
              value: value,
              onChanged: (next) => value = next ?? false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      expect(value, isTrue);
    });
  });
}
