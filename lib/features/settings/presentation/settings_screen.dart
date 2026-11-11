import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/core/theme/app_colors.dart';
import 'package:lextari/features/auth/data/user_profile_provider.dart';
import 'package:lextari/features/settings/presentation/widgets/settings_card.dart';
import 'package:lextari/features/settings/presentation/widgets/settings_nav_tile.dart';
import 'package:lextari/features/settings/presentation/widgets/settings_switch_tile.dart';
import 'package:lextari/shared/widgets/user_avatar.dart';

/// Settings tab — account profile, preferences, and general app options.
///
/// Sections are stacked as rounded white cards over the app's green
/// background. Switch state is local for now and can be wired to real
/// repositories as those land.
class SettingsScreen extends StatefulWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pauseNotifications = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Header(),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                const _ProfileCard(),
                const SizedBox(height: 20),
                const _SectionLabel('Preferences'),
                const SizedBox(height: 8),
                SettingsCard(
                  child: Column(
                    children: [
                      SettingsSwitchTile(
                        icon: Icons.notifications_paused_outlined,
                        label: 'Pause notifications',
                        value: _pauseNotifications,
                        onChanged: (value) =>
                            setState(() => _pauseNotifications = value),
                      ),
                      const _CardDivider(),
                      SettingsSwitchTile(
                        icon: Icons.dark_mode_outlined,
                        label: 'Dark mode',
                        value: _darkMode,
                        onChanged: (value) => setState(() => _darkMode = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const _SectionLabel('General'),
                const SizedBox(height: 8),
                SettingsCard(
                  child: Column(
                    children: [
                      SettingsNavTile(
                        icon: Icons.tune_rounded,
                        label: 'General Settings',
                        onTap: () {},
                      ),
                      const _CardDivider(),
                      SettingsNavTile(
                        icon: Icons.language_rounded,
                        label: 'Language',
                        trailingText: 'English',
                        onTap: () {},
                      ),
                      const _CardDivider(),
                      SettingsNavTile(
                        icon: Icons.description_outlined,
                        label: 'Terms of Service',
                        onTap: () {},
                      ),
                      const _CardDivider(),
                      SettingsNavTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        onTap: () {},
                      ),
                      const _CardDivider(),
                      SettingsNavTile(
                        icon: Icons.info_outline_rounded,
                        label: 'About Lextari',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// Private widgets
//

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your account and preferences',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);

    return SettingsCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          UserAvatar(profile: profile, size: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.offBlack,
                  ),
                ),
                if (profile.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            size: 24,
            color: AppColors.mediumGrey,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.offBlack.withValues(alpha: 0.06),
    );
  }
}
