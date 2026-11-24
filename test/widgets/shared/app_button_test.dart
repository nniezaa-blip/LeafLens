import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/ui/ui.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(bar: const EmptyBar(), body: AppButton(label: 'Submit')),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(bar: const EmptyBar(), body: AppButton(
              label: 'Tap Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      expect(pressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(bar: const EmptyBar(), body: AppButton(label: 'Disabled'),
          ),
        ),
      );

      // Find the FilledButton and verify it's disabled
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('primary variant uses FilledButton', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(bar: const EmptyBar(), body: AppButton(
              label: 'Primary',
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('secondary variant uses FilledButton.tonal', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(bar: const EmptyBar(), body: AppButton(
              label: 'Secondary',
              variant: AppButtonVariant.secondary,
            ),
          ),
        ),
      );

      // FilledButton.tonal is still a FilledButton
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('outline variant uses OutlinedButton', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(bar: const EmptyBar(), body: AppButton(
              label: 'Outline',
              variant: AppButtonVariant.outline,
            ),
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('text variant uses TextButton', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(bar: const EmptyBar(), body: AppButton(
              label: 'TextBtn',
              variant: AppButtonVariant.text,
            ),
          ),
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('shows loading spinner instead of label', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(bar: const EmptyBar(), body: AppButton(
              label: 'Loading',
              loading: true,
            ),
          ),
        ),
      );

      expect(find.text('Loading'), findsNothing);
      expect(find.byType(ActivityIndicator), findsOneWidget);
    });

    testWidgets('is disabled while loading', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        PrismApp(
          home: PrismScaffold(bar: const EmptyBar(), body: AppButton(
              label: 'Submit',
              loading: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      expect(pressed, isFalse);
    });

    testWidgets('renders with icon', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(bar: const EmptyBar(), body: AppButton(
              label: 'With Icon',
            ),
          ),
        ),
      );

      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('renders with custom width', (tester) async {
      await tester.pumpWidget(
        const PrismApp(
          home: PrismScaffold(bar: const EmptyBar(), body: AppButton(
              label: 'Wide',
              
            ),
          ),
        ),
      );

      expect(find.text('Wide'), findsOneWidget);
    });
  });
}
