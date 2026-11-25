import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/auth/domain/auth_actions.dart';
import 'package:lextari/features/auth/providers/auth_providers.dart';
import 'package:lextari/features/settings/presentation/widgets/settings_card.dart';
import 'package:lextari/features/settings/presentation/widgets/settings_nav_tile.dart';
import 'package:lextari/features/settings/presentation/widgets/settings_switch_tile.dart';
import 'package:lextari/features/settings/providers/settings_providers.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/user_avatar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(settingsPreferencesProvider);
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
                        icon: AppGlyphs.notificationsPaused,
                        label: 'Pause notifications',
                        value: prefs.pauseNotifications,
                        onChanged: (value) => ref
                            .read(settingsPreferencesProvider.notifier)
                            .setPauseNotifications(value: value),
                      ),
                      const _CardDivider(),
                      SettingsSwitchTile(
                        icon: AppGlyphs.darkMode,
                        label: 'Dark mode',
                        value: prefs.darkMode,
                        onChanged: (value) => ref
                            .read(settingsPreferencesProvider.notifier)
                            .setDarkMode(value: value),
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
                        icon: AppGlyphs.tune,
                        label: 'General Settings',
                        onTap: () {},
                      ),
                      const _CardDivider(),
                      SettingsNavTile(
                        icon: AppGlyphs.language,
                        label: 'Language',
                        trailingText: 'English',
                        onTap: () {},
                      ),
                      const _CardDivider(),
                      SettingsNavTile(
                        icon: AppGlyphs.description,
                        label: 'Terms of Service',
                        onTap: () {},
                      ),
                      const _CardDivider(),
                      SettingsNavTile(
                        icon: AppGlyphs.privacyTip,
                        label: 'Privacy Policy',
                        onTap: () {},
                      ),
                      const _CardDivider(),
                      SettingsNavTile(
                        icon: AppGlyphs.info,
                        label: 'About Lextari',
                        onTap: () {},
                      ),
                      const _CardDivider(),
                      SettingsNavTile(
                        icon: AppGlyphs.logout,
                        label: 'Log out',
                        onTap: () => ref.read(authActionsProvider).logout(),
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
          const GlyphIcon(
            AppGlyphs.chevronRight,
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
    return const Divider(height: 1, thickness: 1);
  }
}
