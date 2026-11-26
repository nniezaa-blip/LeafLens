import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/app/loading_provider.dart';
import 'package:lextari/features/auth/domain/auth_actions.dart';
import 'package:lextari/features/auth/providers/auth_providers.dart';
import 'package:lextari/features/dashboard/providers/device_providers.dart';
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
      body: PullToRefresh(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.s20,
            context.contentTopPadding + AppSpacing.s8,
            AppSpacing.s20,
            NavigationDock.insetOf(context) + AppSpacing.s24,
          ),
          children: [
            const _ProfileCard(),
            const SizedBox(height: AppSpacing.s20),
            const _SectionLabel('Preferences'),
            const SizedBox(height: AppSpacing.s8),
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
            const SizedBox(height: AppSpacing.s20),
            const _SectionLabel('General'),
            const SizedBox(height: AppSpacing.s8),
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
                  const _LogoutTile(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    final started = DateTime.now();
    ref.invalidate(deviceListProvider);
    try {
      await ref.read(deviceListProvider.future);
    } on Object {
      // Keeping the current profile and preferences is the safe fallback.
    }
    final elapsed = DateTime.now().difference(started);
    if (elapsed < AppMotionTokens.minRefreshDuration) {
      await Future<void>.delayed(
        AppMotionTokens.minRefreshDuration - elapsed,
      );
    }
  }
}

//
// Private widgets
//

class _LogoutTile extends ConsumerStatefulWidget {
  const _LogoutTile();

  @override
  ConsumerState<_LogoutTile> createState() => _LogoutTileState();
}

class _LogoutTileState extends ConsumerState<_LogoutTile> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    ref.read(appLoadingProvider.notifier).show();
    try {
      await ref.read(authActionsProvider).logout();
      await Future<void>.delayed(AppMotionTokens.card);
    } finally {
      ref.read(appLoadingProvider.notifier).hide();
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsNavTile(
      icon: AppGlyphs.logout,
      label: _isLoggingOut ? 'Logging out...' : 'Log out',
      loading: _isLoggingOut,
      onTap: _logout,
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);
    final scheme = context.colorScheme;
    return SettingsCard(
      padding: const EdgeInsets.all(AppSpacing.s18),
      child: Row(
        children: [
          UserAvatar(profile: profile, size: AppSizes.avatarLarge),
          const SizedBox(width: AppSpacing.s16),
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
                  const SizedBox(height: AppSpacing.s4),
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
          const SizedBox(width: AppSpacing.s8),
          GlyphIcon(
            AppGlyphs.chevronRight,
            size: AppSizes.iconAction,
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
      padding: const EdgeInsets.only(left: AppSpacing.s8),
      child: Semantics(
        header: true,
        headingLevel: 2,
        child: Text(
          text,
          style: AppTypography.labelMedium.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: AppSizes.line, thickness: AppSizes.line);
  }
}
