import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/auth/domain/auth_user.dart';
import 'package:lextari/features/auth/domain/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('maps the auth user email onto the profile', () {
      final profile = UserProfile.fromUser(
        const AuthUser(id: 'user-1', email: 'aishah@example.com'),
      );

      expect(profile.name, 'Aishah');
      expect(profile.email, 'aishah@example.com');
      expect(profile.initial, 'A');
    });

    test('derives a display name from the email local part', () {
      final profile = UserProfile.fromUser(
        const AuthUser(id: 'user-1', email: 'aishah.abdul.aziz@example.com'),
      );

      expect(profile.name, 'Aishah Abdul Aziz');
    });

    test('normalises underscores and ignores plus tags', () {
      final profile = UserProfile.fromEmail('aishah_abdul+test@example.com');

      expect(profile.name, 'Aishah Abdul');
      expect(profile.email, 'aishah_abdul+test@example.com');
    });

    test('returns the unknown profile when there is no user', () {
      final profile = UserProfile.fromUser(null);

      expect(profile.name, 'Plant Lover');
      expect(profile.email, isEmpty);
      expect(profile.avatarUrl, isNull);
      expect(profile.initial, 'P');
    });
  });
}
