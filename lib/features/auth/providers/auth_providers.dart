import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lextari/core/network/api_client.dart';
import 'package:lextari/features/auth/data/auth_repository.dart';
import 'package:lextari/features/auth/data/auth_session_manager.dart';
import 'package:lextari/features/auth/domain/auth_session.dart';
import 'package:lextari/features/auth/domain/user_profile.dart';

export 'package:lextari/features/auth/data/auth_repository.dart'
    show apiClientProvider, authRepositoryProvider;
export 'package:lextari/features/auth/data/auth_session_manager.dart'
    show authManagerProvider, authSessionProvider;
export 'package:lextari/features/auth/data/user_profile_provider.dart'
    show currentUserProfileProvider;

final authSessionValueProvider = Provider<AsyncValue<AuthSession?>>((ref) {
  return ref.watch(authSessionProvider);
});

final authAccessTokenProvider = Provider<String?>((ref) {
  return ref.watch(authManagerProvider).currentSession?.accessToken;
});

final currentAuthProfileProvider = Provider<UserProfile>((ref) {
  return ref.watch(currentUserProfileProvider);
});
