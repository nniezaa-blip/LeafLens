# Lextari App Flow

> **Purpose:** End-to-end user journeys and system flows from first launch to
> steady-state monitoring and control.
> **Routes source:** `lib/core/router/app_router.dart`
> **Guard source:** `lib/core/router/auth_guard.dart`

---

## 1. Route Map

| Route | Screen | Widget | Status |
|-------|--------|--------|--------|
| `/splash` | `SplashScreen` | `StatelessWidget` | ✅ |
| `/login` | `LoginPage` | `ConsumerStatefulWidget` | ✅ |
| `/signup` | `SignUpPage` | `ConsumerStatefulWidget` | ✅ |
| `/dashboard` | `DashboardScreen` | shell branch 0 | ✅ |
| `/stats` | `StatsScreen` | shell branch 1 | ⏳ placeholder |
| `/settings` | `SettingsScreen` | shell branch 2 | ⏳ placeholder |

Dashboard, Stats, and Settings are branches of a
`StatefulShellRoute.indexedStack` rendered inside `DashboardShell`.

---

## 2. Cold Start & Launch Flow

```
App launch
  │
  ├─ WidgetsFlutterBinding.ensureInitialized()
  ├─ Init error handlers (FlutterError.onError, PlatformDispatcher.onError)
  ├─ initSentry()          ← skipped if SENTRY_DSN absent
  ├─ initLextariAuth()    ← Supabase.initialize
  ├─ NotificationService.init(rootNavigatorKey)
  ├─ Hive.initFlutter() + openBox('telemetry_cache')
  └─ runApp(ProviderScope(LextariApp))
        │
        └─ GoRouter initialLocation = '/splash'
              │
              └─ AuthGuard.call(...)
                   ├─ session restored from Supabase secure storage?
                   │    ├─ YES → redirect /dashboard
                   │    └─ NO  → redirect /login
```

**Note:** `AuthGuard` checks **both** the reactive `isLoggedIn` stream and the
synchronous `LextariAuth.accessToken`. The `||` ensures cold start works even
before the auth stream emits — Supabase restores the session from secure
storage before the stream fires.

The splash screen itself is decorative. It is never *lingered* on because the
guard immediately resolves `/splash` to `/dashboard` or `/login`.

---

## 3. Authentication Flow

### 3.1 Registration

```
/splash ── "Get Started" ──→ /login ── "Sign up" ──→ /signup
/signup
  ├─ User fills name, email, phone, password
  ├─ Must tick terms checkbox (else inline error below checkbox)
  ├─ Tap "Sign up"
  │    ├─ AuthRepository.register(email, password)
  │    │     └─ LextariAuth.signUp → Supabase
  │    │           ├─ error → AuthFailure (mapped message) → inline red text
  │    │           └─ success → accessToken set on ApiClient
  │    └─ authStateProvider emits token → guard redirects → /dashboard
  └─ Duplicate email → "This email is already registered." inline
```

### 3.2 Login

```
/login
  ├─ Optional: Google Sign-In button → throws UnimplementedError (stub)
  ├─ Email + password form validation
  ├─ Tap "Login"
  │    ├─ AuthRepository.login(email, password)
  │    │     ├─ AuthRetryableFetchException → NetworkFailure
  │    │     ├─ AuthException → AuthFailure(mapped)
  │    │     └─ success → token set on ApiClient
  │    └─ authStateProvider → guard → /dashboard
  └─ Wrong credentials → "Email or password is incorrect." inline
```

### 3.3 Logout

```
/dashboard greeting avatar (tap)
  └─ AuthRepository.logout()
        ├─ LextariAuth.signOut() (clears Supabase session)
        ├─ ApiClient.token = null
        └─ authStateProvider emits null → guard → /login
```

---

## 4. Device Provisioning Flow (BLE Onboarding)

One-time setup. The user never sees an IP address, port, or FavorIoT token.

```
Admin (one-time)                FavorIoT console
───────────────                 ────────────────
(a) create device  ───────────→ device_developer_id + device access token

Flutter app                     ESP32 (base firmware)          Backend / Cloud
─────────────                   ─────────────────────          ───────────────
(1) BLE scan for device
(2) send Wi-Fi SSID + pw
    + device_developer_id
    + access token ──────────→  stores creds
                                (3) connects to Wi-Fi
                                (4) MQTT connect to mqtt.favoriot.com:8883
                                    with access token (username + password)
                                (5) publish to {token}/v2/streams ──→ FavorIoT
                                                                       telemetry begins

(6) POST /api/v1/devices/link
    { device_developer_id, device_name } ─────────────────────→ FastAPI
                                                                   │
                                                       (7) GET /v2/devices/{id} → FavorIoT (verify)
                                                       (8) INSERT user_id ↔ platform_device_id → PostgreSQL
```

**Why it works anywhere:** the ESP32 makes an *outbound* MQTT connection to
FavorIoT's hosted broker — no port forwarding, works on 4G/5G or any network.

**Token ownership:** the FavorIoT device access token is generated in the
console; the admin captures it and the app passes it to the ESP32 over BLE.
FastAPI never mints device tokens.

---

## 5. Steady-State Data Flow

```
ESP32 ──MQTT (every 5s)──→ FavorIoT ←──REST──→ FastAPI ←──REST/WS──→ Flutter
```

When Flutter requests data:
1. FastAPI verifies the Supabase JWT → extracts `user_id`.
2. PostgreSQL lookup → `platform_device_id`(s) for that user.
3. FastAPI queries FavorIoT with its **API key** (server-side only).
4. FastAPI computes GHS and returns data to Flutter (REST snapshot + WS stream).

Flutter data sources:
- **REST** (`ApiClient`) — initial snapshot, history, RPC.
- **WebSocket** (`WsClient`) — live `DashboardUpdate` stream.

---

## 6. Dashboard Flow

```
/dashboard (DashboardShell)
  │
  ├─ Live WS stream of DashboardUpdate:
  │    ├─ .telemetry    → Map<SensorKey, SensorReading>
  │    ├─ .healthScore  → HealthScoreResult (GHS)
  │    └─ .waterStatus  → WaterSystemState
  │
  ├─ Pinned top:
  │    ├─ Greeting header (avatar tap = logout)
  │    ├─ Action switches: Mist / Water / Refill
  │    └─ HealthScoreCard (GHS gauge + status + warning)
  │
  └─ Scrollable:
       ├─ SensorCard Temperature
       ├─ SensorCard Humidity
       └─ SensorCard Soil Moisture
```

### Staleness handling
A reading older than 30 min (`AppConfig.staleThreshold`) is marked stale — the
tile shows a warning icon and renders the value in the error colour. The app
shows **last-known data**, never an indefinite spinner.

### Error isolation
Each sensor tile sits inside a `SensorErrorBoundary`. One failing tile never
takes down the whole dashboard.

---

## 7. Actuator Control Flow (RPC)

```
User toggles an ActionSwitch (Mist / Water / Refill)
  └─ DashboardRepository.sendRpc(method)
        └─ POST /api/rpc  { "method": "triggerWatering" }
              ├─ FastAPI verifies JWT → user_id
              ├─ resolves platform_device_id
              ├─ FavorIoT RPC over API key (POST /v2/rpc)
              │     └─ device offline → downlink missed → logged (NOT an error)
              └─ updated state flows back over WS → waterStatus
```

RPC methods: `triggerWatering`, `triggerMisting`, `triggerRefill`, `setThreshold`.

---

## 8. Offline / Degraded Flow

```
Connectivity lost
  ├─ OfflineBanner shown
  ├─ WS reconnect attempts silently
  ├─ Dashboard keeps last-known readings (Hive `telemetry_cache`)
  └─ Stale indicator appears once readings age past 30 min

Connectivity restored
  ├─ WS reconnects automatically
  ├─ Fresh DashboardUpdate events replace cached values
  └─ OfflineBanner hides
```

---

## 9. Navigation & Guard Rules

```
StatefulShellRoute.indexedStack (DashboardShell)
├── Branch 0: /dashboard → DashboardScreen
├── Branch 1: /stats     → StatsScreen
└── Branch 2: /settings  → SettingsScreen
```

| Current route | Auth state | Redirect |
|---------------|------------|----------|
| `/splash` | any | → `/dashboard` if authenticated, else `/login` |
| not `/login`/`/signup` | unauthenticated | → `/login` |
| `/login` or `/signup` | authenticated | → `/dashboard` |
| other | authenticated | none |

Tab switching uses a horizontal carousel (`snapThreshold = 0.35`, rubber-band
dampening `0.3`). Child routes use `NoTransitionPage` for instant switches.

---

## 10. Error Presentation Decision Tree

```
Error occurs
  ├─ Form submission error (wrong password, duplicate email)
  │     → inline red text; keep form state. No toast/dialog.
  ├─ Operation feedback (RPC, save)
  │     → NotificationService.success / .error (top toast)
  ├─ Unexpected (5xx, network)
  │     → ErrorHandler.handle() — toast + Sentry + metric count
  └─ Blocking/critical (session expired)
        → SessionExpiredFailure → guard redirect; no toast
```

See [ERROR_HANDLING.md](ERROR_HANDLING.md) for the full three-tier system.

---

## 11. Related Documents

| Document | Purpose |
|----------|---------|
| [SCREENS_AND_NAVIGATION.md](SCREENS_AND_NAVIGATION.md) | Per-screen layout detail |
| [ARCHITECTURE.md](ARCHITECTURE.md) | BLE provisioning + data flow |
| [AUTH.md](AUTH.md) | Auth design and token lifecycle |
| [ERROR_HANDLING.md](ERROR_HANDLING.md) | Three-tier error system |
| [BACKEND_SCHEMA.md](BACKEND_SCHEMA.md) | API + data contract |
