import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/app/router/app_router.dart';
import 'package:lextari/features/settings/providers/settings_providers.dart';
import 'package:lextari/managers/managers.dart';
import 'package:lextari/ui/ui.dart';

class LextariApp extends ConsumerWidget {
  const LextariApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(AppRouter.provider);
    final preferences = ref.watch(settingsPreferencesProvider);
    return PrismApp.router(
      title: 'Lextari',
      theme: AppTheme.prismLight(),
      darkTheme: AppTheme.prismDark(),
      themeMode: preferences.darkMode ? ThemeMode.dark : ThemeMode.light,
      liquidGlass: LiquidGlassQuality.standard,
      routerConfig: router,
      localizationsDelegates: const [
        DefaultUiLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      builder: (context, child) {
        final size = MediaQuery.sizeOf(context);
        return ViewScope(
          size: size,
          isMobile: size.width < AppBreakpoints.mobile,
          child: buildManagerStack(
            child: child ?? const SizedBox.shrink(),
            managers: [
              (child) => ConnectivityManager(child: child),
              (child) => SessionManager(child: child),
              (child) => AppStateManager(child: child),
              (child) => DashboardManager(child: child),
            ],
          ),
        );
      },
    );
  }
}
