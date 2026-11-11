import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/auth/presentation/login_page.dart';
import 'package:lextari/features/dashboard/data/dashboard_providers.dart';

import '../../helpers/test_asset_bundle.dart';

Widget buildTestApp() {
  return ProviderScope(
    overrides: [
      authStateProvider.overrideWith((ref) => Stream<String?>.value(null)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: DefaultAssetBundle(
          bundle: TestAssetBundle(),
          child: const LoginPage(),
        ),
      ),
    ),
  );
}

void main() {
  group('LoginPage', () {
    testWidgets('renders login title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('Login'), findsAtLeast(1));
    });

    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders login button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('Login'), findsAtLeast(1));
      expect(find.byType(FilledButton), findsAtLeast(1));
    });

    testWidgets('renders sign up link', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('Sign up'), findsOneWidget);
      expect(find.textContaining("Don't have an account?"), findsOneWidget);
    });

    testWidgets('accepts email input', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'user@test.com');
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('accepts password input', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      final passwordFields = find.byType(TextFormField);
      await tester.enterText(passwordFields.last, 'secret123');
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('or continue divider is visible', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('Or continue with Email'), findsOneWidget);
    });
  });
}
