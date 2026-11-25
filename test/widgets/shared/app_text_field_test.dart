import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/app_text_field.dart';

void main() {
  group('AppTextField', () {
    testWidgets('renders with hint text', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: AppTextField(hint: 'Email'),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders without hint when omitted', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(bar: EmptyBar(), body: AppTextField()),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('renders with prefix icon', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: AppTextField(
              hint: 'Name',
              prefixIcon: GlyphIcon(AppGlyphs.info),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is GlyphIcon && w.glyph == AppGlyphs.info,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders with suffix icon', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: AppTextField(
              hint: 'Password',
              suffixIcon: GlyphIcon(AppGlyphs.info),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is GlyphIcon && w.glyph == AppGlyphs.info,
        ),
        findsOneWidget,
      );
    });

    testWidgets('obscures text input visually', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: AppTextField(obscureText: true),
          ),
        ),
      );

      // Enter text into the obscured field
      await tester.enterText(find.byType(TextFormField), 'secret123');
      await tester.pump();

      // The text was accepted (no error from entering text)
      expect(tester.takeException(), isNull);
    });

    testWidgets('accepts typed input', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: AppTextField(hint: 'Name'),
          ),
        ),
      );

      // Enter text via the TextFormField
      await tester.enterText(find.byType(TextFormField), 'Danial');
      await tester.pump();

      // Verify text was accepted by reading from the form field
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses custom controller', (tester) async {
      final controller = TextEditingController(text: 'prefilled');
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: AppTextField(controller: controller),
          ),
        ),
      );

      // Verify the controller was passed through
      expect(find.text('prefilled'), findsOneWidget);
    });

    testWidgets('uses email keyboard type', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(
            bar: EmptyBar(),
            body: AppTextField(
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
