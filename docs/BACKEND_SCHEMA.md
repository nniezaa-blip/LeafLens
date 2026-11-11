# Lextari Backend Schema

> **Scope:** Database schema, FavorIoT entity model, and the FastAPI HTTP /
> WebSocket contract.
> **Sources:** [ARCHITECTURE.md](ARCHITECTURE.md), `lib/core/network/api_client.dart`,
> `lib/features/dashboard/data/dashboard_providers.dart`
>
> **Note:** Items marked ⏳ are the agreed target contract inferred from the
> client code and architecture, pending final backend implementation. Shipped
> client fields are marked ✅.

---

## 1. Data Ownership

| Data | Store | Why |
|------|-------|-----|
| User accounts | Supabase (PostgreSQL) | Registration, login, JWT, session refresh |
| User ↔ device mapping | PostgreSQL (FastAPI) | FastAPI knows which FavorIoT device belongs to which user |
| Telemetry (soil, temp, humidity, water level) | FavorIoT | Time-series storage + MQTT ingestion |
| Actuator state (pump/mist/refill/lockout) | PostgreSQL (FastAPI) | FavorIoT has no shared attributes — FastAPI tracks last state |
| Alarms | PostgreSQL (FastAPI) | FavorIoT documents no rule engine — FastAPI evaluates thresholds |
| GHS | FastAPI (computed) | Reads telemetry, computes, returns — stateless |

**Rule:** Telemetry **time-series** data is never duplicated in the FastAPI
PostgreSQL — only the latest actuator state and derived alarms are stored.

---

## 2. PostgreSQL Schema (FastAPI-owned)

### 2.1 `users` (Supabase-managed)

Supabase owns `auth.users`. FastAPI never writes to it — it only trusts the
user id from the verified JWT.

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | Supabase user id (referenced as `user_id`) |
| `email` | `text` | Managed by Supabase |

### 2.2 `devices` ✅

Mapping table. One user → many devices. `platform_device_id` holds the FavorIoT
`device_developer_id` (a string like `lextari-env@plantuser`), not a UUID.

```sql
CREATE TABLE devices (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id            UUID        NOT NULL,     -- Supabase auth user id
    platform_device_id TEXT        NOT NULL UNIQUE, -- FavorIoT device_developer_id
    mac_address        TEXT        UNIQUE,        -- ESP32 hardware address
    device_name        TEXT        NOT NULL,      -- "Living Room", "Balcony"
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_devices_user_id ON devices (user_id);
```

| Column | Example | Notes |
|--------|---------|-------|
| `user_id` | `user_001` | Owner |
| `platform_device_id` | `lextari-env@plantuser` | FavorIoT device |
| `mac_address` | `AA:BB:CC:DD:EE:FF` | Optional provisioning key |
| `device_name` | `Living Room` | User-facing label |

Example rows:

```
┌─────────────┬──────────────────────────────┬──────────────┐
│ user_id     │ platform_device_id           │ device_name  │
├─────────────┼──────────────────────────────┼──────────────┤
│ user_001    │ lextari-env@user001          │ Living Room  │
│ user_001    │ lextari-env2@user001         │ Balcony      │
│ user_002    │ lextari-env@user002          │ Kitchen      │
└─────────────┴──────────────────────────────┴──────────────┘
```

### 2.3 `device_state` ✅ (replaces FavorIoT shared attributes)

Latest actuator state reported by the device. One row per device.

```sql
CREATE TABLE device_state (
    platform_device_id TEXT PRIMARY KEY,        -- FK → devices.platform_device_id
    pump_active        BOOLEAN NOT NULL DEFAULT false,
    mist_active        BOOLEAN NOT NULL DEFAULT false,
    refill_active      BOOLEAN NOT NULL DEFAULT false,
    safety_lockout     BOOLEAN NOT NULL DEFAULT false,
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 2.4 `alarms` ✅ (replaces a rule engine)

FastAPI evaluates thresholds on each telemetry update and records alarms here.

```sql
CREATE TABLE alarms (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id            UUID        NOT NULL,
    platform_device_id TEXT        NOT NULL,
    type               TEXT        NOT NULL,   -- HealthCritical | TankLow | TempHigh | ...
    severity           TEXT        NOT NULL,   -- CRITICAL | MAJOR | WARNING
    value              NUMERIC,
    triggered_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    resolved_at        TIMESTAMPTZ
);

CREATE INDEX idx_alarms_user_id ON alarms (user_id);
```

### 2.5 `rpc_commands` ⏳ (recommended audit log)

Traceability for actuator commands and the manual-refill demo safety valve.

```sql
CREATE TABLE rpc_commands (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id            UUID        NOT NULL,
    platform_device_id TEXT        NOT NULL,
    method             TEXT        NOT NULL,   -- triggerWatering | triggerMisting | triggerRefill | setThreshold
    params             JSONB,
    status             TEXT        NOT NULL DEFAULT 'pending', -- pending | sent | failed
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_rpc_commands_user_id ON rpc_commands (user_id);
```

### 2.6 Not stored here
- Telemetry time-series — FavorIoT.
- Session tokens — Supabase.

---

## 3. FavorIoT Data Model

### 3.1 Entities
| Entity | Use |
|--------|-----|
| Device (`device_developer_id`) | One per ESP32 setup, pre-created in the console |
| Access token | Per-device MQTT credential (viewable/regenerated in console) |
| Streams | Time-series telemetry records |
| RPC | Downlink commands (platform → device) |

There is no FavorIoT "Customer" or "shared attribute" concept in Lextari.
Ownership is tracked entirely in the FastAPI `devices` table.

### 3.2 Telemetry keys
| Key | Type | Unit | Source |
|-----|------|------|--------|
| `soil_moisture` | number | % | ESP32 #1 |
| `temperature` | number | °C | ESP32 #1 |
| `humidity` | number | % | ESP32 #1 |
| `water_level` | number | % | ESP32 #2 |
| `pump_active` | boolean | — | ESP32 #1 |
| `mist_active` | boolean | — | ESP32 #1 |
| `refill_active` | boolean | — | ESP32 #2 |
| `safety_lockout` | boolean | — | ESP32 #2 |

### 3.3 Alarm rules (FastAPI-evaluated)
| Alarm | Condition | Severity |
|-------|-----------|----------|
| `HealthCritical` | `healthScore < 30` | CRITICAL |
| `HealthDanger` | `healthScore < 50` | MAJOR |
| `TankLow` | `water_level < 20` | WARNING |
| `TankCritical` | `water_level < 10` | CRITICAL |
| `TempHigh` | `temperature > 35` | MAJOR |
| `MoistureEmpty` | `soil_moisture < 10` | CRITICAL |

---

## 4. FavorIoT API Usage (server-side)

Base URL: `https://apiv2.favoriot.com/v2`. Every call sends
`apikey: <FAVORIOT_API_KEY>`.

| Purpose | Call |
|---------|------|
| Verify a device exists | `GET /devices/{device_developer_id}` |
| Read latest/history | `GET /devices/{device_developer_id}/streams?max=N&order=desc` |
| Send actuator command | `POST /rpc` |
| List account devices (admin) | `GET /devices` |

Device-side MQTT:
| Purpose | Topic | Credentials |
|---------|-------|-------------|
| Publish telemetry | `{device-access-token}/v2/streams` | token as username **and** password |
| Receive RPC | `{device-access-token}/v2/rpc` | token as username **and** password |

RPC body (FastAPI → FavorIoT):
```json
{ "params": { "device_developer_id": "lextari-water@plantuser", "method": "triggerRefill" } }
```

---

## 5. FastAPI HTTP Contract

Base URL from `AppConfig.apiUrl`. All authenticated requests carry
`Authorization: Bearer <supabase_jwt>` (`api_client.dart:24-30`).

### 5.1 Device linking

**`POST /api/v1/devices/link`** ⏳ (replaces the old `/register`)
Authenticated (user JWT).

Request:
```json
{ "platform_device_id": "lextari-env@plantuser", "device_name": "Living Room" }
```
Response:
```json
{ "platform_device_id": "lextari-env@plantuser", "device_name": "Living Room" }
```
Side effects: verify device via FavorIoT `GET /devices/{id}` → insert `devices`
row → initialise `device_state` row.

### 5.2 Devices

**`GET /api/devices`** ⏳
Response:
```json
{
  "devices": [
    { "platform_device_id": "lextari-env@plantuser", "device_name": "Living Room" }
  ]
}
```

### 5.3 Telemetry history

**`GET /api/telemetry/{key}?days=30`** ✅ (client call defined)
`key` ∈ `soil_moisture | temperature | humidity | water_level`.

Response ⏳:
```json
{
  "key": "temperature",
  "unit": "°C",
  "points": [
    { "ts": 1735689600000, "value": 27.4 }
  ]
}
```

### 5.4 Health score

**`GET /api/health-score`** ⏳ (snapshot; live via WS)
Response:
```json
{
  "score": 82.5,
  "status": "Optimal",
  "component_scores": { "soil_moisture": 90.0, "temperature": 80.0, "humidity": 75.0 },
  "computed_at": "2026-05-28T10:00:00Z"
}
```

### 5.5 RPC

**`POST /api/rpc`** ✅ (`dashboard_providers.dart:31-33`)
Request:
```json
{ "method": "triggerWatering" }
```
Methods: `triggerWatering`, `triggerMisting`, `triggerRefill`, `setThreshold`.

Response:
```json
{ "sent": true }
```
FastAPI maps the request to a FavorIoT RPC and updates `device_state` +
`rpc_commands`. A device that is offline simply misses the downlink message.

### 5.6 Status codes → client behaviour

| Status | Client failure | Behaviour |
|--------|----------------|-----------|
| 200 / 201 | — | Success |
| 401 | `SessionExpiredFailure` | Clear token → guard redirects to `/login` |
| 4xx | `ApiFailure` | `handleSilent` — screen handles inline |
| 5xx | `ApiFailure` | `handle` — toast + Sentry |
| network | `NetworkFailure` | toast + Sentry |

---

## 6. WebSocket Contract

**Endpoint:** `AppConfig.wsUrl` (e.g. `ws://host/ws`) ✅
**Auth:** token passed as the first message (`ws_client.dart:45-51`).
**Filter:** messages must contain a string `type` field.

Each message maps to a `DashboardUpdate` variant (`dashboard_update.dart`):

```jsonc
// Telemetry - fields are optional; omitted sensors are unknown
{
  "type": "telemetry",
  "soilMoisture": 45.2,
  "temperature": 27.4,
  "humidity": 58.0,
  "waterLevel": 72.5
}

// Health score
{
  "type": "ghs",
  "score": 82.5,
  "status": "Optimal"
}

// Water system state
{
  "type": "waterSystem",
  "water_level": 72.5,
  "refill_active": false,
  "safety_lockout": false
}
```

FastAPI normalises FavorIoT stream records into these message shapes before
sending them to Flutter. See [DOMAIN_MODELS.md](DOMAIN_MODELS.md).

---

## 7. Auth Boundary Summary

| Caller | Credential | Verified by |
|--------|-----------|-------------|
| Flutter → Supabase | email/password | Supabase |
| Flutter → FastAPI | Supabase JWT (Bearer) | FastAPI — extracts `user_id` |
| FastAPI → FavorIoT | FavorIoT API key (`apikey` header) | FavorIoT (never leaves server) |
| ESP32 → FavorIoT | Device access token | FavorIoT (MQTT only) |

---

## 8. Related Documents

| Document | Purpose |
|----------|---------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Full system design |
| [NETWORKING.md](NETWORKING.md) | Ports, Docker network, secrets |
| [AUTH.md](AUTH.md) | Token lifecycle |
| [DATA_SECURITY.md](DATA_SECURITY.md) | Storage + privacy |
| [DOMAIN_MODELS.md](DOMAIN_MODELS.md) | Client model parsing |
