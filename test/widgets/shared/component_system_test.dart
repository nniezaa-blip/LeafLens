import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/chip_title.dart';
import 'package:lextari/widgets/last_update_time_text.dart';

void main() {
  group('ChipTitle', () {
    testWidgets('renders title, count and expiry', (tester) async {
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: ChipTitle(
              title: 'Profile',
              chip: '3',
              expire: DateTime(2027, 1, 2),
            ),
          ),
        ),
      );

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2027-01-02'), findsOneWidget);
    });
  });

  group('formatLastUpdate', () {
    test('describes recent updates', () {
      final now = DateTime.now();
      expect(formatLastUpdate(now), 'just now');
      expect(
        formatLastUpdate(now.subtract(const Duration(minutes: 5))),
        '5m ago',
      );
      expect(
        formatLastUpdate(now.subtract(const Duration(hours: 2))),
        '2h ago',
      );
    });
  });

  group('AnimatedAppGlyph', () {
    testWidgets('renders the selected fill', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: AnimatedAppGlyph(
              glyph: AppGlyphs.home,
              selected: true,
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedGlyph), findsOneWidget);
    });
  });

  group('Scaffold', () {
    testWidgets('renders title and body', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: ViewScope(
            size: Size(390, 844),
            isMobile: true,
            child: Scaffold(
              title: 'Settings',
              body: Text('Body'),
            ),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });
  });
}
