import 'package:lextari/features/auth/domain/user_profile.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/user_avatar.dart';

/// A profile avatar with a botanical ring.
class ProfileBadge extends StatelessWidget {
  /// Creates a [ProfileBadge].
  const ProfileBadge({
    required this.profile,
    super.key,
    this.size = AppSizes.profileBadge,
    this.onTap,
  });

  /// Profile shown in the badge.
  final UserProfile profile;

  /// Outer diameter of the badge.
  final double size;

  /// Opens the profile when set.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final avatarSize = size - AppSizes.profileRing * 2;
    final badge = Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(AppSizes.profileRing),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: AppOpacity.faint),
            blurRadius: AppSpacing.s8,
            offset: const Offset(0, AppSpacing.s2),
          ),
        ],
      ),
      child: ClipOval(
        child: UserAvatar(
          profile: profile,
          size: avatarSize,
          fontSize: AppSizes.profileBadgeFont,
        ),
      ),
    );
    if (onTap == null) return badge;
    return Semantics(
      button: true,
      label: 'Profile',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: badge,
      ),
    );
  }
}
