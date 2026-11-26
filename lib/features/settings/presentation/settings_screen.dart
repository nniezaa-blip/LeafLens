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
    return Scaffold(
      title: 'Settings',
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, context.contentTopPadding, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
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
      ),
    );
  }
}

//
// Private widgets
//

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);
    final scheme = context.colorScheme;
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
                  style: AppTextStyle.title3
                      .of(context, emphasized: true)
                      .copyWith(color: scheme.onSurface),
                ),
                if (profile.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.footnote
                        .of(context)
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          GlyphIcon(
            AppGlyphs.chevronRight,
            size: 24,
            color: scheme.onSurfaceVariant,
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
