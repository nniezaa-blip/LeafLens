import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/auth/data/auth_session_manager.dart';
import 'package:lextari/features/auth/domain/auth_session.dart';
import 'package:lextari/features/auth/presentation/signup_page.dart';

import '../../helpers/test_asset_bundle.dart';

Widget buildTestApp() {
  return ProviderScope(
    overrides: [
      authSessionProvider.overrideWith(
        (ref) => Stream<AuthSession?>.value(null),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: DefaultAssetBundle(
          bundle: TestAssetBundle(),
          child: const SignUpPage(),
        ),
      ),
    ),
  );
}

void main() {
  group('SignUpPage', () {
    testWidgets('renders sign up title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('renders all form fields', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders sign up button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('renders login link', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('Login'), findsOneWidget);
      expect(find.textContaining('Already have an account?'), findsOneWidget);
    });

    testWidgets('renders terms checkbox', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('renders or divider', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.textContaining('Or continue with'), findsOneWidget);
    });

    testWidgets('accepts name input', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'Danial');
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
