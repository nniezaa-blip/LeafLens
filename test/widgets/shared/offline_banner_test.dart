import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lextari/features/dashboard/data/dashboard_providers.dart';
import 'package:lextari/shared/widgets/offline_banner.dart';

Widget buildTestAppWithAuth(String? token) {
  return ProviderScope(
    overrides: [
      authStateProvider.overrideWith((ref) => Stream<String?>.value(token)),
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
