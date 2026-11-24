class RpcResult {
  const RpcResult({
    required this.method,
    required this.success,
    this.deviceId,
    this.queued = false,
  });

  factory RpcResult.fromJson(Map<String, dynamic> json) {
    final queued = json['queued'] == true;
    final sent = json['sent'] == true;
    final hasResult = json.containsKey('result');
    return RpcResult(
      method: json['method']?.toString() ?? '',
      deviceId: json['device_id']?.toString(),
      queued: queued,
      success: sent || hasResult || queued,
    );
  }

  final String method;
  final String? deviceId;
  final bool queued;
  final bool success;
}
