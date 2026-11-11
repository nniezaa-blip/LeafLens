import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lextari/core/config/app_config.dart';
import 'package:lextari/features/auth/data/auth_api.dart';

/// Wraps Google Sign-In and returns a server-verifiable ID token.
///
/// The Android OAuth client identifies the app to Play Services, but the ID
/// token's `aud` is the *web* client, so serverClientId must be that web
/// client from the same Google Cloud project.
class GoogleSignInService {
  /// Creates the service; serverClientId defaults to
  /// [AppConfig.googleServerClientId].
  GoogleSignInService({String? serverClientId})
    : _serverClientId = serverClientId ?? AppConfig.googleServerClientId;

  final String _serverClientId;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  /// Whether a server client id is configured.
  bool get isConfigured => _serverClientId.isNotEmpty;

  /// Runs the Google consent flow and returns the ID token.
  ///
  /// Throws [AuthException] with `canceled` when the user backs out.
  Future<String> idToken() async {
    if (!isConfigured) {
      throw const AuthException('google_not_configured');
    }

    if (!_initialized) {
      await _googleSignIn.initialize(serverClientId: _serverClientId);
      _initialized = true;
    }

    final GoogleSignInAccount account;
    try {
      account = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('canceled');
      }
      debugPrint(
        '[Auth] Google sign-in failed: ${error.code} ${error.description}',
      );
      throw const AuthException('google_sign_in_failed');
    }

    final token = account.authentication.idToken;
    if (token == null) {
      throw const AuthException('google_not_configured');
    }
    return token;
  }
}
