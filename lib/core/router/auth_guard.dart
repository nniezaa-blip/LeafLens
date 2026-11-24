import 'package:go_router/go_router.dart';

import 'package:lextari/core/router/app_routes.dart';

class AuthGuard {
  const AuthGuard._();

  static String? call({
    required GoRouterState state,
    required bool isLoggedIn,
    String? currentToken,
  }) {
    final path = state.matchedLocation;
    final authenticated = isLoggedIn || currentToken != null;

    if (path == AppRoutes.splash) return null;

    final isPublic = path == AppRoutes.login || path == AppRoutes.signUp;

    if (!authenticated && !isPublic) return AppRoutes.login;
    if (authenticated && isPublic) return AppRoutes.dashboard;
    return null;
  }
}
