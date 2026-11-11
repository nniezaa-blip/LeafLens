import 'package:lextari/features/auth/domain/auth_user.dart';

/// A signed-in session: the bearer token, its owner and its expiry.
class AuthSession {
  /// Creates an [AuthSession].
  const AuthSession({
    required this.accessToken,
    required this.user,
    required this.expiresAt,
  });

  /// Access token to send as `Authorization: Bearer …`.
  final String accessToken;

  /// The account the token belongs to.
  final AuthUser user;

  /// Moment the token stops being accepted.
  final DateTime expiresAt;

  /// Whether the token's `exp` has passed.
  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);
}
