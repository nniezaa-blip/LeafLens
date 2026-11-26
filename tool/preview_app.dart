import 'dart:async';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/auth/data/user_profile_provider.dart';
import 'package:lextari/features/auth/domain/user_profile.dart';
import 'package:lextari/features/dashboard/domain/dashboard_action.dart';
import 'package:lextari/features/dashboard/domain/growth_health_score.dart';
import 'package:lextari/features/dashboard/domain/sensor_key.dart';
import 'package:lextari/features/dashboard/domain/sensor_reading.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_view_model.dart';
import 'package:lextari/ui/ui.dart';

const _showSkeleton = bool.fromEnvironment('PREVIEW_SKELETON');

void main() {
  runApp(
    ProviderScope(
      overrides: [
        currentUserProfileProvider.overrideWithValue(
          const UserProfile(name: 'Aishah', email: 'aishah@example.com'),
        ),
        if (!_showSkeleton)
          dashboardViewModelProvider.overrideWith(
            PreviewDashboardViewModel.new,
          ),
      ],
      child: const _PreviewApp(),
    ),
  );
}

class PreviewDashboardViewModel extends DashboardViewModel {
  @override
  DashboardViewState build() {
    final now = DateTime.now();
    final updated = now.subtract(const Duration(minutes: 2));
    return DashboardViewState(
      telemetry: {
        SensorKey.temperature: SensorReading(
          value: 23.4,
          recordedAt: updated,
          unit: '°C',
        ),
        SensorKey.humidity: SensorReading(
          value: 58,
          recordedAt: updated,
          unit: '%',
        ),
        SensorKey.soilMoisture: SensorReading(
          value: 48,
          recordedAt: updated,
          unit: '%',
        ),
        SensorKey.waterLevel: SensorReading(
          value: 72,
          recordedAt: updated,
          unit: '%',
        ),
      },
      healthScore: HealthScoreResult(
        score: 86,
        status: HealthStatus.optimal,
        componentScores: const {},
        computedAt: now,
      ),
      statusText: 'Soil, temperature and humidity are in the healthy range.',
      waterLevelPercent: 72,
      lastUpdatedAt: updated,
    );
  }

  @override
  Future<void> sendAction(DashboardAction action) async {}
}

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) {
    return PrismApp(
      title: 'Lextari preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.prismLight(),
      darkTheme: AppTheme.prismDark(),
      liquidGlass: LiquidGlassQuality.standard,
      localizationsDelegates: const [
        DefaultUiLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      builder: (context, child) {
        final size = MediaQuery.sizeOf(context);
        return ViewScope(
          size: size,
          isMobile: size.width < 600,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const _PreviewShell(),
    );
  }
}

class _PreviewShell extends StatefulWidget {
  const _PreviewShell();

  @override
  State<_PreviewShell> createState() => _PreviewShellState();
}

class _PreviewShellState extends State<_PreviewShell> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    unawaited(_scrollToBottom());
  }

  Future<void> _scrollToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted || !_controller.hasClients) return;
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = NavigationDock.insetOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        const BotanicalBackground(),
        BottomInsetScope(
          inset: inset,
          child: PrimaryScrollController(
            controller: _controller,
            child: const DashboardScreen(),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: NavigationDock(
            destinations: const [
              NavigationDockDestination(
                glyph: AppGlyphs.sprout,
                label: 'Home',
              ),
              NavigationDockDestination(
                glyph: AppGlyphs.barChart,
                label: 'Stats',
              ),
              NavigationDockDestination(
                glyph: AppGlyphs.settings,
                label: 'Settings',
              ),
            ],
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      ],
    );
  }
}
