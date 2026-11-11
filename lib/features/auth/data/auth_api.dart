import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lextari/core/config/app_config.dart';
import 'package:lextari/features/auth/domain/auth_session.dart';
import 'package:lextari/features/auth/domain/auth_user.dart';

/// Thrown when the auth Worker rejects a request.
class AuthException implements Exception {
  /// Creates an [AuthException] carrying the Worker's error [code].
  const AuthException(this.code, {this.statusCode = 0});

  /// Machine-readable code, e.g. `invalid_credentials`, `network`, `timeout`.
  final String code;

  /// HTTP status returned by the Worker, or `0` for transport failures.
  final int statusCode;

  @override
  String toString() => 'AuthException($code, status: $statusCode)';
}

/// Transport for the Lextari auth Worker.
///
/// Owns HTTP only: no state, no persistence. Callers get a typed
/// [AuthSession] or an [AuthException].
class AuthApi {
  /// Creates the client; [baseUrl] defaults to [AppConfig.authUrl].
  AuthApi({
    String? baseUrl,
    http.Client? client,
    Duration timeout = const Duration(seconds: 20),
  }) : baseUrl = baseUrl ?? AppConfig.authUrl,
       _client = client ?? http.Client(),
       _timeout = timeout;

  /// Base URL of the auth Worker (no trailing slash).
  final String baseUrl;

  final http.Client _client;
  final Duration _timeout;

  /// Whether a Worker URL is configured at all.
  bool get isConfigured => baseUrl.isNotEmpty;

  /// Logs in with email/password.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) => _authenticate('/auth/login', email, password);

  /// Registers a new account.
  Future<AuthSession> register({
    required String email,
    required String password,
  }) => _authenticate('/auth/register', email, password);

  /// Best-effort server-side logout; the local session is cleared regardless.
  Future<void> logout(String token) async {
    if (!isConfigured) return;
    try {
      await _client
          .post(
            Uri.parse('$baseUrl/auth/logout'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);
    } on Object {
      // Logout is best-effort by design: the token expires on its own.
    }
  }

  /// Asks the Worker whether [token] is still valid.
  ///
  /// A transport failure answers `true` (offline start) so a saved session
  /// survives until the network can actually reject it.
  Future<bool> isTokenAccepted(String token) async {
    if (!isConfigured) return false;
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/auth/me'),
            headers: {'authorization': 'Bearer $token'},
          )
          .timeout(_timeout);
      return response.statusCode != 401;
    } on Object {
      return true;
    }
  }

  Future<AuthSession> _authenticate(
    String path,
    String email,
    String password,
  ) async {
    if (!isConfigured) {
      throw const AuthException('auth_not_configured');
    }

    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$baseUrl$path'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const AuthException('timeout');
    } on Exception {
      throw const AuthException('network');
    }

    final body = _decode(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AuthException(
        body['error'] as String? ?? 'unknown',
        statusCode: response.statusCode,
      );
    }

    final accessToken = body['access_token'];
    final user = body['user'];
    if (accessToken is! String || user is! Map<String, dynamic>) {
      throw AuthException('invalid_response', statusCode: response.statusCode);
    }

    return AuthSession(
      accessToken: accessToken,
      user: AuthUser.fromJson(user),
      expiresAt: DateTime.now().toUtc().add(_ttl(body['expires_in'])),
    );
  }

  static Duration _ttl(Object? seconds) {
    if (seconds is int && seconds > 0) return Duration(seconds: seconds);
    return const Duration(hours: 12);
  }

  static Map<String, dynamic> _decode(String raw) {
    if (raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }
}
