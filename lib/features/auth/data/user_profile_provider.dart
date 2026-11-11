import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/auth/data/lextari_auth.dart';
import 'package:lextari/features/auth/domain/user_profile.dart';

/// Provides the display profile of the currently signed-in user.
///
/// Auto-disposed so it is re-read after a logout/login cycle instead of
/// serving the previous account's details.
final Provider<UserProfile> currentUserProfileProvider =
    Provider.autoDispose<UserProfile>((ref) {
      return UserProfile.fromUser(LextariAuth.currentUser);
    });
