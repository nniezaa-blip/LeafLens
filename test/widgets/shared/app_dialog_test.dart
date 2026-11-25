import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/notifications/app_dialog.dart';

void main() {
  group('showAppDialog', () {
    testWidgets('shows title and message', (tester) async {
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () => showAppDialog<void>(
                  context: context,
                  title: 'Test Title',
                  message: 'Test message body',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test message body'), findsOneWidget);
    });

    testWidgets('shows OK button by default', (tester) async {
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () => showAppDialog<void>(
                  context: context,
                  title: 'Info',
                  message: 'Details here',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('shows custom confirm label', (tester) async {
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () => showAppDialog<void>(
                  context: context,
                  title: 'Delete?',
                  message: 'Cannot undo',
                  confirmLabel: 'Delete',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('OK'), findsNothing);
    });

    testWidgets('shows cancel when cancelLabel provided', (tester) async {
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () => showAppDialog<void>(
                  context: context,
                  title: 'Confirm',
                  message: 'Are you sure?',
                  confirmLabel: 'Yes',
                  cancelLabel: 'No',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('confirm returns true', (tester) async {
      bool? result;
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  result = await showAppDialog<bool>(
                    context: context,
                    title: 'Confirm',
                    message: 'Proceed?',
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('cancel returns null', (tester) async {
      bool? result;
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  result = await showAppDialog<bool>(
                    context: context,
                    title: 'Confirm',
                    message: 'Proceed?',
                    cancelLabel: 'Cancel',
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () => showAppDialog<void>(
                  context: context,
                  title: 'Warning',
                  message: 'Be careful',
                  icon: const GlyphIcon(AppGlyphs.warning),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) => w is GlyphIcon && w.glyph == AppGlyphs.warning,
        ),
        findsOneWidget,
      );
    });

    testWidgets('barrier not dismissible by default', (tester) async {
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(
            bar: const EmptyBar(),
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () => showAppDialog<void>(
                  context: context,
                  title: 'Modal',
                  message: 'Cannot tap outside',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Modal'), findsOneWidget);
    });
  });
}
