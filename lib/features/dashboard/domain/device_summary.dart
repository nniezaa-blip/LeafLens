class DeviceSummary {
  const DeviceSummary({
    required this.platformDeviceId,
    required this.deviceName,
    required this.deviceType,
  });

  factory DeviceSummary.fromJson(Map<String, dynamic> json) {
    return DeviceSummary(
      platformDeviceId: json['platform_device_id']?.toString() ?? '',
      deviceName: json['device_name']?.toString() ?? '',
      deviceType: json['device_type']?.toString() ?? '',
    );
  }

  final String platformDeviceId;
  final String deviceName;
  final String deviceType;
}
