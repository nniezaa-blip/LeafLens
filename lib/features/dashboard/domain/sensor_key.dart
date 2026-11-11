/// Maps to telemetry keys from the dual-ESP32 setup.
///
/// ESP32 #1 (env): soil_moisture, temperature, humidity
/// ESP32 #2 (water): water_level
///
/// Keys are published to FavorIoT and normalised by the FastAPI gateway
/// before they reach the app.
enum SensorKey {
  /// Soil moisture percentage sensor.
  soilMoisture('soil_moisture', '%'),

  /// Ambient temperature in Celsius.
  temperature('temperature', '°C'),

  /// Ambient humidity percentage.
  humidity('humidity', '%'),

  /// Water tank level percentage.
  waterLevel('water_level', '%');

  const SensorKey(this.telemetryKey, this.unit);

  /// The telemetry key for this sensor (as published to FavorIoT).
  final String telemetryKey;

  /// The display unit for this sensor (e.g. '%', '°C').
  final String unit;

  /// Resolves a telemetry key to the corresponding [SensorKey].
  /// Throws a [StateError] if the key is unknown.
  static SensorKey fromTelemetryKey(String key) =>
      values.firstWhere((k) => k.telemetryKey == key);
}
