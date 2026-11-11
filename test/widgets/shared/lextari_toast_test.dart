import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/shared/notifications/lextari_toast.dart';
import 'package:toastification/toastification.dart';

void main() {
  group('LextariToast', () {
    LextariToast buildToast({
      String title = 'Test Title',
      String? description,
      ToastificationType type = ToastificationType.info,
    }) {
      // Don't pass autoCloseDuration — it starts a PausableTimer
      // that causes "!timersPending" assertion failures in tests.
      final holder = ToastificationItem(
        builder: (context, holder) => const SizedBox(),
        alignment: Alignment.topCenter,
      );
      return LextariToast(
        holder: holder,
        title: title,
        description: description,
        type: type,
      );
    }

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: buildToast(title: 'Success!')),
        ),
      );
      expect(find.text('Success!'), findsOneWidget);
    });

    testWidgets('renders description when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildToast(
              title: 'Error',
              description: 'Something went wrong',
            ),
          ),
        ),
      );
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('hides description when null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: buildToast(title: 'Info')),
        ),
      );
      expect(find.text('Info'), findsOneWidget);
      // No second text widget (description)
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('shows close button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: buildToast()),
        ),
      );
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('error type shows error icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildToast(type: ToastificationType.error),
          ),
        ),
      );
      expect(find.byIcon(Icons.error_rounded), findsOneWidget);
    });

    testWidgets('success type shows check icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildToast(type: ToastificationType.success),
          ),
        ),
      );
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('warning type shows warning icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildToast(type: ToastificationType.warning),
          ),
        ),
      );
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets('info type shows info icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildToast(),
          ),
        ),
      );
      expect(find.byIcon(Icons.info_rounded), findsOneWidget);
    });
  });
}
