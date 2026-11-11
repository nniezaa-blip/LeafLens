import 'package:lextari/core/errors/failures.dart';
import 'package:lextari/core/network/api_client.dart';
import 'package:lextari/features/auth/data/lextari_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository.g.dart';

/// Repository for Lextari user auth through LextariAuth.
///
/// The rest of the app calls this, not LextariAuth directly.
class AuthRepository {
  /// Creates an [AuthRepository] backed by the given [ApiClient].
  AuthRepository(this._api);
  final ApiClient _api;

  /// Login with email/password.
  /// Throws [AuthFailure] with a user-friendly message on failure.
  Future<void> login(String email, String password) async {
    try {
      final token = await LextariAuth.signInWithPassword(
        email: email,
        password: password,
      );
      _api.token = token;
    } on AuthRetryableFetchException {
      throw const NetworkFailure();
    } on AuthException catch (e) {
      throw AuthFailure(_mapSupabaseError(e));
    }
  }

  /// Register a new account.
  /// Throws [AuthFailure] with a user-friendly message on failure.
  Future<void> register(String email, String password) async {
    try {
      final token = await LextariAuth.signUp(
        email: email,
        password: password,
      );
      _api.token = token;
    } on AuthRetryableFetchException {
      throw const NetworkFailure();
    } on AuthException catch (e) {
      throw AuthFailure(_mapSupabaseError(e));
    }
  }

  /// Logout — clears the Supabase session and API token.
  Future<void> logout() async {
    await LextariAuth.signOut();
    _api.token = null;
  }

  /// Maps a Supabase [AuthException] to user-friendly text.
  ///
  /// Supabase's error `code` (see the `ErrorCode` enum in the `gotrue`
  /// package, https://supabase.com/docs/guides/auth/debugging/error-codes)
  /// is the stable, documented identifier for an auth failure — unlike
  /// `message`, which is free-text and not guaranteed to match any
  /// particular wording. Match on `code` first; only fall back to the
  /// raw message for the handful of legacy errors GoTrue still returns
  /// without a code (e.g. wrong password).
  static String _mapSupabaseError(AuthException e) {
    final byCode = _codeMessages[e.code];
    if (byCode != null) return byCode;

    final raw = e.message.toLowerCase();
    for (final entry in _legacyMessageMap.entries) {
      if (raw.contains(entry.key)) return entry.value;
    }

    // Fallback — don't leak raw Supabase text.
    return 'Something went wrong. Please try again.';
  }

  /// Supabase `AuthException.code` → user-friendly message.
  /// Codes taken from `gotrue`'s `ErrorCode` enum (the full list Supabase
  /// documents at the URL above); only codes reachable from
  /// [LextariAuth.signInWithPassword]/[LextariAuth.signUp] are mapped.
  static const _codeMessages = {
    'email_exists': 'This email is already registered.',
    'user_already_exists': 'This email is already registered.',
    'weak_password': 'Password is too weak. Try a longer password.',
    'email_not_confirmed': 'Please confirm your email before logging in.',
    'validation_failed': 'Enter a valid email address.',
    'over_email_send_rate_limit':
        'Too many attempts. Please wait and try again.',
    'over_request_rate_limit': 'Too many attempts. Please wait and try again.',
    'signup_disabled': 'Account creation is currently disabled.',
    'email_provider_disabled': 'Email sign-up is currently disabled.',
    'user_banned': 'This account has been suspended.',
    'captcha_failed': 'Verification failed. Please try again.',
    'request_timeout': 'The request timed out. Please try again.',
  };

  /// GoTrue returns some errors — notably wrong email/password — as a
  /// plain 400 with no `code`, only a `message`. This is the only
  /// substring fallback still needed; keep it minimal.
  static const _legacyMessageMap = {
    'invalid login credentials': 'Email or password is incorrect.',
  };
}

// ── Providers ────────────────────────────────────────────

/// Provides a singleton [ApiClient] instance.
@riverpod
ApiClient apiClient(Ref ref) => ApiClient();

/// Provides the [AuthRepository] used for login/signup/logout operations.
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.read(apiClientProvider));
}
