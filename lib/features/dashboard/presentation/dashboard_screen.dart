import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lextari/core/router/app_routes.dart';
import 'package:lextari/features/auth/providers/auth_providers.dart';
import 'package:lextari/features/dashboard/domain/growth_health_score.dart';
import 'package:lextari/features/dashboard/domain/sensor_key.dart';
import 'package:lextari/features/dashboard/domain/sensor_reading.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_style.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_view_model.dart';
import 'package:lextari/features/dashboard/presentation/widgets/care_controls_card.dart';
import 'package:lextari/features/dashboard/presentation/widgets/dashboard_skeleton.dart';
import 'package:lextari/features/dashboard/presentation/widgets/environment_card.dart';
import 'package:lextari/features/dashboard/presentation/widgets/health_score_card.dart';
import 'package:lextari/features/dashboard/presentation/widgets/water_system_card.dart';
import 'package:lextari/features/dashboard/providers/dashboard_providers.dart';
import 'package:lextari/features/dashboard/providers/device_providers.dart';
import 'package:lextari/features/stats/presentation/trend_metric.dart';
import 'package:lextari/features/stats/presentation/trend_metric_provider.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/notifications/app_dialog.dart';
import 'package:lextari/widgets/profile_badge.dart';

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
  Timer? _loadingTimeout;
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(dashboardViewModelProvider);
    if (state.telemetry.isEmpty && state.healthScore == null) {
      _startLoadingTimeout();
    }
  }

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    super.dispose();
  }

  void _startLoadingTimeout() {
    _loadingTimeout?.cancel();
    _loadingTimeout = Timer(AppMotionTokens.loadingTimeout, () {
      if (!mounted) return;
      setState(() => _timedOut = true);
    });
  }

  void _openTrend(TrendMetric metric) {
    ref.read(selectedTrendMetricProvider.notifier).select(metric);
    context.go(AppRoutes.stats);
  }

  void _openSettings() {
    context.go(AppRoutes.settings);
  }

  Future<void> _refresh() async {
    final started = DateTime.now();
    ref
      ..invalidate(deviceListProvider)
      ..invalidate(dashboardStreamProvider);
    setState(() => _timedOut = false);
    _startLoadingTimeout();
    try {
      await ref.read(deviceListProvider.future);
    } on Object {
      // A failed refresh leaves the current readings on screen.
    }
    final elapsed = DateTime.now().difference(started);
    if (elapsed < AppMotionTokens.minRefreshDuration) {
      await Future<void>.delayed(
        AppMotionTokens.minRefreshDuration - elapsed,
      );
    }
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
    final hasDevice = ref.watch(hasLinkedDeviceProvider);

    return Scaffold(
      title: 'Dashboard',
      actions: [
        ProfileBadge(profile: profile, onTap: _openSettings),
      ],
      body: PullToRefresh(
        onRefresh: _refresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final density = DashboardDensity.of(constraints.biggest);
            final side = dashboardMobileSideOf(constraints.maxWidth);
            final bottom = NavigationDock.insetOf(context) + AppSpacing.s24;
            final noDevice = hasDevice.value == false;
            final waiting = telemetry.isEmpty && health == null;
            final loading = waiting && !_timedOut && !noDevice;
            final empty = waiting && (_timedOut || noDevice);
            return DashboardDensityScope(
              density: density,
              scale: MediaQuery.textScalerOf(context)
                  .scale(1)
                  .clamp(
                    AppMotionTokens.minTextScale,
                    AppMotionTokens.maxTextScale,
                  ),
              child: loading
                  ? _buildSkeletonBody(side, bottom)
                  : empty
                  ? _buildEmptyBody(noDevice: noDevice)
                  : _buildContentBody(
                      side,
                      bottom,
                      dashboard,
                      telemetry,
                      health,
                      waterLevel,
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonBody(double side, double bottom) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            side,
            context.contentTopPadding,
            side,
            bottom,
          ),
          sliver: const SliverToBoxAdapter(child: DashboardSkeleton()),
        ),
      ],
    );
  }

  Widget _buildEmptyBody({required bool noDevice}) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: context.contentTopPadding),
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              illustration: noDevice
                  ? NullStatusIllustration.devices
                  : NullStatusIllustration.data,
              label: noDevice ? 'No device linked' : 'No telemetry yet',
              description: noDevice
                  ? 'Add a FavorIoT device to start receiving readings.'
                  : 'The dashboard will fill when the linked devices publish readings.',
              action: TextButton(
                onPressed: noDevice
                    ? () => unawaited(context.push(AppRoutes.onboarding))
                    : () => unawaited(_refresh()),
                child: Text(noDevice ? 'Add device' : 'Refresh'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentBody(
    double side,
    double bottom,
    DashboardViewState dashboard,
    Map<SensorKey, SensorReading> telemetry,
    HealthScoreResult? health,
    double? waterLevel,
  ) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
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
                  gaugeColor: _healthColor(
                    health?.status,
                    isStale: dashboard.healthIsStale,
                  ),
                  isStale: dashboard.healthIsStale,
                  hasData: health != null,
                  warningText: dashboard.safetyLockout
                      ? 'SAFETY LOCKOUT'
                      : null,
                ),
                const SizedBox(height: AppSpacing.s16),
                CareControlsCard(
                  mistOn: _mistOn,
                  waterOn: _waterOn,
                  refillOn: _refillOn || dashboard.refillActive,
                  onMistChanged: (value) => unawaited(_setMist(value)),
                  onWaterChanged: (value) => unawaited(_setWater(value)),
                  onRefillChanged: (value) => unawaited(_setRefill(value)),
                ),
                const SizedBox(height: AppSpacing.s16),
                EnvironmentCard(
                  telemetry: telemetry,
                  onOpenTrend: _openTrend,
                ),
                const SizedBox(height: AppSpacing.s16),
                WaterSystemCard(
                  reading:
                      telemetry[SensorKey.waterLevel] ??
                      (waterLevel == null
                          ? null
                          : SensorReading(
                              value: waterLevel,
                              recordedAt: DateTime.now(),
                              unit: SensorKey.waterLevel.unit,
                            )),
                  refillActive: dashboard.refillActive,
                  safetyLockout: dashboard.safetyLockout,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _healthColor(HealthStatus? status, {required bool isStale}) {
    if (isStale || status == null) return context.colorScheme.onSurfaceVariant;
    return switch (status) {
      HealthStatus.optimal || HealthStatus.moderate => AppColors.success,
      HealthStatus.caution => AppColors.warning,
      HealthStatus.danger || HealthStatus.critical => AppColors.danger,
    };
  }
}
