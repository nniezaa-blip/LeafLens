import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:lextari/core/config/app_config.dart';
import 'package:lextari/features/settings/domain/settings_preferences.dart';

final settingsPreferencesProvider =
    NotifierProvider<SettingsPreferencesNotifier, SettingsPreferences>(
      SettingsPreferencesNotifier.new,
    );

class SettingsPreferencesNotifier extends Notifier<SettingsPreferences> {
  static const String _pauseNotificationsKey = 'pauseNotifications';
  static const String _darkModeKey = 'darkMode';

  @override
  SettingsPreferences build() {
    return SettingsPreferences(
      pauseNotifications: _read(_pauseNotificationsKey) ?? false,
      darkMode: _read(_darkModeKey) ?? false,
    );
  }

  void setPauseNotifications({required bool value}) {
    state = state.copyWith(pauseNotifications: value);
    _write(_pauseNotificationsKey, value);
  }

  void setDarkMode({required bool value}) {
    state = state.copyWith(darkMode: value);
    _write(_darkModeKey, value);
  }

  bool? _read(String key) {
    if (!Hive.isBoxOpen(AppConfig.settingsBox)) return null;
    return Hive.box<dynamic>(AppConfig.settingsBox).get(key) as bool?;
  }

  void _write(String key, bool value) {
    if (!Hive.isBoxOpen(AppConfig.settingsBox)) return;
    unawaited(Hive.box<dynamic>(AppConfig.settingsBox).put(key, value));
  }
}
