import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the app is blocked by a full-screen progress overlay.
final appLoadingProvider = NotifierProvider<AppLoadingNotifier, bool>(
  AppLoadingNotifier.new,
);

class AppLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;

  void hide() => state = false;
}
