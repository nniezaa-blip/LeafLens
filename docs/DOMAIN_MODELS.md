# Lextari Domain Models

All domain types in `lib/features/dashboard/domain/` and `lib/features/auth/domain/`.

---

## SensorKey

**File:** `lib/features/dashboard/domain/sensor_key.dart`

```dart
enum SensorKey {
  soilMoisture('soil_moisture', '%'),
  temperature('temperature', '°C'),
  humidity('humidity', '%'),
  waterLevel('water_level', '%');
}
```

| Value | `telemetryKey` | `unit` | Source |
|-------|----------------|--------|--------|
| `soilMoisture` | `soil_moisture` | `%` | ESP32 #1 |
| `temperature` | `temperature` | `°C` | ESP32 #1 |
| `humidity` | `humidity` | `%` | ESP32 #1 |
| `waterLevel` | `water_level` | `%` | ESP32 #2 |

Static method `SensorKey.fromTelemetryKey(String key)` resolves a FavorIoT telemetry key to the enum value.

---

## SensorReading

**File:** `lib/features/dashboard/domain/sensor_reading.dart`

```dart
class SensorReading {
  final double value;
  final DateTime recordedAt;
  final String unit;

  Duration get age => DateTime.now().difference(recordedAt);
  bool get isStale => age > AppConfig.staleThreshold;   // 30 minutes
  String get ageLabel;                                    // "just now", "5m ago", "2h ago", "3d ago"
}
```

### Factory

```dart
factory SensorReading.fromTelemetryJson(Map<String, dynamic> json, String unit)
```

Parses the normalised telemetry format `{ ts: 1234567890, value: "28.5" }`
produced by the FastAPI gateway from FavorIoT streams.

### Staleness

Readings older than `AppConfig.staleThreshold` (30 minutes) are marked stale. The UI shows a warning icon and renders the value in error colour.

---

## HealthConfig

**File:** `lib/features/dashboard/domain/growth_health_score.dart`

Threshold ranges for GHS computation. Defaults for fragile indoor plants.

```dart
class HealthConfig {
  final double soilMoistureMin;    // 40%
  final double soilMoistureMax;    // 70%
  final double temperatureMin;     // 18°C
  final double temperatureMax;     // 28°C
  final double humidityMin;        // 50%
  final double humidityMax;        // 80%
}
```

User-configurable per species via settings (planned).

---

## HealthScoreResult

**File:** `lib/features/dashboard/domain/growth_health_score.dart`

```dart
class HealthScoreResult {
  final double score;                             // 0–100
  final HealthStatus status;                      // Optimal / Moderate / Caution / Danger / Critical
  final Map<SensorKey, double> componentScores;   // per-sensor 0.0–1.0
  final DateTime computedAt;

  bool get isCritical => score < 30;
  bool get isDanger => score < 50;
  bool get isOptimal => score >= 80;
}
```

---

## GrowthHealthScore

**File:** `lib/features/dashboard/domain/growth_health_score.dart`

**Pure domain logic — zero Flutter imports.** Fully unit-tested (24 tests).

### Algorithm

```dart
static HealthScoreResult compute(
  Map<SensorKey, SensorReading> readings,
  HealthConfig config,
)
```

#### Per-sensor scoring (bell curve)

```
_bellScore(value, min, max):
  if value < min or value > max → 0.0
  mid = (min + max) / 2
  range = (max - min) / 2
  return 1.0 - |value - mid| / range
```

Result: 1.0 at midpoint, 0.0 at/beyond boundaries.

#### Composite score

```
weightedSum = Σ(componentScore × weight) for each available sensor
totalWeight = Σ(weight) for each available sensor
score = (weightedSum / totalWeight) × 100    (0 if no sensors available)
```

Handles partial sensor outages — if one sensor is offline, remaining sensors are re-weighted proportionally.

### Weights

| Sensor | Weight |
|--------|--------|
| Soil moisture | 50% |
| Temperature | 30% |
| Humidity | 20% |

### Status Thresholds

| Score | Status | Colour |
|-------|--------|--------|
| ≥ 80 | Optimal | Green |
| ≥ 65 | Moderate | Light green |
| ≥ 50 | Caution | Yellow |
| ≥ 30 | Danger | Orange |
| < 30 | Critical | Red |

---

## AuthState

**File:** `lib/features/auth/domain/auth_state.dart`

```dart
sealed class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String token;
  final String email;
}
class AuthFailure extends AuthState {
  final String message;
}
```

Used by `authStateProvider` (`StreamProvider<String?>`) — watches Supabase auth state changes and emits the current access token (null if not logged in). The sealed class is currently defined but the provider uses `String?` directly for simplicity. Future iterations may migrate to the sealed class.

---

## DashboardUpdate

**File:** `lib/features/dashboard/domain/dashboard_update.dart`

```dart
@freezed
class DashboardUpdate with _$DashboardUpdate {
  const factory DashboardUpdate.telemetry({
    required Map<SensorKey, SensorReading> readings,
  }) = _TelemetryUpdate;

  const factory DashboardUpdate.healthScore({
    required HealthScoreResult result,
  }) = _HealthScoreUpdate;

  const factory DashboardUpdate.waterStatus({
    required WaterSystemState state,
  }) = _WaterStatusUpdate;

  factory DashboardUpdate.fromJson(Map<String, dynamic> json) =>
      _$DashboardUpdateFromJson(json);
}
```

Sealed union for WebSocket messages from FastAPI. Each variant represents a different type of dashboard update.

---

## WaterSystemState

**File:** `lib/features/dashboard/domain/water_system_state.dart`

```dart
class WaterSystemState {
  final bool pumpActive;
  final bool mistActive;
  final bool refillActive;
  final bool safetyLockout;
}
```

Reflects the actuator flags `pump_active`, `mist_active`, `refill_active`,
`safety_lockout`. FavorIoT has no shared attributes, so FastAPI tracks the
latest values in `device_state` and streams them to Flutter.
