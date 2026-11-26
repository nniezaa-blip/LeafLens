import 'package:lextari/features/auth/domain/user_profile.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/user_avatar.dart';

/// A profile avatar with a botanical ring and an optional presence dot.
class ProfileBadge extends StatelessWidget {
  /// Creates a [ProfileBadge].
  const ProfileBadge({
    required this.profile,
    super.key,
    this.size = AppSizes.profileBadge,
    this.onTap,
    this.online = false,
  });

  /// Profile shown in the badge.
  final UserProfile profile;

  /// Outer diameter of the badge.
  final double size;

  /// Opens the profile when set.
  final VoidCallback? onTap;

  /// Whether the presence dot is filled.
  final bool online;

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
    final presence = Container(
      width: AppSizes.statusDot,
      height: AppSizes.statusDot,
      decoration: BoxDecoration(
        color: online ? scheme.success : scheme.outline,
        shape: BoxShape.circle,
        border: Border.all(
          color: scheme.surface,
          width: AppSizes.statusDotBorder,
        ),
      ),
    );
    final content = Stack(
      clipBehavior: Clip.none,
      children: [
        badge,
        Positioned(right: 0, bottom: 0, child: presence),
      ],
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      label: 'Profile',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      ),
    );
  }
}
