import 'package:flutter_test/flutter_test.dart';
import 'package:lextari/features/auth/domain/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  User buildUser({
    String? email,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: 'user-1',
      appMetadata: const {},
      userMetadata: metadata,
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00Z',
      email: email,
    );
  }

  group('UserProfile', () {
    test('reads name and avatar from metadata', () {
      final profile = UserProfile.fromUser(
        buildUser(
          email: 'aishah@example.com',
          metadata: const {
            'full_name': 'Aishah Abdul Aziz',
            'avatar_url': 'https://example.com/avatar.png',
          },
        ),
      );

      expect(profile.name, 'Aishah Abdul Aziz');
      expect(profile.email, 'aishah@example.com');
      expect(profile.avatarUrl, 'https://example.com/avatar.png');
      expect(profile.initial, 'A');
    });

    test('falls back to picture for the avatar', () {
      final profile = UserProfile.fromUser(
        buildUser(
          email: 'aishah@example.com',
          metadata: const {'picture': 'https://example.com/photo.png'},
        ),
      );

      expect(profile.avatarUrl, 'https://example.com/photo.png');
    });

    test('derives a display name from the email local part', () {
      final profile = UserProfile.fromUser(
        buildUser(email: 'aishah.abdul.aziz@example.com'),
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
