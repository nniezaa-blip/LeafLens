# Lextari Technical Requirements

> **Scope:** The concrete technical constraints, stack, versions, and interfaces
> Lextari must satisfy. Product goals live in
> [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md).

---

## 1. System Architecture

Lextari is a **three-tier system with BLE-based device provisioning**:

```
Provisioning (one-time BLE setup)
  Admin ──FavorIoT console──→ device created (device_developer_id + token)
  Flutter ──BLE──→ ESP32   Wi-Fi creds + device_developer_id + access token
  Flutter ──REST──→ FastAPI ──REST──→ FavorIoT (verify device)
                          └──SQL──→ PostgreSQL (user ↔ device mapping)

Steady State
  ESP32 ──MQTT──→ FavorIoT ←──REST──→ FastAPI ──REST/WS──→ Flutter
  FastAPI ──RPC──→ FavorIoT ──MQTT──→ ESP32
```

**Hard rule:** Flutter **never** talks to FavorIoT directly. FastAPI is the
sole gateway and holds the FavorIoT API key server-side. Full detail in
[ARCHITECTURE.md](ARCHITECTURE.md).

---

## 2. Mobile Stack

| Component | Requirement | Source |
|-----------|-------------|--------|
| Flutter SDK | `^3.11.5` | `pubspec.yaml:7` |
| Dart SDK | `^3.11.5` | `pubspec.yaml:6` |
| State management | Riverpod 3.x (`flutter_riverpod ^3.3.2-dev.2`) with `@riverpod` codegen | `pubspec.yaml:17` |
| Routing | `go_router ^17.2.3` + `go_router_builder ^4.3.0` | `pubspec.yaml:20-21` |
| Data models | `freezed_annotation ^3.1.0` + `json_annotation ^4.12.0` | `pubspec.yaml:19,26` |
| Auth SDK | `supabase_flutter ^2.12.4` | `pubspec.yaml:30` |
| HTTP | `http ^1.3.0` | `pubspec.yaml:24` |
| WebSocket | `web_socket_channel ^3.0.1` | `pubspec.yaml:32` |
| Local cache | `hive ^2.2.3` + `hive_flutter ^1.1.0` | `pubspec.yaml:22-23` |
| Connectivity | `connectivity_plus ^7.1.1` | `pubspec.yaml:10` |
| Charts | `fl_chart ^1.2.0` | `pubspec.yaml:14` |
| Notifications | `toastification ^3.2.0` | `pubspec.yaml:31` |
| Error tracking | `sentry_flutter ^9.0.0` | `pubspec.yaml:28` |
| Vector assets | `flutter_svg ^2.3.0` | `pubspec.yaml:18` |
| Shimmer skeleton | `shimmer ^3.0.0` | `pubspec.yaml:29` |
| Push (unwired) | `firebase_core ^4.9.0`, `firebase_messaging ^16.2.2` | `pubspec.yaml:12-13` |
| Lints | `very_good_analysis ^10.2.0` | `pubspec.yaml:41` |
| Font | Lexend variable, embedded (no `google_fonts`) | `pubspec.yaml:49-52` |

### Codegen

`riverpod_generator`, `freezed`, `json_serializable` via `build_runner`.
Generated files (`.g.dart`, `.freezed.dart`) are **committed to git**.

```bash
dart run build_runner build
```

Codegen packages must be upgraded **as a coordinated set** — see
[CONVENTIONS.md](CONVENTIONS.md).

---

## 3. Platform Requirements

| Platform | Tooling | Notes |
|----------|---------|-------|
| Android | Android Studio, Java JDK 17–21 | AGP 8.11.1 — Java 22+ breaks Gradle |
| iOS | macOS + Xcode | CocoaPods removed — uses SPM |
| macOS | Xcode | Needed for iOS builds |
| Windows | Visual Studio (desktop), Android Studio (Android) | |
| Linux | Distro build deps | |
| Web | Chrome | WebSocket URL must be `ws(s)://` |

---

## 4. Backend Requirements

| Component | Requirement |
|-----------|-------------|
| Language | Python 3.10+ |
| Framework | FastAPI (async) |
| Database | PostgreSQL 16 |
| IoT platform | FavorIoT v2 (`https://apiv2.favoriot.com/v2`) |
| Auth provider | Supabase (user accounts + JWT issuance) |
| Deployment | Single Docker Compose stack on one VPS; only nginx public |
| Public ports | `443` (HTTPS/WS → FastAPI) |
| Internal-only | FastAPI, PostgreSQL |
| IoT ingest | FavorIoT cloud (MQTT `mqtt.favoriot.com`), ESP32 connects outbound |

Full networking contract in [NETWORKING.md](NETWORKING.md).

---

## 5. Hardware Requirements

### ESP32 #1 — Environmental (`lextari-env`)
| Component | Telemetry key |
|-----------|---------------|
| Capacitive/resistive soil moisture sensor | `soil_moisture` (%) |
| DHT11/22 temperature | `temperature` (°C) |
| DHT11/22 humidity | `humidity` (%) |
| Water pump (actuator) | — |
| Mist maker (actuator) | — |

### ESP32 #2 — Water Management (`lextari-water`)
| Component | Telemetry key |
|-----------|---------------|
| Ultrasonic HC-SR04 water level | `water_level` (%) |
| Solenoid valve (refill actuator) | — |
| Safety cutoff | — |

- **Publish cadence:** every 5 s, all sensors batched in one MQTT message.
- **Provisioning transport:** BLE (one-time); **telemetry transport:** MQTT.

---

## 6. Telemetry Contract

### Sensor keys (canonical)
Defined in `lib/features/dashboard/domain/sensor_key.dart`:

| Enum | `telemetryKey` | Unit |
|------|----------------|------|
| `soilMoisture` | `soil_moisture` | % |
| `temperature` | `temperature` | °C |
| `humidity` | `humidity` | % |
| `waterLevel` | `water_level` | % |

### Actuator flags (device-reported)
`refill_active`, `pump_active`, `mist_active`, `safety_lockout` (booleans).
FavorIoT has no shared attributes; FastAPI stores the latest values in
`device_state` (see [BACKEND_SCHEMA.md](BACKEND_SCHEMA.md) §2.3).

### RPC methods
`triggerWatering`, `triggerMisting`, `triggerRefill`, `setThreshold`.

---

## 7. Growth Health Score (GHS)

- **Location:** `lib/features/dashboard/domain/growth_health_score.dart`
- **Weights:** soil moisture 50 % / temperature 30 % / humidity 20 %
- **Scoring:** bell curve — 1.0 at range midpoint, 0.0 at/beyond boundaries
- **Partial data:** available sensors re-weighted proportionally
- **Status:** Optimal ≥ 80, Moderate ≥ 65, Caution ≥ 50, Danger ≥ 30, Critical < 30
- **Constraint:** pure Dart, **zero Flutter imports**, fully unit-testable.

See [DOMAIN_MODELS.md](DOMAIN_MODELS.md) for the full algorithm.

---

## 8. Configuration & Secrets

All runtime config is injected at build time via `--dart-define-from-file`:

| Key | Required | Purpose |
|-----|----------|---------|
| `API_URL` | Yes | FastAPI base URL |
| `WS_URL` | Yes | FastAPI WebSocket URL |
| `SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | Supabase public/anon key |
| `SENTRY_DSN` | No | Error tracking (skipped if absent) |

Defined in `lib/core/config/app_config.dart`. Template: `.env.example`.

**Rules:**
- No secret is ever hardcoded in source.
- `.env` is git-ignored; only `.env.example` is committed.
- The Supabase **anon** key is public by design; the `service_role` key never
  ships in the app.
- Server-side secrets (`FAVORIOT_API_KEY`, `POSTGRES_PASSWORD`,
  `FASTAPI_SECRET_KEY`) live only in host environment variables.

---

## 9. Non-Functional Constraints

| Constraint | Target |
|------------|--------|
| Stale threshold | 30 min (`AppConfig.staleThreshold`) |
| Local cache | Hive box `telemetry_cache` |
| First paint | No blocking network I/O |
| WebSocket | Silent auto-reconnect |
| Lint | `very_good_analysis` — zero violations; 80-col line limit |
| Tests | `flutter test` — 98 active + 2 skipped |
| Auth safety | `mounted` checks after every async gap |

---

## 10. Related Documents

| Document | Purpose |
|----------|---------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | System design and data flow |
| [NETWORKING.md](NETWORKING.md) | Docker Compose, ports, secrets |
| [BACKEND_SCHEMA.md](BACKEND_SCHEMA.md) | Database + API contract |
| [DOMAIN_MODELS.md](DOMAIN_MODELS.md) | Models and GHS algorithm |
| [CONVENTIONS.md](CONVENTIONS.md) | Lint, codegen, naming |
