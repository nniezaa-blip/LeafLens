import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/auth/providers/auth_providers.dart';

final authActionsProvider = Provider<AuthActions>((ref) {
  return AuthActions(ref);
});

class AuthActions {
  AuthActions(this._ref);
  final Ref _ref;

  Future<void> login(String email, String password) {
    return _ref.read(authRepositoryProvider).login(email, password);
  }

  Future<void> register(String email, String password) {
    return _ref.read(authRepositoryProvider).register(email, password);
  }

  Future<bool> signInWithGoogle() {
    return _ref.read(authRepositoryProvider).signInWithGoogle();
  }

  Future<void> logout() {
    return _ref.read(authRepositoryProvider).logout();
  }
}
