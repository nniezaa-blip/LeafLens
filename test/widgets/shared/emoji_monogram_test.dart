import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/ui/ui.dart';

void main() {
  group('EmojiMonogram', () {
    testWidgets('renders an emoji mark', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: EmojiMonogram('🌱 Plant'),
          ),
        ),
      );

      expect(find.byType(EmojiText), findsOneWidget);
    });

    testWidgets('falls back to the first letter', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: EmojiMonogram('Lextari'),
          ),
        ),
      );

      expect(find.text('L'), findsOneWidget);
    });
  });
}
