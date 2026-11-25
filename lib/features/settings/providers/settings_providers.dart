import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/settings/domain/settings_preferences.dart';

final settingsPreferencesProvider =
    NotifierProvider<SettingsPreferencesNotifier, SettingsPreferences>(
      SettingsPreferencesNotifier.new,
    );

class SettingsPreferencesNotifier extends Notifier<SettingsPreferences> {
  @override
  SettingsPreferences build() => const SettingsPreferences();

  void setPauseNotifications({required bool value}) {
    state = state.copyWith(pauseNotifications: value);
  }

  void setDarkMode({required bool value}) {
    state = state.copyWith(darkMode: value);
  }
}
