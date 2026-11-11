import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lextari/core/theme/app_colors.dart';
import 'package:lextari/core/theme/app_typography.dart';
import 'package:lextari/features/auth/data/auth_session_manager.dart';
import 'package:lextari/features/auth/data/user_profile_provider.dart';
import 'package:lextari/features/auth/domain/user_profile.dart';
import 'package:lextari/features/dashboard/presentation/widgets/action_switch.dart';
import 'package:lextari/features/dashboard/presentation/widgets/health_score_card.dart';
import 'package:lextari/features/dashboard/presentation/widgets/sensor_card.dart';
import 'package:lextari/features/stats/presentation/trend_metric.dart';
import 'package:lextari/features/stats/presentation/trend_metric_provider.dart';
import 'package:lextari/shared/widgets/user_avatar.dart';

/// Main dashboard screen showing live sensor readings, action toggles,
/// and the overall Growth Health Score.
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

  Future<void> _logout() => ref.read(authManagerProvider).logout();

  /// Deep-links to the 30-day trends tab with [metric] preselected.
  void _openTrend(TrendMetric metric) {
    ref.read(selectedTrendMetricProvider.notifier).select(metric);
    context.go('/stats');
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProfileProvider);

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
            refillOn: _refillOn,
            onMistChanged: (v) => setState(() => _mistOn = v),
            onWaterChanged: (v) => setState(() => _waterOn = v),
            onRefillChanged: (v) => setState(() => _refillOn = v),
          ),
          const SizedBox(height: 16),
          const HealthScoreCard(
            score: 62,
            statusText: 'Environment is great but the soil is too wet!',
            gaugeColor: AppColors.gaugeOrange,
            warningText: 'STOP WATERING!',
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                // TODO(danial): Wire to real telemetry data
                SensorCard(
                  sensorName: 'Temperature',
                  value: 26,
                  unit: '°C',
                  unitIcon: Icons.thermostat,
                  statusText: 'Temperature is normal',
                  gaugeColor: AppColors.gaugeGreen,
                  onMoreTap: () => _openTrend(TrendMetric.temperature),
                ),
                const SizedBox(height: 12),
                SensorCard(
                  sensorName: 'Humidity',
                  value: 64,
                  unit: 'RH',
                  unitIcon: Icons.water_drop_outlined,
                  statusText: 'Perfect Environment',
                  gaugeColor: AppColors.gaugeGreen,
                  onMoreTap: () => _openTrend(TrendMetric.humidity),
                ),
                const SizedBox(height: 12),
                SensorCard(
                  sensorName: 'Soil Moisture',
                  value: 90,
                  unit: '%',
                  unitIcon: Icons.grass,
                  statusText: 'Saturated',
                  gaugeColor: AppColors.redAlert,
                  onMoreTap: () => _openTrend(TrendMetric.moisture),
                ),
                const SizedBox(height: 12),
                const SensorCard(
                  sensorName: 'Water Level',
                  value: 45,
                  unit: 'cm',
                  unitIcon: Icons.waves,
                  statusText: 'Water level is low',
                  gaugeColor: AppColors.gaugeOrange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// Private widgets
//

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
            icon: Icons.cloud_outlined,
            label: 'Mist',
            value: mistOn,
            onChanged: onMistChanged,
          ),
          const SizedBox(width: 10),
          ActionSwitch(
            icon: Icons.water_drop_outlined,
            label: 'Water',
            value: waterOn,
            onChanged: onWaterChanged,
          ),
          const SizedBox(width: 10),
          ActionSwitch(
            icon: Icons.autorenew,
            label: 'Refill',
            value: refillOn,
            onChanged: onRefillChanged,
          ),
        ],
      ),
    );
  }
}
