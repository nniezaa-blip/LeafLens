/// The signed-in account as returned by the Lextari auth Worker.
class AuthUser {
  /// Creates an [AuthUser].
  const AuthUser({required this.id, required this.email});

  /// Builds an [AuthUser] from the Worker's JSON payload.
  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String? ?? '',
    email: json['email'] as String? ?? '',
  );

  /// Stable user id (the JWT `sub` claim).
  final String id;

  /// The account's email address.
  final String email;
}
