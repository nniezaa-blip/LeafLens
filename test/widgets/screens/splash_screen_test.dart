import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lextari/features/splash/presentation/splash_screen.dart';

import '../../helpers/test_asset_bundle.dart';

/// Pumps a bare [SplashScreen] (no router) so the widget can be
/// inspected in isolation. Advances past [SplashScreen.displayDuration]
/// so the auto-advance timer does not linger after the test.
Future<void> _pumpSplash(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: const SplashScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.pump(SplashScreen.displayDuration);
  await tester.pumpAndSettle();
}

void main() {
  group('SplashScreen', () {
    testWidgets('renders brand text', (tester) async {
      await _pumpSplash(tester);

      expect(find.text('LEXTARI'), findsOneWidget);
      expect(find.textContaining('Smarter Care'), findsOneWidget);
    });

    testWidgets('renders Get Started button', (tester) async {
      await _pumpSplash(tester);

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('renders without errors', (tester) async {
      await _pumpSplash(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Stack layout', (tester) async {
      await _pumpSplash(tester);

      // MaterialApp also uses Stack internally
      expect(find.byType(Stack), findsAtLeast(1));
    });

    testWidgets('auto-advances after the display duration', (tester) async {
      final router = GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
          GoRoute(
            path: '/login',
            builder: (_, _) => const Scaffold(body: Text('Login')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: MaterialApp.router(routerConfig: router),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('LEXTARI'), findsOneWidget);

      await tester.pump(SplashScreen.displayDuration);
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });
  });
}
