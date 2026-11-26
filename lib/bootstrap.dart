import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lextari/core/init/app_init.dart';
import 'package:lextari/features/auth/providers/auth_providers.dart';

class BootstrapResult {
  const BootstrapResult();

  static Future<BootstrapResult> initialize() async {
    await initApp();
    return const BootstrapResult();
  }
}

Future<ProviderContainer> bootstrapContainer() async {
  await BootstrapResult.initialize();
  final container = ProviderContainer();
  await container.read(authManagerProvider).ensureRestored();
  return container;
}
