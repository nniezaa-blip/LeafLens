import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lextari/features/auth/data/auth_session_manager.dart';
import 'package:lextari/features/auth/domain/auth_session.dart';
import 'package:lextari/features/auth/domain/auth_user.dart';
import 'package:lextari/shared/widgets/offline_banner.dart';

Widget buildTestAppWithAuth(String? token) {
  return ProviderScope(
    overrides: [
      authSessionProvider.overrideWith(
        (ref) => Stream<AuthSession?>.value(
          token == null
              ? null
              : AuthSession(
                  accessToken: token,
                  user: const AuthUser(id: 'user-1', email: 'a@b.co'),
                  expiresAt: DateTime.now().toUtc().add(
                    const Duration(hours: 1),
                  ),
                ),
        ),
      ),
    ],
    child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
  );
}

void main() {
  group('OfflineBanner', () {
    testWidgets('shows nothing when authenticated', (tester) async {
      await tester.pumpWidget(buildTestAppWithAuth('token123'));
      await tester.pumpAndSettle();

      // Banner text should not be present
      expect(
        find.text('No connection — showing last known data'),
        findsNothing,
      );
      // Should be SizedBox.shrink (empty widget)
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('shows banner when unauthenticated', (tester) async {
      await tester.pumpWidget(buildTestAppWithAuth(null));
      await tester.pumpAndSettle();

      expect(
        find.text('No connection — showing last known data'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.byType(MaterialBanner), findsOneWidget);
    });
  });
}
