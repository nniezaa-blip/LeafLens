import 'package:go_router/go_router.dart';

/// Centralised route guard for authentication-based navigation.
///
/// Translates auth state into redirect decisions. GoRouter calls [call]
/// on every navigation — guards don't know about GoRouter internals.
///
/// Handles two auth sources:
/// - `isLoggedIn` — reactive stream state from authStateProvider.
/// - `currentToken` — synchronous, available immediately on cold start
///   (Supabase restores session from secure storage before the
///   stream emits).
/// The `||` ensures cold start works even before the stream emits.
/// This is a pure function — no direct service access — so it's
/// fully testable without mocking Supabase.
class AuthGuard {
  const AuthGuard._();

  /// Returns the redirect path, or `null` if no redirect is needed.
  static String? call({
    required GoRouterState state,
    required bool isLoggedIn,
    String? currentToken,
  }) {
    final path = state.matchedLocation;
    final authenticated = isLoggedIn || currentToken != null;

    // Splash is the first screen on launch — leave it alone so it can
    // display; the screen itself routes onward once its timer elapses
    // (to /login, which this guard then resolves for signed-in users).
    if (path == '/splash') return null;

    final isPublic = path == '/login' || path == '/signup';

    // Unauthenticated users can only access public routes.
    if (!authenticated && !isPublic) return '/login';

    // Authenticated users shouldn't linger on auth screens.
    if (authenticated && isPublic) return '/dashboard';

    return null;
  }
}
