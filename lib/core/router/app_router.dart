import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lextari/core/router/auth_guard.dart';
import 'package:lextari/features/auth/data/auth_session_manager.dart';
import 'package:lextari/features/auth/presentation/login_page.dart';
import 'package:lextari/features/auth/presentation/signup_page.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_shell.dart';
import 'package:lextari/features/settings/presentation/settings_screen.dart';
import 'package:lextari/features/splash/presentation/splash_screen.dart';
import 'package:lextari/features/stats/presentation/stats_screen.dart';

/// Centralised GoRouter configuration for Lextari.
///
/// Wraps all routing logic in one place. Screens never import GoRouter
/// directly — they use GoRouterHelper extensions from context instead.
class AppRouter {
  const AppRouter._();

  /// Root navigator key shared with NotificationService.
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  /// First screen shown when the app cold starts.
  static const String appRouterInitialLocation = '/splash';

  /// GoRouter provider wired to auth state.
  static final provider = Provider<GoRouter>((ref) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: appRouterInitialLocation,
      refreshListenable: ref.watch(authManagerProvider),
      redirect: (context, state) {
        // Read the live session synchronously so the redirect never depends on
        // whether the session stream has emitted yet.
        final session = ref.read(authManagerProvider).currentSession;
        return AuthGuard.call(
          state: state,
          isLoggedIn: session != null,
          currentToken: session?.accessToken,
        );
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
        StatefulShellRoute.indexedStack(
          builder: (_, _, navigationShell) => DashboardShell(
            navigationShell: navigationShell,
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/dashboard',
                  pageBuilder: (_, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const DashboardScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/stats',
                  pageBuilder: (_, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const StatsScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  pageBuilder: (_, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const SettingsScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  });
}
