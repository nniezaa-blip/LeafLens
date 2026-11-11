# Lextari Architecture

> **System:** Lextari — AI-Powered Plant Health Monitoring  
> **Cloud IoT platform:** FavorIoT  
> **Thesis:** Available on request

---

## Flutter Architecture (MVVM)

Lextari follows Google's recommended [MVVM architecture pattern](https://docs.flutter.dev/app-architecture/guide). The app is organized into feature modules with a clear separation of concerns: **Views** (Flutter widgets) → **ViewModels** (Riverpod providers) → **Repositories** → **Services**. The domain layer is omitted for Lextari's scope — domain logic lives directly in providers.

### Directory Structure

```
lib/
├── main.dart                              # Entry point only
├── app.dart                               # LextariApp widget only
├── core/
│   ├── config/app_config.dart
│   ├── errors/failures.dart, error_handler.dart
│   ├── init/sentry_init.dart, lextari_auth_init.dart
│   ├── network/api_client.dart, ws_client.dart
│   ├── router/app_router.dart, auth_guard.dart
│   └── theme/app_theme.dart, app_colors.dart, app_typography.dart
├── features/
│   ├── auth/
│   │   ├── data/auth_repository.dart, lextari_auth.dart
│   │   └── presentation/login_page.dart, signup_page.dart
│   ├── dashboard/
│   │   ├── data/dashboard_providers.dart
│   │   ├── domain/dashboard_update.dart, growth_health_score.dart, sensor_key.dart, sensor_reading.dart, water_system_state.dart
│   │   └── presentation/dashboard_screen.dart
│   └── splash/presentation/splash_screen.dart
└── shared/
    ├── widgets/app_text_field.dart, app_button.dart, background_ellipse.dart, lextari_logo.dart, health_gauge.dart, sensor_tile.dart, status_badge.dart, sensor_error_boundary.dart, offline_banner.dart
    └── notifications/notification_service.dart, lextari_notification_overlay.dart, lextari_toast.dart, app_dialog.dart
```

### Key Principles

- **Feature-first organization:** Each feature (`auth`, `dashboard`, `splash`) contains its own `data/`, `domain/`, and `presentation/` layers.
- **Core is shared infrastructure:** `core/` holds config, error handling, networking, routing, and theming used across all features.
- **Shared is reusable UI:** `shared/` contains widgets and notification utilities that multiple features depend on.
- **main.dart is minimal:** Only bootstraps the app. `app.dart` owns the `LextariApp` widget. Feature screens live in `features/*/presentation/`.
- **Screens folder eliminated:** No top-level `screens/` directory. Each screen belongs to its feature module.

## IoT Platform (FavorIoT)

Lextari uses **FavorIoT** as the cloud IoT middleware: device management, telemetry ingestion (REST / MQTT / CoAP), scalable storage, dashboards, and **RPC (downlink)** for actuator commands.

```
┌─────────────┐   MQTT: {token}/v2/streams   ┌─────────────┐
│   ESP32     │ ───────────────────────────→ │  FavorIoT   │
│  (2 units)  │ ←─── MQTT: {token}/v2/rpc ── │   Platform  │
└─────────────┘                              └──────┬──────┘
                                                    │ REST (apikey header)
                                                    ▼
                                             ┌─────────────┐
                                             │   FastAPI   │ ──→ PostgreSQL
                                             │   Backend   │
                                             └──────┬──────┘
                                                    │ REST / WS
                                                    ▼
                                             ┌─────────────┐
                                             │   Flutter   │
                                             │     App     │
                                             └─────────────┘
```

**Hard rule:** Flutter **never** talks to FavorIoT directly. FastAPI is the sole gateway and holds the account-wide **FavorIoT API key** server-side. Flutter authenticates via Supabase and FastAPI proxies FavorIoT data.

### Credentials

| Credential | Scope | Held by | Used as |
|-----------|-------|---------|---------|
| **FavorIoT API key** | Whole account | FastAPI (server env `FAVORIOT_API_KEY`) | `apikey:` HTTP header |
| **Device access token** | One device | ESP32 flash | MQTT username + password |
| **Supabase JWT** | One app user | Flutter → FastAPI | `Authorization: Bearer` |

FavorIoT's API key is account-wide, so it is the highest-value secret in the
system. It must never be shipped in the app or sent to a device.

---

## Device Provisioning

Devices are **pre-registered in the FavorIoT console** by an admin before they
reach a user. That yields a `device_developer_id` (e.g. `lextari-env@plantuser`)
and a device **access token**. The app then links the device to a user and
delivers Wi-Fi + credentials over BLE.

```
Admin (one-time, FavorIoT console)
  └─ Create device → device_developer_id + device access token

User onboarding
  1. Flutter ──POST /api/v1/devices/link──→ FastAPI   (user JWT)
                  { device_developer_id, device_name }
  2. FastAPI  ──GET /v2/devices/{id}──→ FavorIoT      (verify it exists)
  3. FastAPI  ──INSERT──→ PostgreSQL  (user_id ↔ platform_device_id)
  4. Flutter  ──BLE──→ ESP32   Wi-Fi creds + device_developer_id + access token
  5. ESP32    ──Wi-Fi──→ Home router
  6. ESP32    ──MQTT {token}/v2/streams──→ FavorIoT   (telemetry begins)
```

### Step by Step

| Step | From | To | Data | Protocol |
|------|------|----|------|----------|
| 0 | Admin | FavorIoT | Create device, capture credentials | Console |
| 1 | Flutter | FastAPI | `{ device_developer_id, device_name }` + user JWT | HTTP POST |
| 2 | FastAPI | FavorIoT | Verify device exists | REST (apikey) |
| 3 | FastAPI | PostgreSQL | Save `user_id ↔ platform_device_id` | SQL |
| 4 | Flutter | ESP32 | Wi-Fi SSID + password, `device_developer_id`, access token | BLE |
| 5 | ESP32 | Home router | Wi-Fi connection | Wi-Fi |
| 6 | ESP32 | FavorIoT | Publish telemetry to `{token}/v2/streams` | MQTT |

**Why this works anywhere:** the ESP32 makes an outbound MQTT connection to
FavorIoT's public broker. No port forwarding. Works on 4G/5G, any network.

**Why admin pre-registration:** FavorIoT's device access token is generated and
viewed in the console (there is no documented server-side endpoint to mint one
during a request), so provisioning is split: admin creates the device once,
the app links and configures it.

---

## Steady State Data Flow

```
ESP32 ──MQTT──→ FavorIoT ←──REST (apikey)──→ FastAPI ──REST/WS──→ Flutter
FastAPI ──REST /v2/rpc──→ FavorIoT ──MQTT {token}/v2/rpc──→ ESP32
```

When Flutter requests data:
1. FastAPI verifies the Supabase JWT → extracts `user_id`.
2. PostgreSQL lookup → `platform_device_id`(s) for that user.
3. FastAPI queries FavorIoT (`GET /v2/devices/{id}/streams`) with the account
   API key.
4. FastAPI computes GHS + evaluates alarms, and returns data to Flutter.

Data delivery to Flutter:
- **REST** — initial snapshot, history, RPC.
- **WebSocket** — live `DashboardUpdate` stream from FastAPI. (FavorIoT does
  not document a WebSocket transport, so FastAPI owns the WS fan-out.)

| Layer | Technology | Role |
|-------|-----------|------|
| Hardware | 2× ESP32 + sensors + actuators | Data collection, actuation |
| Cloud | FavorIoT | Telemetry ingest/storage, device registry, dashboards, RPC |
| Auth | Supabase | User accounts, sessions, JWT issuance |
| Backend | FastAPI + PostgreSQL | Device mapping, state, alarms, GHS, FavorIoT proxy |
| Mobile | Flutter | Dashboard UI, offline mode, BLE provisioning |

---

## Data Split

| What | Where | Why |
|------|-------|-----|
| User accounts | Supabase (PostgreSQL) | Registration, login, JWT, session refresh |
| User ↔ device mapping | PostgreSQL (FastAPI) | Which FavorIoT device belongs to which user |
| Telemetry (soil, temp, humidity, water level) | FavorIoT | Time-series storage + MQTT ingestion |
| Actuator state (pump/mist/refill/lockout) | PostgreSQL (FastAPI) | FavorIoT has no shared attributes — FastAPI tracks last state |
| Alarms (low water, critical health) | PostgreSQL (FastAPI) | FavorIoT documents no rule engine — FastAPI evaluates thresholds |
| Growth Health Score | FastAPI (Python) | Reads telemetry from FavorIoT, computes, returns to Flutter |

FastAPI + PostgreSQL is intentionally small:
- Device registration/linking and mapping
- Actuator-state tracking (replaces FavorIoT shared attributes)
- Alarm evaluation (replaces a rule engine)
- FavorIoT proxy + GHS computation

Sensor **time-series** data is never duplicated in PostgreSQL. Only the latest
actuator state and derived alarms are stored.

---

## Multiple Devices Per User

One user can own multiple ESP32 setups (multiple plants, multiple rooms). The mapping table is one-to-many:

```
PostgreSQL — devices table
┌─────────────┬──────────────────────────────┬──────────────┐
│ user_id     │ platform_device_id           │ device_name  │
├─────────────┼──────────────────────────────┼──────────────┤
│ user_001    │ lextari-env@user001          │ Living Room  │
│ user_001    │ lextari-env2@user001         │ Balcony      │
│ user_002    │ lextari-env@user002          │ Kitchen      │
└─────────────┴──────────────────────────────┴──────────────┘
```

FastAPI fetches all `platform_device_id`s for the user, queries each from FavorIoT in parallel, and returns them together.

---

## Scalability

| Layer | Approach |
|-------|----------|
| ESP32 → FavorIoT (MQTT) | FavorIoT handles large concurrent MQTT fleets |
| FavorIoT storage | Purpose-built IoT storage — no custom time-series DB needed |
| FastAPI | Stateless — horizontal scaling behind nginx |
| PostgreSQL | Accounts + mappings + latest state + alarms — row count stays small |
| GHS computation | Stateless pure computation — scales with FastAPI instances |

Real-time telemetry is delivered to Flutter over WebSocket (persistent
connection). FastAPI polls/subscribes FavorIoT and fans out one stream per
device to all subscribed clients.

At higher load: multiple FastAPI instances behind a gateway, async polling with
caching (Redis) for FavorIoT queries, and a single upstream connection per
device fanned out to Flutter clients.

---

## Hardware

### ESP32 #1 — Environmental (lextari-env)

| Component | Purpose |
|-----------|---------|
| Soil moisture sensor | Reads capacitive/resistive moisture % |
| DHT sensor (DHT11/22) | Ambient temperature + humidity |
| Water pump | Irrigation |
| Mist maker | Humidity control |

### ESP32 #2 — Water Management (lextari-water)

| Component | Purpose |
|-----------|---------|
| Ultrasonic sensor (HC-SR04) | Water level in internal reservoir |
| Solenoid valve | External water line refill |
| Safety cutoff | Closes valve if target not reached within timeout |

### Telemetry Keys

| Key | Source | Unit |
|-----|--------|------|
| `soil_moisture` | ESP32 #1 | % |
| `temperature` | ESP32 #1 | °C |
| `humidity` | ESP32 #1 | % |
| `water_level` | ESP32 #2 | % |

### Actuator Flags (device-reported)

FavorIoT has no shared attributes, so the ESP32 reports actuator state as part
of its telemetry payload. FastAPI stores the latest values in `device_state`.

| Key | Type | Description |
|-----|------|-------------|
| `refill_active` | boolean | Solenoid valve status |
| `pump_active` | boolean | Water pump status |
| `mist_active` | boolean | Mist maker status |
| `safety_lockout` | boolean | Safety cutoff triggered |

---

## Authentication

Flutter uses **Supabase** for user authentication. Supabase handles registration, login, session persistence, and token refresh. The rest of the app never imports the Supabase SDK directly — `LextariAuth` wraps it.

| Layer | Who | Token | Flows |
|-------|-----|-------|-------|
| App user | Flutter → Supabase | Supabase JWT (auto-refreshed) | register / login / logout |
| FastAPI proxy | Flutter → FastAPI | Supabase JWT (verified server-side) | Data fetch, RPC commands |
| FavorIoT | FastAPI → FavorIoT | FavorIoT API key (`apikey` header) | Proxy calls, never leaves server |
| ESP32 | ESP32 → FavorIoT | Device access token | MQTT only, provisioned once |

### LextariAuth (Supabase wrapper)

**File:** `lib/features/auth/data/lextari_auth.dart`

Wraps `supabase_flutter` so no other file imports it directly. All methods are static.

```
LextariAuth.init(url, publishableKey)   // Called once from main.dart
LextariAuth.signInWithPassword(...)     // Returns access token
LextariAuth.signUp(...)                 // Returns access token (or null if email confirmation required)
LextariAuth.signOut()                   // Clears session
LextariAuth.onAuthChange                // Stream<AuthState> — emits on login, logout, token refresh
LextariAuth.accessToken                 // Current token, or null
```

### GoRouter Auth Guard

The auth guard is encapsulated in `lib/core/router/auth_guard.dart` and consumed by `AppRouter` (`lib/core/router/app_router.dart`). `AppRouter` is a class that owns the `GoRouter` instance:

```dart
// lib/core/router/app_router.dart
class AppRouter {
  final Ref _ref;
  AppRouter(this._ref);

  GoRouter get router => GoRouter(
        initialLocation: '/splash',
        routes: [/* route definitions */],
        redirect: (context, state) => _ref.read(authGuardProvider)(context, state),
      );
}
```

```dart
// lib/core/router/auth_guard.dart
final authGuardProvider = Provider<GoRouterRedirect>((ref) {
  final auth = ref.watch(authStateProvider);
  return (context, state) {
    final isLoggedIn = auth.value != null;
    final path = state.matchedLocation;
    if (path == '/splash') return null;
    if (!isLoggedIn && path != '/login' && path != '/signup') return '/login';
    if (isLoggedIn && (path == '/login' || path == '/signup')) return '/dashboard';
    return null;
  };
});
```

### Session Lifecycle

1. Login → `AuthRepository.login()` → calls `LextariAuth.signInWithPassword()` → Supabase returns JWT → token set on `ApiClient`
2. `authStateProvider` (StreamProvider) emits new token → GoRouter detects auth → redirects to `/dashboard`
3. App restart → Supabase restores session from its internal storage → `authStateProvider` emits current token automatically
4. Logout → `LextariAuth.signOut()` → stream emits null → GoRouter redirects to `/login`

### Build-time Configuration

Supabase credentials are injected at build time via
`--dart-define-from-file`. Copy `.env.example` to `.env` and fill in
your values:

```bash
cp .env.example .env
flutter run --dart-define-from-file=.env
flutter build apk --dart-define-from-file=.env
```

All four client values (`API_URL`, `WS_URL`, `SUPABASE_URL`,
`SUPABASE_ANON_KEY`) are required — the app won't compile without
them. Same for `SENTRY_DSN` (optional). `FAVORIOT_API_KEY` is **server-side
only** and never appears in the app.

---

## FavorIoT Data Model

### Telemetry ingest

Device → FavorIoT (MQTT): publish to topic `{device-access-token}/v2/streams`:

```json
{
  "device_developer_id": "lextari-env@plantuser",
  "data": {
    "soil_moisture": 45.2,
    "temperature": 27.4,
    "humidity": 58.0,
    "water_level": 72.5
  }
}
```

### Historical read

FastAPI → FavorIoT (REST):

```
GET https://apiv2.favoriot.com/v2/devices/{device_developer_id}/streams?max=1&order=desc
apikey: <FAVORIOT_API_KEY>
```

### Alarms (FastAPI-evaluated)

| Alarm | Condition | Severity |
|-------|-----------|----------|
| HealthCritical | healthScore < 30 | CRITICAL |
| HealthDanger | healthScore < 50 | MAJOR |
| TankLow | water_level < 20 | WARNING |
| TankCritical | water_level < 10 | CRITICAL |
| TempHigh | temperature > 35 | MAJOR |
| MoistureEmpty | soil_moisture < 10 | CRITICAL |

### RPC Commands (downlink)

| Method | Action |
|--------|--------|
| `triggerWatering` | Activates water pump |
| `triggerMisting` | Activates mist maker |
| `triggerRefill` | Opens solenoid valve |
| `setThreshold` | Updates sensor thresholds |

FastAPI sends an RPC via `POST https://apiv2.favoriot.com/v2/rpc`; the device
receives it by subscribing to MQTT topic `{device-access-token}/v2/rpc`:

```json
{
  "params": {
    "device_developer_id": "lextari-water@plantuser",
    "method": "triggerRefill"
  }
}
```

---

## Thesis Document

The full FYP report covers:
- Problem statement and objectives (Chapter 1)
- Literature review — 13 related systems compared (Chapter 2)
- Methodology with use case, activity, sequence, DFD, ERD diagrams (Chapter 3)
- Survey data and UAT results (73 respondents)
- Gantt chart and project schedule

Available on request from the team.
