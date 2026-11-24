import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lextari/features/auth/domain/user_profile.dart';
import 'package:lextari/features/auth/providers/auth_providers.dart';
import 'package:lextari/features/dashboard/domain/growth_health_score.dart';
import 'package:lextari/features/dashboard/domain/sensor_key.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_view_model.dart';
import 'package:lextari/features/dashboard/presentation/widgets/action_switch.dart';
import 'package:lextari/features/dashboard/presentation/widgets/health_score_card.dart';
import 'package:lextari/features/dashboard/presentation/widgets/sensor_card.dart';
import 'package:lextari/features/stats/presentation/trend_metric.dart';
import 'package:lextari/features/stats/presentation/trend_metric_provider.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/user_avatar.dart';

/// Main dashboard screen showing live sensor readings, action toggles,
/// and the overall Growth Health Score.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _mistOn = false;
  bool _waterOn = false;
  bool _refillOn = false;

  Future<void> _logout() => ref.read(authManagerProvider).logout();

  void _openTrend(TrendMetric metric) {
    ref.read(selectedTrendMetricProvider.notifier).select(metric);
    context.go('/stats');
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProfileProvider);
    final dashboard = ref.watch(dashboardViewModelProvider);
    final telemetry = dashboard.telemetry;
    final temperature = telemetry[SensorKey.temperature]?.value;
    final humidity = telemetry[SensorKey.humidity]?.value;
    final moisture = telemetry[SensorKey.soilMoisture]?.value;
    final waterLevel = dashboard.waterLevelPercent ?? telemetry[SensorKey.waterLevel]?.value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GreetingHeader(profile: profile, onAvatarTap: _logout),
          const SizedBox(height: 16),
          _ActionSwitchesRow(
            mistOn: _mistOn,
            waterOn: _waterOn,
            refillOn: _refillOn || dashboard.refillActive,
            onMistChanged: (value) {
              setState(() => _mistOn = value);
              unawaited(ref.read(dashboardViewModelProvider.notifier).setMist(value));
            },
            onWaterChanged: (value) {
              setState(() => _waterOn = value);
              unawaited(ref.read(dashboardViewModelProvider.notifier).setWater(value));
            },
            onRefillChanged: (value) {
              setState(() => _refillOn = value);
              unawaited(ref.read(dashboardViewModelProvider.notifier).setRefill(value));
            },
          ),
          const SizedBox(height: 16),
          HealthScoreCard(
            score: dashboard.healthScore?.score ?? 0,
            statusText: dashboard.statusText,
            gaugeColor: _healthColor(dashboard.healthScore?.status),
            warningText: dashboard.safetyLockout ? 'SAFETY LOCKOUT' : null,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                SensorCard(
                  sensorName: 'Temperature',
                  value: temperature ?? 0,
                  unit: '°C',
                  unitIcon: AppGlyphs.thermostat,
                  statusText: temperature == null ? 'Waiting for data' : 'Live telemetry',
                  gaugeColor: AppColors.gaugeGreen,
                  onMoreTap: () => _openTrend(TrendMetric.temperature),
                ),
                const SizedBox(height: 12),
                SensorCard(
                  sensorName: 'Humidity',
                  value: humidity ?? 0,
                  unit: 'RH',
                  unitIcon: AppGlyphs.waterDrop,
                  statusText: humidity == null ? 'Waiting for data' : 'Live telemetry',
                  gaugeColor: AppColors.gaugeGreen,
                  onMoreTap: () => _openTrend(TrendMetric.humidity),
                ),
                const SizedBox(height: 12),
                SensorCard(
                  sensorName: 'Soil Moisture',
                  value: moisture ?? 0,
                  unit: '%',
                  unitIcon: AppGlyphs.grass,
                  statusText: moisture == null ? 'Waiting for data' : 'Live telemetry',
                  gaugeColor: AppColors.redAlert,
                  onMoreTap: () => _openTrend(TrendMetric.moisture),
                ),
                const SizedBox(height: 12),
                SensorCard(
                  sensorName: 'Water Level',
                  value: waterLevel ?? 0,
                  unit: '%',
                  unitIcon: AppGlyphs.waves,
                  statusText: waterLevel == null ? 'Waiting for data' : 'Live telemetry',
                  gaugeColor: AppColors.gaugeOrange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _healthColor(HealthStatus? status) {
    return switch (status) {
      HealthStatus.optimal || HealthStatus.moderate => AppColors.gaugeGreen,
      HealthStatus.caution => AppColors.gaugeOrange,
      HealthStatus.danger || HealthStatus.critical || null => AppColors.redAlert,
    };
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.profile, required this.onAvatarTap});

  final UserProfile profile;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(
          profile: profile,
          fontSize: 32,
          onTap: onAvatarTap,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _timeGreeting(),
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                profile.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.offBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }
}

class _ActionSwitchesRow extends StatelessWidget {
  const _ActionSwitchesRow({
    required this.mistOn,
    required this.waterOn,
    required this.refillOn,
    required this.onMistChanged,
    required this.onWaterChanged,
    required this.onRefillChanged,
  });

  final bool mistOn;
  final bool waterOn;
  final bool refillOn;
  final ValueChanged<bool> onMistChanged;
  final ValueChanged<bool> onWaterChanged;
  final ValueChanged<bool> onRefillChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ActionSwitch(
            icon: AppGlyphs.cloud,
            label: 'Mist',
            value: mistOn,
            onChanged: onMistChanged,
          ),
          const SizedBox(width: 10),
          ActionSwitch(
            icon: AppGlyphs.waterDrop,
            label: 'Water',
            value: waterOn,
            onChanged: onWaterChanged,
          ),
          const SizedBox(width: 10),
          ActionSwitch(
            icon: AppGlyphs.autorenew,
            label: 'Refill',
            value: refillOn,
            onChanged: onRefillChanged,
          ),
        ],
      ),
    );
  }
}
