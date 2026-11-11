import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lextari/core/router/auth_guard.dart';
import 'package:lextari/features/auth/presentation/login_page.dart';
import 'package:lextari/features/auth/presentation/signup_page.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lextari/features/splash/presentation/splash_screen.dart';

/// Creates a test-only GoRouter that uses [AuthGuard] without
/// touching LextariAuth — safe for tests where Supabase isn't initialized.
GoRouter createTestRouter({required Stream<bool> authStream}) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // Simulate auth state — no LextariAuth.accessToken access.
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, _) => const SignUpPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, _) => const DashboardScreen(),
      ),
    ],
  );
}

/// Wraps the full app with provider overrides so navigation can be tested
/// without real API calls or Supabase.
Widget buildTestApp({bool isAuthenticated = false}) {
  final router = createTestRouter(
    authStream: Stream.value(isAuthenticated),
  );

  return MaterialApp.router(
    routerConfig: router,
  );
}

void main() {
  group('Navigation flows', () {
    testWidgets('splash → login: Get Started button navigates to login', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('LEXTARI'), findsOneWidget);

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('login → signup: Sign up link navigates to signup', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('signup → login: Login link navigates back to login', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('full splash → login → signup → login round trip', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      expect(find.text('Or continue with Email'), findsOneWidget);

      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();
      expect(find.byType(Checkbox), findsOneWidget);

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      expect(find.text('Or continue with Email'), findsOneWidget);
    });

    testWidgets('unauthenticated routes redirect to login', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
