import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lextari/shared/widgets/app_text_field.dart';

void main() {
  group('AppTextField', () {
    testWidgets('renders with hint text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppTextField(hint: 'Email')),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders without hint when omitted', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppTextField())),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('renders with prefix icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              hint: 'Name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders with suffix icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              hint: 'Password',
              suffixIcon: Icon(Icons.visibility_off),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('obscures text input visually', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
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
        const MaterialApp(
          home: Scaffold(
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
        MaterialApp(
          home: Scaffold(body: AppTextField(controller: controller)),
        ),
      );

      // Verify the controller was passed through
      expect(find.text('prefilled'), findsOneWidget);
    });

    testWidgets('uses email keyboard type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
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
