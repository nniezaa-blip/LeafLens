import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/auth/data/auth_api.dart';
import 'package:lextari/features/auth/data/auth_session_store.dart';
import 'package:lextari/features/auth/domain/auth_session.dart';

/// Single source of truth for the signed-in session.
///
/// Owns the in-memory session, restores it from secure storage on start, and
/// notifies listeners whenever it changes. Transport lives in AuthApi,
/// persistence in AuthSessionStore; this class only orchestrates.
class AuthSessionManager extends ChangeNotifier {
  /// Creates a manager over the given API client and store.
  AuthSessionManager(this._api, this._store);

  final AuthApi _api;
  final AuthSessionStore _store;
  final StreamController<AuthSession?> _updates =
      StreamController<AuthSession?>.broadcast();

  AuthSession? _session;
  Future<void>? _restoring;

  /// The current session, or null when signed out.
  AuthSession? get currentSession => _session;

  /// Whether a session is currently held in memory.
  bool get isSignedIn => _session != null;

  /// Emits the current session immediately, then every change.
  Stream<AuthSession?> get changes async* {
    yield _session;
    yield* _updates.stream;
  }

  /// Restores a persisted session once; later calls reuse the same future.
  ///
  /// Expired tokens are discarded, rejected tokens are discarded, and an
  /// offline start keeps the local session.
  Future<void> ensureRestored() => _restoring ??= _restore();

  /// Logs in and persists the issued session.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _api.login(email: email, password: password);
    await _persist(session);
    return session;
  }

  /// Registers an account and persists the issued session.
  Future<AuthSession> register({
    required String email,
    required String password,
  }) async {
    final session = await _api.register(email: email, password: password);
    await _persist(session);
    return session;
  }

  /// Clears the local session, then asks the Worker to revoke it.
  Future<void> logout() async {
    final token = _session?.accessToken;
    await _clear();
    if (token != null) await _api.logout(token);
  }

  /// Drops the session after the API rejected the token.
  Future<void> forget() => _clear();

  Future<void> _restore() async {
    if (!_api.isConfigured) return;

    final stored = await _store.read();
    if (stored == null) return;
    if (stored.isExpired) {
      await _store.clear();
      return;
    }
    if (!await _api.isTokenAccepted(stored.accessToken)) {
      await _clear();
      return;
    }
    _publish(stored);
  }

  Future<void> _persist(AuthSession session) async {
    await _store.save(session);
    _publish(session);
  }

  Future<void> _clear() async {
    await _store.clear();
    _publish(null);
  }

  void _publish(AuthSession? session) {
    _session = session;
    _updates.add(session);
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_updates.close());
    super.dispose();
  }
}

// ── Providers ────────────────────────────────────────────

/// Transport client for the auth Worker.
final authApiProvider = Provider<AuthApi>((ref) => AuthApi());

/// Secure storage for the session.
final authSessionStoreProvider = Provider<AuthSessionStore>(
  (ref) => AuthSessionStore(),
);

/// The application's single [AuthSessionManager].
final authManagerProvider = Provider<AuthSessionManager>((ref) {
  final manager = AuthSessionManager(
    ref.watch(authApiProvider),
    ref.watch(authSessionStoreProvider),
  );
  ref.onDispose(manager.dispose);
  return manager;
});

/// Reactive view of the session, for widgets and other providers.
final authSessionProvider = StreamProvider<AuthSession?>(
  (ref) => ref.watch(authManagerProvider).changes,
);
