import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism_ui/prism_ui.dart';

import 'package:lextari/app/router/app_router.dart';
import 'package:lextari/managers/app_manager.dart';
import 'package:lextari/managers/manager_stack.dart';
import 'package:lextari/ui/theme/app_theme.dart';

class LextariApp extends ConsumerWidget {
  const LextariApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(AppRouter.provider);
    return PrismApp.router(
      title: 'Lextari',
      theme: LextariTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        final appChild = child ?? const SizedBox.shrink();
        return buildManagerStack(
          child: appChild,
          managers: [
            (stackChild) => AppManager(child: stackChild),
          ],
        );
      },
    );
  }
}
