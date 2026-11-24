class TelemetryHistoryPoint {
  const TelemetryHistoryPoint({
    required this.timestamp,
    required this.value,
  });

  factory TelemetryHistoryPoint.fromJson(Map<String, dynamic> json) {
    final ts = json['ts'] ?? json['timestamp'] ?? json['time'];
    final rawValue = json['value'];
    final timestamp = ts is int
        ? DateTime.fromMillisecondsSinceEpoch(ts)
        : DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
    final value = rawValue is num ? rawValue.toDouble() : double.tryParse(rawValue?.toString() ?? '') ?? 0;
    return TelemetryHistoryPoint(timestamp: timestamp, value: value);
  }

  final DateTime timestamp;
  final double value;
}
