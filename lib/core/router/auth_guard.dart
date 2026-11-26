import 'package:go_router/go_router.dart';

import 'package:lextari/core/router/app_routes.dart';

class AuthGuard {
  const AuthGuard._();

  static String? call({
    required GoRouterState state,
    required bool isLoggedIn,
    String? currentToken,
    bool hasLinkedDevice = false,
    bool deviceCheckResolved = false,
    bool deviceProvisioningSkipped = false,
  }) {
    final path = state.matchedLocation;
    final authenticated = isLoggedIn || currentToken != null;

    if (path == AppRoutes.splash) return null;

    final isPublic = AppRoutes.publicRoutes.contains(path);
    final isOnboarding = path == AppRoutes.onboarding;

    if (!authenticated && !isPublic) return AppRoutes.login;
    if (authenticated && isPublic) {
      if (!deviceCheckResolved) return AppRoutes.dashboard;
      if (!hasLinkedDevice && !deviceProvisioningSkipped) {
        return AppRoutes.onboarding;
      }
      return AppRoutes.dashboard;
    }
    if (authenticated &&
        deviceCheckResolved &&
        !hasLinkedDevice &&
        !deviceProvisioningSkipped &&
        !isOnboarding) {
      return AppRoutes.onboarding;
    }
    if (authenticated &&
        deviceCheckResolved &&
        hasLinkedDevice &&
        isOnboarding) {
      return AppRoutes.dashboard;
    }
    return null;
  }
}
