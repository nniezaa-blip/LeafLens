import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lextari/core/router/app_routes.dart';
import 'package:lextari/core/router/auth_guard.dart';
import 'package:lextari/features/auth/presentation/login_page.dart';
import 'package:lextari/features/auth/presentation/signup_page.dart';
import 'package:lextari/features/auth/providers/auth_providers.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_shell.dart';
import 'package:lextari/features/settings/presentation/settings_screen.dart';
import 'package:lextari/features/splash/presentation/splash_screen.dart';
import 'package:lextari/features/stats/presentation/stats_screen.dart';
import 'package:prism_ui/prism_ui.dart' as prism;

class AppRouter {
  const AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final Provider<GoRouter> provider = Provider<GoRouter>((ref) {
    final authManager = ref.watch(authManagerProvider);
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: authManager,
      redirect: (context, state) {
        final session = authManager.currentSession;
        return AuthGuard.call(
          state: state,
          isLoggedIn: session != null,
          currentToken: session?.accessToken,
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.splash,
          pageBuilder: (context, state) => _fadeThroughPage(
            state: state,
            child: const SplashScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          pageBuilder: (context, state) => _fadeThroughPage(
            state: state,
            child: const LoginPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.signUp,
          pageBuilder: (context, state) => _fadeThroughPage(
            state: state,
            child: const SignUpPage(),
          ),
        ),
        StatefulShellRoute.indexedStack(
          pageBuilder: (context, state, navigationShell) => _fadeThroughPage(
            state: state,
            child: DashboardShell(navigationShell: navigationShell),
          ),
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.dashboard,
                  pageBuilder: (_, state) => const NoTransitionPage<void>(
                    child: DashboardScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.stats,
                  pageBuilder: (_, state) => const NoTransitionPage<void>(
                    child: StatsScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.settings,
                  pageBuilder: (_, state) => const NoTransitionPage<void>(
                    child: SettingsScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  });

  static CustomTransitionPage<void> _fadeThroughPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return prism.FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }
}
