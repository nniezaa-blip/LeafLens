import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:lextari/core/config/app_config.dart';

/// Whether the user chose to skip linking a device.
final deviceProvisioningSkippedProvider =
    NotifierProvider<DeviceProvisioningSkippedNotifier, bool>(
      DeviceProvisioningSkippedNotifier.new,
    );

class DeviceProvisioningSkippedNotifier extends Notifier<bool> {
  static const String _key = 'deviceProvisioningSkipped';

  @override
  bool build() {
    if (!Hive.isBoxOpen(AppConfig.settingsBox)) return false;
    return Hive.box<dynamic>(AppConfig.settingsBox).get(_key) as bool? ?? false;
  }

  void skip() => _set(true);

  void reset() => _set(false);

  void _set(bool value) {
    state = value;
    if (!Hive.isBoxOpen(AppConfig.settingsBox)) return;
    unawaited(Hive.box<dynamic>(AppConfig.settingsBox).put(_key, value));
  }
}
