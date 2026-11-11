# Lextari Product Requirements

> **Product:** Lextari — AI-Powered Mobile Application for Intelligent Plant Health Monitoring
> **Type:** Final Year Project — Bachelor of Computer Science, IIUM
> **Supervisor:** Ts. Dr. Ahmad Anwar bin Zainuddin
> **Status:** Living document — reflects the shipped v1.0.0 scope plus planned work

---

## 1. Problem Statement

Indoor plant owners lack a simple, at-a-glance way to know whether their plant
is healthy. Existing IoT gardening systems:

- Show raw telemetry (27 °C, 45 % moisture) that non-experts cannot interpret.
- Depend on the owner manually refilling a water tank — plants die during
  holidays or busy weeks.
- Require network setup (IPs, ports, credentials) that overwhelms casual users.

Lextari solves all three: it translates telemetry into a single interpretable
score, refills water autonomously with a safety cutoff, and provisions devices
over BLE with no technical configuration.

---

## 2. Target Users

| Persona | Description | Primary need |
|---------|-------------|--------------|
| **Busy plant owner** | Working adult, 1–3 indoor plants, away 8–12 h/day | "Tell me my plant is fine without opening an app." |
| **Frequent traveller** | Away for days/weeks | Autonomous watering + remote visibility |
| **Plant hobbyist** | Several plants, multiple rooms | Per-device monitoring and historical trends |

---

## 3. Goals & Non-Goals

### Goals
- G1 — Condense multi-sensor telemetry into one **Growth Health Score (GHS)** 0–100.
- G2 — Keep plants alive through **autonomous water-line refill** with safety cutoff.
- G3 — Provision a device in **one BLE flow**, no IP/port/credential entry.
- G4 — Deliver **real-time** readings and control over WebSocket.
- G5 — **Degrade gracefully offline** — show last-known data with a stale marker, never a spinner.

### Non-Goals (v1)
- NG1 — Outdoor / agricultural-scale monitoring.
- NG2 — Direct mobile → FavorIoT communication (FastAPI is the gateway).
- NG3 — Mobile-side long-term analytics (FavorIoT owns the time-series store).
- NG4 — Social / community features.
- NG5 — iOS/Android store release (deliverable is a tested build + thesis).

---

## 4. Functional Requirements

### 4.1 Authentication (FR-AUTH)
| ID | Requirement | Status |
|----|-------------|--------|
| FR-AUTH-1 | User can register with email + password | ✅ Shipped |
| FR-AUTH-2 | User can log in with email + password | ✅ Shipped |
| FR-AUTH-3 | Session persists across app restarts (token refresh) | ✅ Shipped |
| FR-AUTH-4 | User can log out | ✅ Shipped |
| FR-AUTH-5 | Auth errors shown inline with user-friendly messages (never raw provider text) | ✅ Shipped |
| FR-AUTH-6 | Google Sign-In | ⏳ Stub (`UnimplementedError`) |

### 4.2 Device Provisioning (FR-PROV)
| ID | Requirement | Status |
|----|-------------|--------|
| FR-PROV-1 | Discover nearby unprovisioned ESP32 over BLE | ⏳ Firmware/vehicle pending |
| FR-PROV-2 | Send Wi-Fi SSID + password + `device_developer_id` + access token to device over BLE | ⏳ Pending |
| FR-PROV-3 | Device connects to FavorIoT over MQTT and starts publishing telemetry | ⏳ Pending |
| FR-PROV-4 | Admin pre-registers the device in FavorIoT; app links it via `POST /api/v1/devices/link` | ⏳ Pending |
| FR-PROV-5 | User never sees or types any FavorIoT credential | ✅ By design |

### 4.3 Dashboard (FR-DASH)
| ID | Requirement | Status |
|----|-------------|--------|
| FR-DASH-1 | Show a Growth Health Score gauge with status label and colour | ✅ Shipped |
| FR-DASH-2 | Show per-sensor cards (temperature, humidity, soil moisture) | ✅ Shipped |
| FR-DASH-3 | Mark readings older than the stale threshold (30 min) | ✅ Shipped |
| FR-DASH-4 | Show water-system state (pump / mist / refill / safety lockout) | ⏳ Partial |
| FR-DASH-5 | Live updates over WebSocket | ✅ Infrastructure shipped |
| FR-DASH-6 | Each sensor tile is independently error-bounded | ✅ Shipped (`SensorErrorBoundary`) |
| FR-DASH-7 | Offline indicator when connectivity is lost | ✅ Shipped (`OfflineBanner`) |

### 4.4 Actuator Control (FR-CTRL)
| ID | Requirement | Status |
|----|-------------|--------|
| FR-CTRL-1 | Toggle water pump, mist maker, and refill from the dashboard | ✅ Shipped (UI) |
| FR-CTRL-2 | Commands delivered as FavorIoT RPC via FastAPI | ⏳ Backend pending |
| FR-CTRL-3 | Manual refill trigger available as a demo safety valve | ⏳ Pending |
| FR-CTRL-4 | `safety_lockout` surfaced prominently when the cutoff trips | ⏳ Pending |

### 4.5 Statistics (FR-STATS)
| ID | Requirement | Status |
|----|-------------|--------|
| FR-STATS-1 | 30-day trend charts for soil moisture, temperature, humidity | ⏳ Placeholder screen |
| FR-STATS-2 | Data sourced from FavorIoT via FastAPI `/api/telemetry/{key}` | ⏳ Pending |

### 4.6 Settings (FR-SET)
| ID | Requirement | Status |
|----|-------------|--------|
| FR-SET-1 | Species-specific threshold configuration (mutable `HealthConfig`) | ⏳ Placeholder |
| FR-SET-2 | Notification preferences | ⏳ Pending |
| FR-SET-3 | Account management (log out confirmed) | ⏳ Partial |

---

## 5. Non-Functional Requirements

| ID | Category | Requirement |
|----|----------|-------------|
| NFR-1 | Performance | Sensor cards render immediately; no blocking network on first paint |
| NFR-2 | Performance | GHS computation is pure and runs in < 1 ms (unit-tested) |
| NFR-3 | Reliability | WebSocket reconnects silently and automatically |
| NFR-4 | Availability | Stale data shown with an indicator instead of a spinner |
| NFR-5 | Usability | Device onboarded with no IP/port/credential knowledge |
| NFR-6 | Accessibility | Text/UI contrast meets Material 3 guidance; single embedded font |
| NFR-7 | Security | No secrets in source; tokens never logged or sent to the device UI |
| NFR-8 | Portability | Android, iOS, macOS, Windows, Linux, Web build targets |
| NFR-9 | Maintainability | `very_good_analysis` (200+ lint rules) passes clean |
| NFR-10 | Testability | Domain logic is pure Dart with zero Flutter imports |

---

## 6. Success Metrics

- **UAT:** ≥ 80 % of survey respondents rate the GHS as "easy to understand" (thesis, 73 respondents).
- **Functional:** demo runs end-to-end without a manual intervention except initial setup.
- **Reliability:** WebSocket drop during demo recovers without user action.
- **Quality:** `dart analyze` clean; all unit/widget tests pass (98 active tests).

---

## 7. Out of Scope / Future Work

- Google / Apple social sign-in.
- Push notifications for alarms (Firebase Messaging dependency present but unwired).
- Species database with auto-loaded `HealthConfig` presets.
- Multi-tenant FavorIoT accounts (a single account-wide API key is used — see ARCHITECTURE.md).
- Offline write queue for RPC commands issued while disconnected.

---

## 8. Related Documents

| Document | Purpose |
|----------|---------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | System design and data flow |
| [TECHNICAL_REQUIREMENTS.md](TECHNICAL_REQUIREMENTS.md) | Stack, versions, constraints |
| [APP_FLOW.md](APP_FLOW.md) | User journeys |
| [DESIGN_BRIEF.md](DESIGN_BRIEF.md) | Visual and UX direction |
| [BACKEND_SCHEMA.md](BACKEND_SCHEMA.md) | Data model and API contract |
| [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) | Phased delivery plan |
| [AUTH.md](AUTH.md) | Authentication design |
| [SECURITY.md](SECURITY.md) | Security posture |
