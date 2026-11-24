import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/dashboard/domain/dashboard_bootstrap.dart';
import 'package:lextari/features/dashboard/domain/telemetry_history_point.dart';
import 'package:lextari/features/dashboard/providers/device_providers.dart';
import 'package:lextari/features/dashboard/providers/telemetry_providers.dart';

final dashboardBootstrapProvider = FutureProvider<DashboardBootstrap>((ref) async {
  final devices = await ref.watch(deviceListProvider.future);
  final health = await ref.watch(healthScoreProvider.future);
  final keys = <String>['temperature', 'humidity', 'soil_moisture', 'water_level'];
    final resolved = <String, List<TelemetryHistoryPoint>>{};
  for (final key in keys) {
    final points = await ref.watch(telemetryHistoryProvider(key).future);
    resolved[key] = points;
  }
  return DashboardBootstrap(devices: devices, healthScore: health, telemetryHistory: resolved);
});
