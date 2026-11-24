import 'package:lextari/features/dashboard/domain/device_summary.dart';
import 'package:lextari/features/dashboard/domain/health_score_dto.dart';
import 'package:lextari/features/dashboard/domain/telemetry_history_point.dart';

class DashboardBootstrap {
  const DashboardBootstrap({
    this.devices = const <DeviceSummary>[],
    this.healthScore,
    this.telemetryHistory = const <String, List<TelemetryHistoryPoint>>{},
  });

  final List<DeviceSummary> devices;
  final HealthScoreDto? healthScore;
  final Map<String, List<TelemetryHistoryPoint>> telemetryHistory;
}
