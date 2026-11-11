import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lextari/core/router/auth_guard.dart';

/// Builds a minimal GoRouterState for testing.
///
/// GoRouterState requires a non-null RouteConfiguration, so we build
/// a real one with a placeholder route. AuthGuard only reads
/// `matchedLocation` from the state — the rest is scaffolding.
GoRouterState _state(String location) {
  final routingConfig = ValueNotifier(
    RoutingConfig(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SizedBox()),
      ],
    ),
  );
  final config = RouteConfiguration(
    routingConfig,
    navigatorKey: GlobalKey<NavigatorState>(),
  );
  return GoRouterState(
    config,
    uri: Uri.parse(location),
    matchedLocation: location,
    fullPath: location,
    pathParameters: const <String, String>{},
    pageKey: const ValueKey('test'),
  );
}

void main() {
  group('AuthGuard', () {
    group('splash', () {
      test('is never redirected when unauthenticated', () {
        final result = AuthGuard.call(
          state: _state('/splash'),
          isLoggedIn: false,
        );
        expect(result, isNull);
      });

      test('is never redirected when authenticated via stream', () {
        final result = AuthGuard.call(
          state: _state('/splash'),
          isLoggedIn: true,
        );
        expect(result, isNull);
      });

      test('is never redirected when authenticated via token', () {
        final result = AuthGuard.call(
          state: _state('/splash'),
          isLoggedIn: false,
          currentToken: 'some-token',
        );
        expect(result, isNull);
      });
    });

    group('public routes (login/signup)', () {
      test('allows unauthenticated access to /login', () {
        final result = AuthGuard.call(
          state: _state('/login'),
          isLoggedIn: false,
        );
        expect(result, isNull);
      });

      test('allows unauthenticated access to /signup', () {
        final result = AuthGuard.call(
          state: _state('/signup'),
          isLoggedIn: false,
        );
        expect(result, isNull);
      });

      test('redirects authenticated user away from /login', () {
        final result = AuthGuard.call(
          state: _state('/login'),
          isLoggedIn: true,
        );
        expect(result, '/dashboard');
      });

      test('redirects authenticated user away from /signup', () {
        final result = AuthGuard.call(
          state: _state('/signup'),
          isLoggedIn: true,
          currentToken: 'token',
        );
        expect(result, '/dashboard');
      });
    });

    group('protected routes', () {
      test('redirects unauthenticated user to /login', () {
        final result = AuthGuard.call(
          state: _state('/dashboard'),
          isLoggedIn: false,
        );
        expect(result, '/login');
      });

      test('allows authenticated user to /dashboard', () {
        final result = AuthGuard.call(
          state: _state('/dashboard'),
          isLoggedIn: true,
        );
        expect(result, isNull);
      });

      test('allows user with token to /dashboard', () {
        final result = AuthGuard.call(
          state: _state('/dashboard'),
          isLoggedIn: false,
          currentToken: 'token',
        );
        expect(result, isNull);
      });
    });

    group('unknown routes', () {
      test('redirects unauthenticated user to /login', () {
        final result = AuthGuard.call(
          state: _state('/settings'),
          isLoggedIn: false,
        );
        expect(result, '/login');
      });

      test('allows authenticated user to unknown route', () {
        final result = AuthGuard.call(
          state: _state('/settings'),
          isLoggedIn: true,
        );
        expect(result, isNull);
      });
    });
  });
}
