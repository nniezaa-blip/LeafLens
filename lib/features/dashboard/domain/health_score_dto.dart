class HealthScoreDto {
  const HealthScoreDto({
    required this.score,
    required this.status,
    required this.components,
  });

  factory HealthScoreDto.fromJson(Map<String, dynamic> json) {
    final componentsRaw = json['components'];
    final components = <String, double>{};
    if (componentsRaw is Map) {
      for (final entry in componentsRaw.entries) {
        final value = entry.value;
        components[entry.key.toString()] = value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
      }
    }
    return HealthScoreDto(
      score: (json['score'] as num?)?.toDouble() ?? double.tryParse('${json['score']}') ?? 0,
      status: json['status']?.toString() ?? 'unknown',
      components: components,
    );
  }

  final double score;
  final String status;
  final Map<String, double> components;
}
