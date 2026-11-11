import 'package:supabase_flutter/supabase_flutter.dart';

/// Application-level auth service.
///
/// Wraps the underlying auth provider so the rest of the app never
/// imports a specific auth SDK directly.
///
/// Must be initialized once with [init] before any other method is called.
class LextariAuth {
  LextariAuth._();

  /// Initialise with the provider's [url] and [publishableKey].
  /// Call once from main after WidgetsFlutterBinding.ensureInitialized.
  static Future<void> init({
    required String url,
    required String publishableKey,
  }) async {
    await Supabase.initialize(url: url, publishableKey: publishableKey);
  }

  static SupabaseClient get _client => Supabase.instance.client;

  // ── Auth API ────────────────────────────────────────────

  /// Login with email/password. Returns the access token.
  static Future<String> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.session!.accessToken;
  }

  /// Register a new account. Returns the access token, or null if
  /// email confirmation is required.
  static Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return response.session?.accessToken;
  }

  /// Logout — clears the session.
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── Session ─────────────────────────────────────────────

  /// The signed-in user, or null when signed out / not initialised.
  static User? get currentUser {
    try {
      return _client.auth.currentUser;
    } on Object {
      return null;
    }
  }

  /// Current access token, or null if not logged in.
  static String? get accessToken => _client.auth.currentSession?.accessToken;

  /// Stream of auth state changes. Emits on login, logout, token refresh.
  static Stream<AuthState> get onAuthChange => _client.auth.onAuthStateChange;
}
