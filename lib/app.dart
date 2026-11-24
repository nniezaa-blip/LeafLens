import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/app/router/app_router.dart';
import 'package:lextari/managers/managers.dart';
import 'package:lextari/ui/theme/app_theme.dart';
import 'package:lextari/ui/ui.dart';

class LextariApp extends ConsumerWidget {
  const LextariApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(AppRouter.provider);
    return PrismApp.router(
      title: 'Lextari',
      theme: AppTheme.prismLight(),
      darkTheme: AppTheme.prismDark(),
      routerConfig: router,
      localizationsDelegates: const [
        DefaultUiLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      builder: (context, child) {
        return buildManagerStack(
          child: child ?? const SizedBox.shrink(),
          managers: [
            (child) => ConnectivityManager(child: child),
            (child) => SessionManager(child: child),
            (child) => AppStateManager(child: child),
            (child) => DashboardManager(child: child),
          ],
        );
      },
    );
  }
}
