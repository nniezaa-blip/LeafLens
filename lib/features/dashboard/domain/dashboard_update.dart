import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_update.freezed.dart';
part 'dashboard_update.g.dart';

/// Models for data pushed by FastAPI over WebSocket.
@Freezed(unionKey: 'type', fallbackUnion: 'ack')
sealed class DashboardUpdate with _$DashboardUpdate {
  const factory DashboardUpdate.telemetry({
    double? soilMoisture,
    double? temperature,
    double? humidity,
    double? waterLevel,
    Map<String, int>? recordedAt,
    Map<String, String>? source,
  }) = TelemetryUpdate;

  const factory DashboardUpdate.ghs({
    required double score,
    required String status,
    @Default(false) bool stale,
  }) = GHSUpdate;

  const factory DashboardUpdate.waterSystem({
    @JsonKey(name: 'water_level') required double tankLevelPercent,
    @JsonKey(name: 'refill_active') required bool refillActive,
    @JsonKey(name: 'safety_lockout') required bool safetyLockout,
  }) = WaterSystemUpdate;

  const factory DashboardUpdate.ack({
    required String type,
    required bool success,
  }) = AckUpdate;

  factory DashboardUpdate.fromJson(Map<String, dynamic> json) =>
      _$DashboardUpdateFromJson(json);
}
