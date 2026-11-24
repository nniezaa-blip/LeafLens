import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/auth/providers/auth_providers.dart';
import 'package:lextari/features/dashboard/data/telemetry_api.dart';
import 'package:lextari/features/dashboard/domain/health_score_dto.dart';
import 'package:lextari/features/dashboard/domain/telemetry_history_point.dart';

final telemetryApiProvider = Provider<TelemetryApi>((ref) {
  return TelemetryApi(ref.watch(apiClientProvider));
});

final telemetryHistoryProvider = // ignore: specify_nonobvious_property_types - Riverpod family type is verbose/unstable across generator versions
    FutureProvider.family<List<TelemetryHistoryPoint>, String>((ref, key) async {
  final session = ref.watch(authSessionProvider).value;
  if (session == null) return const [];
  return ref.watch(telemetryApiProvider).fetchHistory(key);
});

final healthScoreProvider = FutureProvider<HealthScoreDto?>((ref) async {
  final session = ref.watch(authSessionProvider).value;
  if (session == null) return null;
  return ref.watch(telemetryApiProvider).fetchHealthScore();
});
