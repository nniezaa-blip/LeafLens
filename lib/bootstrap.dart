import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lextari/core/init/app_init.dart';

class BootstrapResult {
  const BootstrapResult();

  static Future<BootstrapResult> initialize() async {
    await initApp();
    return const BootstrapResult();
  }
}

Future<ProviderContainer> bootstrapContainer() async {
  await BootstrapResult.initialize();
  return ProviderContainer();
}
