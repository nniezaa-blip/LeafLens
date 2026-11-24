class SettingsPreferences {
  const SettingsPreferences({
    this.pauseNotifications = false,
    this.darkMode = false,
  });

  final bool pauseNotifications;
  final bool darkMode;

  SettingsPreferences copyWith({bool? pauseNotifications, bool? darkMode}) {
    return SettingsPreferences(
      pauseNotifications: pauseNotifications ?? this.pauseNotifications,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
