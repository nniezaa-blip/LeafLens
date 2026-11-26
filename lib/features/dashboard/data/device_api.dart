import 'package:lextari/core/network/api_client.dart';
import 'package:lextari/core/network/api_endpoints.dart';
import 'package:lextari/features/dashboard/domain/device_summary.dart';

class DeviceApi {
  DeviceApi(this._client);
  final ApiClient _client;

  Future<List<DeviceSummary>> listDevices() async {
    final response = await _client.get(ApiEndpoints.devices);
    final raw = response['devices'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(DeviceSummary.fromJson)
        .toList(growable: false);
  }

  Future<DeviceSummary> linkDevice({
    required String platformDeviceId,
    required String deviceName,
    String deviceType = 'lextari-env',
  }) async {
    final response = await _client.post(
      ApiEndpoints.linkDevice,
      body: <String, dynamic>{
        'platform_device_id': platformDeviceId,
        'device_name': deviceName,
        'device_type': deviceType,
      },
    );
    return DeviceSummary.fromJson(response);
  }
}
