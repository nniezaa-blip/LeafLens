import 'package:lextari/core/errors/failures.dart';
import 'package:lextari/core/network/api_client.dart';
import 'package:lextari/features/auth/data/auth_api.dart';
import 'package:lextari/features/auth/data/auth_session_manager.dart';
import 'package:lextari/features/auth/domain/auth_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

/// UI-facing auth operations.
///
/// Translates transport failures into the app's [Failure] types so screens
/// never see [AuthException] or HTTP details.
class AuthRepository {
  /// Creates an [AuthRepository] over the shared session manager.
  AuthRepository(this._manager);

  final AuthSessionManager _manager;

  /// Login with email/password.
  /// Throws [AuthFailure] with a user-friendly message on failure.
  Future<void> login(String email, String password) => _run(
    () => _manager.login(email: email, password: password),
  );

  /// Register a new account.
  /// Throws [AuthFailure] with a user-friendly message on failure.
  Future<void> register(String email, String password) => _run(
    () => _manager.register(email: email, password: password),
  );

  /// Logout — clears the session locally and revokes it server-side.
  Future<void> logout() => _manager.logout();

  Future<void> _run(Future<AuthSession> Function() action) async {
    try {
      await action();
    } on AuthException catch (error) {
      if (error.code == 'network' || error.code == 'timeout') {
        throw const NetworkFailure();
      }
      throw AuthFailure(_messages[error.code] ?? _fallback);
    }
  }

  static const _fallback = 'Something went wrong. Please try again.';

  /// Auth Worker error code → user-friendly message.
  static const _messages = {
    'email_exists': 'This email is already registered.',
    'invalid_credentials': 'Email or password is incorrect.',
    'too_many_attempts': 'Too many attempts. Please wait and try again.',
    'invalid_request':
        'Enter a valid email and a password of at least 8 characters.',
    'auth_not_configured': 'Login is not configured. Please try again later.',
  };
}

// ── Providers ────────────────────────────────────────────

/// Provides a singleton [ApiClient] instance.
///
/// The bearer token follows the session, and a 401 drops the stored session.
@riverpod
ApiClient apiClient(Ref ref) {
  final manager = ref.read(authManagerProvider);
  final client = ApiClient()
    ..onSessionExpired = manager.forget
    ..token = manager.currentSession?.accessToken;

  ref.listen(authSessionProvider, (previous, next) {
    client.token = next.value?.accessToken;
  }, fireImmediately: true);

  return client;
}

/// Provides the [AuthRepository] used for login/signup/logout operations.
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(authManagerProvider));
}
