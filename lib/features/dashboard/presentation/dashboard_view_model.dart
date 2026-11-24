import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/dashboard/domain/dashboard_action.dart';
import 'package:lextari/features/dashboard/domain/dashboard_actions.dart';
import 'package:lextari/features/dashboard/domain/dashboard_update.dart';
import 'package:lextari/features/dashboard/domain/growth_health_score.dart';
import 'package:lextari/features/dashboard/domain/sensor_key.dart';
import 'package:lextari/features/dashboard/domain/sensor_reading.dart';
import 'package:lextari/features/dashboard/domain/ws_event.dart';
import 'package:lextari/features/dashboard/providers/dashboard_providers.dart';

class DashboardViewState {
  const DashboardViewState({
    this.telemetry = const <SensorKey, SensorReading>{},
    this.healthScore,
    this.statusText = 'Waiting for telemetry...',
    this.waterLevelPercent,
    this.refillActive = false,
    this.safetyLockout = false,
  });

  final Map<SensorKey, SensorReading> telemetry;
  final HealthScoreResult? healthScore;
  final String statusText;
  final double? waterLevelPercent;
  final bool refillActive;
  final bool safetyLockout;

  DashboardViewState copyWith({
    Map<SensorKey, SensorReading>? telemetry,
    HealthScoreResult? healthScore,
    String? statusText,
    double? waterLevelPercent,
    bool? refillActive,
    bool? safetyLockout,
  }) {
    return DashboardViewState(
      telemetry: telemetry ?? this.telemetry,
      healthScore: healthScore ?? this.healthScore,
      statusText: statusText ?? this.statusText,
      waterLevelPercent: waterLevelPercent ?? this.waterLevelPercent,
      refillActive: refillActive ?? this.refillActive,
      safetyLockout: safetyLockout ?? this.safetyLockout,
    );
  }
}

final dashboardViewModelProvider =
    NotifierProvider<DashboardViewModel, DashboardViewState>(DashboardViewModel.new);

class DashboardViewModel extends Notifier<DashboardViewState> {
  @override
  DashboardViewState build() {
    ref.listen(dashboardStreamProvider, (_, next) {
      next.whenData(_handleEvent);
    });
    return const DashboardViewState();
  }

  void _handleEvent(WsEvent event) {
    switch (event) {
      case WsDashboardUpdate(:final update):
        _applyUpdate(update);
      case WsAuthOk():
      case WsPong():
      case WsSubscribed():
      case WsUnknown():
        break;
      case WsAuthError(:final message):
        state = state.copyWith(statusText: message);
    }
  }

  void _applyUpdate(DashboardUpdate update) {
    switch (update) {
      case TelemetryUpdate(:final soilMoisture, :final temperature, :final humidity, :final waterLevel):
        final nextTelemetry = Map<SensorKey, SensorReading>.from(state.telemetry);
        final now = DateTime.now();
        void put(SensorKey key, double? value) {
          if (value == null) return;
          nextTelemetry[key] = SensorReading(value: value, recordedAt: now, unit: key.unit);
        }
        put(SensorKey.soilMoisture, soilMoisture);
        put(SensorKey.temperature, temperature);
        put(SensorKey.humidity, humidity);
        put(SensorKey.waterLevel, waterLevel);
        final score = GrowthHealthScore.compute(nextTelemetry, const HealthConfig());
        state = state.copyWith(
          telemetry: nextTelemetry,
          healthScore: score,
          statusText: score.status.name,
          waterLevelPercent: waterLevel ?? state.waterLevelPercent,
        );
      case GHSUpdate(:final score, :final status):
        final existing = state.healthScore;
        state = state.copyWith(
          statusText: status,
          healthScore: HealthScoreResult(
            score: score,
            status: existing?.status ?? _statusFromScore(score),
            componentScores: existing?.componentScores ?? const {},
            computedAt: DateTime.now(),
          ),
        );
      case WaterSystemUpdate(:final tankLevelPercent, :final refillActive, :final safetyLockout):
        state = state.copyWith(
          waterLevelPercent: tankLevelPercent,
          refillActive: refillActive,
          safetyLockout: safetyLockout,
        );
      case AckUpdate():
        break;
    }
  }

  HealthStatus _statusFromScore(double score) => switch (score) {
    >= 80 => HealthStatus.optimal,
    >= 65 => HealthStatus.moderate,
    >= 50 => HealthStatus.caution,
    >= 30 => HealthStatus.danger,
    _ => HealthStatus.critical,
  };

  Future<void> sendAction(DashboardAction action) async {
    final result = await ref.read(dashboardActionsProvider).send(action);
    if (!result.success) {
      state = state.copyWith(statusText: 'Command failed: ${result.method}');
    }
  }

  Future<void> setMist(bool enabled) => sendAction(enabled ? DashboardAction.mistOn : DashboardAction.mistOff);
  Future<void> setWater(bool enabled) => sendAction(enabled ? DashboardAction.waterOn : DashboardAction.waterOff);
  Future<void> setRefill(bool enabled) => sendAction(enabled ? DashboardAction.refillOn : DashboardAction.refillOff);
}
