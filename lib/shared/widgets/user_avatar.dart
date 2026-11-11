import 'package:flutter/material.dart';
import 'package:lextari/core/theme/app_colors.dart';
import 'package:lextari/features/auth/domain/user_profile.dart';

/// Circular avatar for the signed-in user.
///
/// Shows the profile's remote image when one is available and falls back to
/// the user's initial otherwise.
class UserAvatar extends StatelessWidget {
  /// Creates a [UserAvatar].
  const UserAvatar({
    required this.profile,
    this.size = 52,
    this.fontSize = 28,
    this.onTap,
    super.key,
  });

  /// The profile whose avatar is displayed.
  final UserProfile profile;

  /// Diameter of the avatar.
  final double size;

  /// Font size of the fallback initial.
  final double fontSize;

  /// Optional tap handler (e.g. logout from the dashboard).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fallback = _InitialAvatar(
      profile: profile,
      size: size,
      fontSize: fontSize,
    );
    final url = profile.avatarUrl;

    final avatar = url == null || url.isEmpty
        ? fallback
        : ClipOval(
            child: Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            ),
          );

    if (onTap == null) return avatar;

    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: '${profile.name} profile',
        child: avatar,
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({
    required this.profile,
    required this.size,
    required this.fontSize,
  });

  final UserProfile profile;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.mediumGreen,
        shape: BoxShape.circle,
      ),
      child: Text(
        profile.initial,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
          color: AppColors.white,
        ),
      ),
    );
  }
}
