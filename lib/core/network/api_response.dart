Map<String, dynamic> asJsonMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const FormatException('Expected JSON object');
}

List<Map<String, dynamic>> asJsonMapList(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map<Object?, Object?>>()
      .map(Map<String, dynamic>.from)
      .toList(growable: false);
}
