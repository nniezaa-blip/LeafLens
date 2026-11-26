import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lextari/core/config/app_config.dart';
import 'package:lextari/core/router/app_routes.dart';
import 'package:lextari/features/auth/providers/auth_providers.dart';
import 'package:lextari/features/dashboard/domain/growth_health_score.dart';
import 'package:lextari/features/dashboard/domain/sensor_key.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_style.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_view_model.dart';
import 'package:lextari/features/dashboard/presentation/widgets/care_controls_card.dart';
import 'package:lextari/features/dashboard/presentation/widgets/dashboard_card.dart';
import 'package:lextari/features/dashboard/presentation/widgets/environment_card.dart';
import 'package:lextari/features/dashboard/presentation/widgets/health_score_card.dart';
import 'package:lextari/features/dashboard/presentation/widgets/water_system_card.dart';
import 'package:lextari/features/dashboard/providers/dashboard_providers.dart';
import 'package:lextari/features/dashboard/providers/device_providers.dart';
import 'package:lextari/features/stats/presentation/trend_metric.dart';
import 'package:lextari/features/stats/presentation/trend_metric_provider.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/last_update_time_text.dart';
import 'package:lextari/widgets/notifications/app_dialog.dart';
import 'package:lextari/widgets/user_avatar.dart';

/// Main dashboard screen showing plant health, environment readings and care
/// controls.
class DashboardScreen extends ConsumerStatefulWidget {
  /// Creates a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _mistOn = false;
  bool _waterOn = false;
  bool _refillOn = false;

  void _openTrend(TrendMetric metric) {
    ref.read(selectedTrendMetricProvider.notifier).select(metric);
    context.go(AppRoutes.stats);
  }

  void _openSettings() {
    context.go(AppRoutes.settings);
  }

  void _refresh() {
    ref
      ..invalidate(deviceListProvider)
      ..invalidate(dashboardStreamProvider);
  }

  Future<void> _setMist(bool value) async {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _mistOn = value);
    await ref.read(dashboardViewModelProvider.notifier).setMist(enabled: value);
  }

  Future<void> _setWater(bool value) async {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _waterOn = value);
    await ref
        .read(dashboardViewModelProvider.notifier)
        .setWater(enabled: value);
  }

  Future<void> _setRefill(bool value) async {
    if (!value) {
      unawaited(HapticFeedback.selectionClick());
      setState(() => _refillOn = false);
      await ref
          .read(dashboardViewModelProvider.notifier)
          .setRefill(enabled: false);
      return;
    }
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: 'Refill water tank?',
      message:
          'This opens the solenoid valve. The safety cutoff closes it if the tank does not fill in time.',
      confirmLabel: 'Start refill',
      cancelLabel: 'Cancel',
    );
    if (confirmed != true) return;
    unawaited(HapticFeedback.selectionClick());
    setState(() => _refillOn = true);
    await ref
        .read(dashboardViewModelProvider.notifier)
        .setRefill(enabled: true);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProfileProvider);
    final dashboard = ref.watch(dashboardViewModelProvider);
    final telemetry = dashboard.telemetry;
    final health = dashboard.healthScore;
    final waterLevel =
        dashboard.waterLevelPercent ?? telemetry[SensorKey.waterLevel]?.value;

    return Scaffold(
      title: 'Dashboard',
      actions: [
        _LiveStatusChip(lastUpdatedAt: dashboard.lastUpdatedAt),
        IconTap(
          icon: GlyphIcon(
            AppGlyphs.autorenew,
            size: 22,
            color: context.colorScheme.onSurfaceVariant,
          ),
          onPressed: _refresh,
        ),
        UserAvatar(
          profile: profile,
          size: 28,
          fontSize: 14,
          onTap: _openSettings,
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final density = DashboardDensity.of(constraints.biggest);
          final side = dashboardMobileSideOf(constraints.maxWidth);
          final bottom = NavigationDock.insetOf(context) + 24;
          return DashboardDensityScope(
            density: density,
            scale: MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    side,
                    context.contentTopPadding,
                    side,
                    bottom,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HealthScoreCard(
                          score: health?.score ?? 0,
                          statusText: dashboard.statusText,
                          gaugeColor: _healthColor(health?.status),
                          warningText: dashboard.safetyLockout
                              ? 'SAFETY LOCKOUT'
                              : null,
                          soilMoisture:
                              telemetry[SensorKey.soilMoisture]?.value,
                          temperature: telemetry[SensorKey.temperature]?.value,
                          humidity: telemetry[SensorKey.humidity]?.value,
                          lastUpdatedAt: dashboard.lastUpdatedAt,
                        ),
                        const SizedBox(height: 16),
                        CareControlsCard(
                          mistOn: _mistOn,
                          waterOn: _waterOn,
                          refillOn: _refillOn || dashboard.refillActive,
                          onMistChanged: (value) => unawaited(_setMist(value)),
                          onWaterChanged: (value) =>
                              unawaited(_setWater(value)),
                          onRefillChanged: (value) =>
                              unawaited(_setRefill(value)),
                        ),
                        const SizedBox(height: 16),
                        EnvironmentCard(
                          telemetry: telemetry,
                          onOpenTrend: _openTrend,
                        ),
                        const SizedBox(height: 16),
                        WaterSystemCard(
                          waterLevel: waterLevel,
                          refillActive: dashboard.refillActive,
                          safetyLockout: dashboard.safetyLockout,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _healthColor(HealthStatus? status) {
    return switch (status) {
      HealthStatus.optimal || HealthStatus.moderate => AppColors.success,
      HealthStatus.caution => AppColors.warning,
      HealthStatus.danger || HealthStatus.critical || null => AppColors.danger,
    };
  }
}

class _LiveStatusChip extends StatelessWidget {
  const _LiveStatusChip({required this.lastUpdatedAt});

  final DateTime? lastUpdatedAt;

  @override
  Widget build(BuildContext context) {
    final updated = lastUpdatedAt;
    final stale =
        updated == null ||
        DateTime.now().difference(updated) > AppConfig.staleThreshold;
    return DashboardChip(
      label: updated == null ? 'Waiting' : formatLastUpdate(updated),
      tone: stale ? DashboardChipTone.warn : DashboardChipTone.ok,
      dot: !stale,
    );
  }
}
