import 'package:supabase_flutter/supabase_flutter.dart';

/// Display profile for the signed-in user.
///
/// Name and avatar are read from the Supabase user's metadata when
/// available (e.g. Google sign-in supplies `full_name` and `avatar_url`).
/// Email/password accounts have no metadata, so a readable display name is
/// derived from the email local part and the avatar falls back to an initial.
class UserProfile {
  /// Creates a [UserProfile].
  const UserProfile({
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  /// Builds a profile from a Supabase [user].
  factory UserProfile.fromUser(User? user) {
    if (user == null) return unknown;

    final metadata = user.userMetadata;
    final name =
        _metadataString(metadata, 'full_name') ??
        _metadataString(metadata, 'name') ??
        _metadataString(metadata, 'display_name') ??
        _metadataString(metadata, 'preferred_username') ??
        _nameFromEmail(user.email);
    final avatarUrl =
        _metadataString(metadata, 'avatar_url') ??
        _metadataString(metadata, 'picture');

    return UserProfile(
      name: name,
      email: user.email ?? '',
      avatarUrl: avatarUrl,
    );
  }

  /// Builds a profile from an [email] alone, deriving a readable name.
  factory UserProfile.fromEmail(String email) {
    return UserProfile(name: _nameFromEmail(email), email: email);
  }

  /// Display name shown in the dashboard and settings.
  final String name;

  /// The signed-in user's email address.
  final String email;

  /// Optional remote avatar image URL.
  final String? avatarUrl;

  /// Fallback used when no user is signed in.
  static const UserProfile unknown = UserProfile(
    name: 'Plant Lover',
    email: '',
  );

  /// First letter of [name], used for the initials avatar.
  String get initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

  static String? _metadataString(Map<String, dynamic>? metadata, String key) {
    final value = metadata?[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  static String _nameFromEmail(String? email) {
    if (email == null || email.trim().isEmpty) return unknown.name;

    final localPart = email.split('@').first.split('+').first;
    final words = localPart
        .split(RegExp(r'[._\-\s]+'))
        .where((word) => word.isNotEmpty);

    if (words.isEmpty) return unknown.name;

    return words.map(_capitalize).join(' ');
  }

  static String _capitalize(String word) {
    if (word.length == 1) return word.toUpperCase();
    return word[0].toUpperCase() + word.substring(1);
  }
}
