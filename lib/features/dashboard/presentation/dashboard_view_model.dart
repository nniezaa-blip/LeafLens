import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:lextari/core/config/app_config.dart';
import 'package:lextari/features/auth/providers/auth_providers.dart';
import 'package:lextari/features/dashboard/domain/dashboard_action.dart';
import 'package:lextari/features/dashboard/domain/dashboard_actions.dart';
import 'package:lextari/features/dashboard/domain/dashboard_update.dart';
import 'package:lextari/features/dashboard/domain/growth_health_score.dart';
import 'package:lextari/features/dashboard/domain/health_narrative.dart';
import 'package:lextari/features/dashboard/domain/sensor_key.dart';
import 'package:lextari/features/dashboard/domain/sensor_reading.dart';
import 'package:lextari/features/dashboard/domain/ws_event.dart';
import 'package:lextari/features/dashboard/providers/dashboard_providers.dart';
import 'package:lextari/features/dashboard/providers/telemetry_providers.dart';

class DashboardViewState {
  const DashboardViewState({
    this.telemetry = const <SensorKey, SensorReading>{},
    this.healthScore,
    this.statusText = 'Waiting for telemetry...',
    this.waterLevelPercent,
    this.refillActive = false,
    this.safetyLockout = false,
    this.healthIsStale = false,
    this.lastUpdatedAt,
  });

  final Map<SensorKey, SensorReading> telemetry;
  final HealthScoreResult? healthScore;
  final String statusText;
  final double? waterLevelPercent;
  final bool refillActive;
  final bool safetyLockout;
  final bool healthIsStale;
  final DateTime? lastUpdatedAt;

  DashboardViewState copyWith({
    Map<SensorKey, SensorReading>? telemetry,
    HealthScoreResult? healthScore,
    bool resetHealthScore = false,
    String? statusText,
    double? waterLevelPercent,
    bool? refillActive,
    bool? safetyLockout,
    bool? healthIsStale,
    DateTime? lastUpdatedAt,
  }) {
    return DashboardViewState(
      telemetry: telemetry ?? this.telemetry,
      healthScore: resetHealthScore ? null : healthScore ?? this.healthScore,
      statusText: statusText ?? this.statusText,
      waterLevelPercent: waterLevelPercent ?? this.waterLevelPercent,
      refillActive: refillActive ?? this.refillActive,
      safetyLockout: safetyLockout ?? this.safetyLockout,
      healthIsStale: healthIsStale ?? this.healthIsStale,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

final dashboardViewModelProvider =
    NotifierProvider<DashboardViewModel, DashboardViewState>(
      DashboardViewModel.new,
    );

class DashboardViewModel extends Notifier<DashboardViewState> {
  static const List<SensorKey> _healthSensors = [
    SensorKey.soilMoisture,
    SensorKey.temperature,
    SensorKey.humidity,
  ];

  bool _isSeedingHistory = false;

  @override
  DashboardViewState build() {
    ref
      ..listen(dashboardStreamProvider, (_, next) {
        next.whenData(_handleEvent);
      })
      ..listen(authSessionProvider, (previous, next) {
        final previousUserId = previous?.value?.user.id;
        final nextUserId = next.value?.user.id;
        if (previousUserId == nextUserId) return;
        state = _cachedStateFor(nextUserId);
      });
    final restored = _cachedStateFor(
      ref.read(authSessionProvider).value?.user.id,
    );
    if (_hasMissingReadings(restored.telemetry)) {
      unawaited(Future.microtask(_seedMissingReadingsFromHistory));
    }
    return restored;
  }

  bool _hasMissingReadings(Map<SensorKey, SensorReading> telemetry) {
    return SensorKey.values.any((key) => !telemetry.containsKey(key));
  }

  ({
    HealthScoreResult? score,
    String statusText,
    bool isStale,
  })
  _assessHealth(Map<SensorKey, SensorReading> telemetry) {
    if (telemetry.isEmpty) {
      return (
        score: null,
        statusText: 'Waiting for the first reading.',
        isStale: false,
      );
    }
    final required = [
      for (final key in _healthSensors) telemetry[key],
    ];
    if (required.any((reading) => reading == null)) {
      return (
        score: null,
        statusText: 'Waiting for soil, temperature and humidity readings.',
        isStale: false,
      );
    }
    final score = GrowthHealthScore.compute(telemetry, const HealthConfig());
    final readings = required.whereType<SensorReading>().toList(
      growable: false,
    );
    final oldest = readings.reduce(
      (first, second) =>
          first.recordedAt.isBefore(second.recordedAt) ? first : second,
    );
    if (oldest.isStale) {
      return (
        score: score,
        statusText:
            'Last known ${oldest.ageLabel}. Health cannot be confirmed.',
        isStale: true,
      );
    }
    return (
      score: score,
      statusText: healthNarrative(status: score.status, telemetry: telemetry),
      isStale: false,
    );
  }

  void _applyAssessment(
    ({HealthScoreResult? score, String statusText, bool isStale}) assessment, {
    Map<SensorKey, SensorReading>? telemetry,
    double? waterLevelPercent,
    DateTime? lastUpdatedAt,
  }) {
    state = state.copyWith(
      telemetry: telemetry,
      healthScore: assessment.score,
      resetHealthScore: assessment.score == null,
      statusText: assessment.statusText,
      waterLevelPercent: waterLevelPercent,
      healthIsStale: assessment.isStale,
      lastUpdatedAt: lastUpdatedAt,
    );
  }

  Future<void> _seedMissingReadingsFromHistory() async {
    if (_isSeedingHistory) return;
    final userId = ref.read(authSessionProvider).value?.user.id;
    if (userId == null || userId.isEmpty) return;
    final missing = [
      for (final key in SensorKey.values)
        if (!state.telemetry.containsKey(key)) key,
    ];
    if (missing.isEmpty) return;
    _isSeedingHistory = true;
    try {
      final histories = await Future.wait([
        for (final key in missing)
          ref
              .read(telemetryApiProvider)
              .fetchHistory(key.telemetryKey, days: 90),
      ]);
      if (!ref.mounted) return;
      if (ref.read(authSessionProvider).value?.user.id != userId) return;
      final seeded = <SensorKey, SensorReading>{};
      for (var index = 0; index < missing.length; index++) {
        final points = histories[index];
        if (points.isEmpty) continue;
        final newest = points.last;
        seeded[missing[index]] = SensorReading(
          value: newest.value,
          recordedAt: newest.timestamp,
          unit: missing[index].unit,
        );
      }
      if (seeded.isEmpty) return;
      final nextTelemetry = Map<SensorKey, SensorReading>.from(state.telemetry);
      final applied = <SensorKey, SensorReading>{};
      for (final entry in seeded.entries) {
        if (nextTelemetry.containsKey(entry.key)) continue;
        nextTelemetry[entry.key] = entry.value;
        applied[entry.key] = entry.value;
      }
      if (applied.isEmpty) return;
      _persistTelemetry(applied);
      _applyAssessment(
        _assessHealth(nextTelemetry),
        telemetry: nextTelemetry,
        lastUpdatedAt: _latestRecordedAt(nextTelemetry),
      );
    } on Object {
      return;
    } finally {
      _isSeedingHistory = false;
    }
  }

  DashboardViewState _cachedStateFor(String? userId) {
    final cached = _readCachedTelemetry(userId);
    final assessment = _assessHealth(cached);
    return DashboardViewState(
      telemetry: cached,
      healthScore: assessment.score,
      statusText: assessment.statusText,
      healthIsStale: assessment.isStale,
      lastUpdatedAt: _latestRecordedAt(cached),
    );
  }

  Map<SensorKey, SensorReading> _readCachedTelemetry(String? userId) {
    if (userId == null || userId.isEmpty) {
      return const <SensorKey, SensorReading>{};
    }
    if (!Hive.isBoxOpen(AppConfig.telemetryCacheBox)) {
      return const <SensorKey, SensorReading>{};
    }
    final box = Hive.box<dynamic>(AppConfig.telemetryCacheBox);
    final readings = <SensorKey, SensorReading>{};
    for (final key in SensorKey.values) {
      final raw = box.get(_cacheKey(userId, key.telemetryKey));
      if (raw is! Map) continue;
      final value = (raw['value'] as num?)?.toDouble();
      final recordedAt = raw['recordedAt'] as int?;
      if (value == null || recordedAt == null) continue;
      readings[key] = SensorReading(
        value: value,
        recordedAt: DateTime.fromMillisecondsSinceEpoch(recordedAt),
        unit: key.unit,
        source: raw['source'] as String?,
      );
    }
    return readings;
  }

  String _cacheKey(String userId, String telemetryKey) =>
      'telemetry.$userId.$telemetryKey';

  DateTime? _latestRecordedAt(Map<SensorKey, SensorReading> readings) {
    DateTime? latest;
    for (final reading in readings.values) {
      if (latest == null || reading.recordedAt.isAfter(latest)) {
        latest = reading.recordedAt;
      }
    }
    return latest;
  }

  void _persistTelemetry(Map<SensorKey, SensorReading> readings) {
    final userId = ref.read(authSessionProvider).value?.user.id;
    if (userId == null || userId.isEmpty) return;
    if (!Hive.isBoxOpen(AppConfig.telemetryCacheBox)) return;
    final box = Hive.box<dynamic>(AppConfig.telemetryCacheBox);
    for (final entry in readings.entries) {
      unawaited(
        box.put(_cacheKey(userId, entry.key.telemetryKey), <String, dynamic>{
          'value': entry.value.value,
          'recordedAt': entry.value.recordedAt.millisecondsSinceEpoch,
          'source': entry.value.source,
        }),
      );
    }
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
      case TelemetryUpdate(
        :final soilMoisture,
        :final temperature,
        :final humidity,
        :final waterLevel,
        :final recordedAt,
        :final source,
      ):
        final nextTelemetry = Map<SensorKey, SensorReading>.from(
          state.telemetry,
        );
        final now = DateTime.now();
        void put(SensorKey key, String field, double? value) {
          if (value == null) return;
          final recordedAtMillis = recordedAt?[field];
          nextTelemetry[key] = SensorReading(
            value: value,
            recordedAt: recordedAtMillis == null
                ? now
                : DateTime.fromMillisecondsSinceEpoch(recordedAtMillis),
            unit: key.unit,
            source: source?[field],
          );
        }
        put(SensorKey.soilMoisture, 'soilMoisture', soilMoisture);
        put(SensorKey.temperature, 'temperature', temperature);
        put(SensorKey.humidity, 'humidity', humidity);
        put(SensorKey.waterLevel, 'waterLevel', waterLevel);
        _persistTelemetry(nextTelemetry);
        _applyAssessment(
          _assessHealth(nextTelemetry),
          telemetry: nextTelemetry,
          waterLevelPercent: waterLevel,
          lastUpdatedAt: _latestRecordedAt(nextTelemetry) ?? now,
        );
        if (_hasMissingReadings(nextTelemetry)) {
          unawaited(_seedMissingReadingsFromHistory());
        }
      case GHSUpdate():
        _applyAssessment(_assessHealth(state.telemetry));
      case WaterSystemUpdate(
        :final tankLevelPercent,
        :final refillActive,
        :final safetyLockout,
      ):
        state = state.copyWith(
          waterLevelPercent: tankLevelPercent,
          refillActive: refillActive,
          safetyLockout: safetyLockout,
        );
      case AckUpdate():
        break;
    }
  }

  Future<void> sendAction(DashboardAction action) async {
    final result = await ref.read(dashboardActionsProvider).send(action);
    if (!result.success) {
      state = state.copyWith(statusText: 'Command failed: ${result.method}');
    }
  }

  Future<void> setMist({required bool enabled}) =>
      sendAction(enabled ? DashboardAction.mistOn : DashboardAction.mistOff);
  Future<void> setWater({required bool enabled}) =>
      sendAction(enabled ? DashboardAction.waterOn : DashboardAction.waterOff);
  Future<void> setRefill({required bool enabled}) => sendAction(
    enabled ? DashboardAction.refillOn : DashboardAction.refillOff,
  );
}
