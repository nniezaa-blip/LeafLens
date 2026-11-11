import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lextari/features/auth/domain/auth_session.dart';
import 'package:lextari/features/auth/domain/auth_user.dart';

/// Persists the session in the platform keychain/keystore.
///
/// Modelled on the proven AISolutions `PlatformCredentialStore`: credentials
/// go to secure storage only, reads tolerate corrupt data, and failures are
/// logged rather than crashing the login flow.
class AuthSessionStore {
  /// Creates a store, optionally backed by a custom [storage] for tests.
  AuthSessionStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(resetOnError: false),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
            ),
          );

  static const String _key = 'lextari.session';

  final FlutterSecureStorage _storage;

  /// Reads the stored session, or null when absent or unreadable.
  Future<AuthSession?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        debugPrint('[Auth] Ignoring malformed session payload.');
        return null;
      }
      return _fromJson(decoded);
    } on Object catch (error) {
      debugPrint('[Auth] Could not read stored session: $error');
      return null;
    }
  }

  /// Writes [session], replacing any previous one.
  Future<void> save(AuthSession session) async {
    try {
      await _storage.write(
        key: _key,
        value: jsonEncode({
          'accessToken': session.accessToken,
          'userId': session.user.id,
          'email': session.user.email,
          'expiresAt': session.expiresAt.toUtc().millisecondsSinceEpoch,
        }),
      );
    } on Object catch (error) {
      debugPrint('[Auth] Could not persist session: $error');
    }
  }

  /// Removes any stored session.
  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } on Object catch (error) {
      debugPrint('[Auth] Could not clear stored session: $error');
    }
  }

  static AuthSession? _fromJson(Map<String, Object?> json) {
    final accessToken = json['accessToken'];
    final userId = json['userId'];
    final email = json['email'];
    final expiresAt = json['expiresAt'];
    if (accessToken is! String || accessToken.isEmpty) return null;
    if (userId is! String || userId.isEmpty) return null;
    if (email is! String) return null;
    if (expiresAt is! int) return null;
    return AuthSession(
      accessToken: accessToken,
      user: AuthUser(id: userId, email: email),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(expiresAt, isUtc: true),
    );
  }
}
