import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/auth/data/user_profile_provider.dart';
import 'package:lextari/features/auth/domain/user_profile.dart';
import 'package:lextari/features/settings/presentation/settings_screen.dart';
import 'package:lextari/features/settings/presentation/widgets/settings_switch.dart';

void main() {
  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        currentUserProfileProvider.overrideWithValue(
          const UserProfile(
            name: 'Aishah Abdul Aziz',
            email: 'aishah.abdulaziz@example.com',
          ),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SettingsScreen(),
        ),
      ),
    );
  }

  group('SettingsScreen', () {
    testWidgets('renders header and profile details', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Aishah Abdul Aziz'), findsOneWidget);
      expect(
        find.text('aishah.abdulaziz@example.com'),
        findsOneWidget,
      );
    });

    testWidgets('renders preference switch rows', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('Pause notifications'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);
      expect(find.byType(SettingsSwitch), findsNWidgets(2));
    });

    testWidgets('toggles pause notifications switch on tap', (tester) async {
      await tester.pumpWidget(buildTestApp());

      final pauseSwitch = find.byType(SettingsSwitch).first;
      expect(tester.widget<SettingsSwitch>(pauseSwitch).value, isFalse);

      await tester.tap(find.text('Pause notifications'));
      await tester.pumpAndSettle();

      expect(tester.widget<SettingsSwitch>(pauseSwitch).value, isTrue);
    });

    testWidgets('renders general navigation tiles with chevrons', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('General Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('About Lextari'), findsOneWidget);

      // One chevron on the profile card plus one per nav tile.
      expect(
        find.byIcon(Icons.chevron_right_rounded),
        findsNWidgets(6),
      );
    });
  });
}
