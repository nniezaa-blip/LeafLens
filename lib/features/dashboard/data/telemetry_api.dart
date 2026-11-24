import 'package:lextari/core/network/api_client.dart';
import 'package:lextari/core/network/api_endpoints.dart';
import 'package:lextari/core/network/api_response.dart';
import 'package:lextari/features/dashboard/domain/health_score_dto.dart';
import 'package:lextari/features/dashboard/domain/telemetry_history_point.dart';

class TelemetryApi {
  TelemetryApi(this._client);
  final ApiClient _client;

  Future<List<TelemetryHistoryPoint>> fetchHistory(String key, {int days = 30}) async {
    final response = await _client.get(ApiEndpoints.telemetryHistory(key), params: {'days': '$days'});
    final data = response['data'] ?? response['history'] ?? response[key] ?? response['points'];
    return asJsonMapList(data)
        .map(TelemetryHistoryPoint.fromJson)
        .toList(growable: false);
  }

  Future<HealthScoreDto> fetchHealthScore() async {
    final response = await _client.get(ApiEndpoints.healthScore);
    return HealthScoreDto.fromJson(response);
  }
}
