# Lextari Threat Model

> **Method:** STRIDE, applied to the Lextari architecture.
> **Scope:** Mobile app, FastAPI gateway, PostgreSQL, FavorIoT, ESP32 devices,
> and the links between them.
> **Related:** [SECURITY.md](SECURITY.md), [AUTH.md](AUTH.md),
> [DATA_SECURITY.md](DATA_SECURITY.md), [SECURITY_CHECKLIST.md](SECURITY_CHECKLIST.md)

---

## 1. System Composition

```
[ Flutter app ]──HTTPS──┐
                        ├──[ nginx ]──[ FastAPI ]──[ PostgreSQL ]
[ ESP32 devices ]──MQTT──┘                 │
                                           └──HTTPS──[ FavorIoT ]──[ FavorIoT DB ]
                                                   ▲
                                     (MQTT telemetry from ESP32)
```

---

## 2. Assets

| Asset | Why it matters |
|-------|----------------|
| User credentials (email/password) | Account takeover |
| Supabase JWT | Impersonation, access to user's devices |
| FavorIoT API key | Controls **all** devices — highest value |
| FavorIoT device tokens | Spoof telemetry, issue fake actuator commands |
| `devices` mapping | Determines data ownership; tampering = data leak |
| Actuator control (pump/valve/mist) | Physical consequence (flooding, plant damage) |
| Telemetry integrity | Wrong GHS → bad decisions |
| Availability of backend | Loss of monitoring/refill |

---

## 3. Entry Points & Trust Boundaries

| # | Boundary | Exposed to |
|---|----------|-----------|
| B1 | Flutter → public internet | untrusted networks, MITM |
| B2 | User login (Supabase) | credential attacks |
| B3 | Flutter → FastAPI HTTPS | forged/expired tokens |
| B4 | Device link `/api/v1/devices/link` | spoofed / hijacked links |
| B5 | ESP32 → FavorIoT MQTT | token theft from device |
| B6 | FastAPI → FavorIoT | server compromise |
| B7 | Docker internal network | lateral movement if host breached |
| B8 | Developer laptop / CI | secret exfiltration |

---

## 4. STRIDE Analysis

### 4.1 Spoofing

| ID | Threat | Mitigation | Status |
|----|--------|-----------|--------|
| S1 | Attacker forges Supabase JWT to call FastAPI | FastAPI verifies signature + expiry; reject `none` alg | ⏳ required |
| S2 | Attacker links a device they don't own | Link endpoint requires JWT, verifies device exists in FavorIoT, uniqueness, rate limit | ⏳ required |
| S3 | Device stolen → MQTT token reused | Regenerate token in FavorIoT console, re-provision; token per device | ✅ design |
| S4 | Client impersonates another user | Ownership mapping enforced per request | ✅ design |
| S5 | Phishing login page | Supabase-hosted auth, no credential handling client-side beyond TLS | ✅ |

### 4.2 Tampering

| ID | Threat | Mitigation | Status |
|----|--------|-----------|--------|
| T1 | MITM alters API traffic | TLS 1.2+ enforced in production | ⏳ enforce |
| T2 | MITM alters MQTT telemetry | MQTT over TLS (8883) in prod | ⏳ enforce |
| T3 | Client tampers with GHS locally | GHS recomputed server-side; client value is display-only | ✅ design |
| T4 | Attacker writes bogus telemetry | FavorIoT device access token required; per-device scope | ✅ design |
| T5 | DB mapping row altered | DB access internal-only; least-privilege DB user | ⏳ required |
| T6 | Local Hive cache edited | Cache is display-only, re-fetched; never trusted for commands | ✅ design |

### 4.3 Repudiation

| ID | Threat | Mitigation | Status |
|----|--------|-----------|--------|
| R1 | User denies issuing an actuator command | `rpc_commands` audit log (user_id, method, timestamp) | ⏳ planned |
| R2 | Can't attribute a device to a registered owner | `devices` row records `user_id` + `platform_device_id` | ✅ design |
| R3 | No record of provisioning | Log provisioning events server-side | ⏳ planned |

### 4.4 Information Disclosure

| ID | Threat | Mitigation | Status |
|----|--------|-----------|--------|
| I1 | FavorIoT API key leaked to client | Never sent to client; server memory only | ✅ design |
| I2 | JWT/token in logs | `avoid_print`, Sentry excludes credentials | ✅ |
| I3 | Raw Supabase errors exposed | Errors mapped to friendly text | ✅ |
| I4 | Cross-user telemetry access (IDOR) | Every query scoped by `user_id → platform_device_id` | ✅ design |
| I5 | PII exposed in error reports | Sentry carries no PII | ✅ |
| I6 | FavorIoT console exposed | Admin SaaS login (MFA); app users have no access | ✅ |
| I7 | `.env` committed | git-ignored; `.env.example` only | ✅ |
| I8 | Secrets in Docker image layers | Injected at runtime via env, not baked | ✅ |

### 4.5 Denial of Service

| ID | Threat | Mitigation | Status |
|----|--------|-----------|--------|
| D1 | Flood `/link` | Per-IP rate limit + idempotency | ⏳ planned |
| D2 | Flood login | Supabase rate limits | ✅ built-in |
| D3 | WS connection exhaustion | Connection limits, backpressure, per-user cap | ⏳ planned |
| D4 | MQTT platform flood | FavorIoT handles large fleets; monitor | ✅ platform |
| D5 | FastAPI single point of failure | Stateless → horizontal scale behind nginx | ✅ design |
| D6 | VPS outage removes refill automation | Device-side safety cutoff keeps plant safe | ✅ design |

### 4.6 Elevation of Privilege

| ID | Threat | Mitigation | Status |
|----|--------|-----------|--------|
| E1 | Regular user reaches FavorIoT account scope | No client path to FavorIoT; FastAPI mediates | ✅ design |
| E2 | SQL injection in FastAPI | Parameterised queries / ORM | ⏳ required |
| E3 | Command injection into FavorIoT RPC | Allow-list RPC methods server-side | ⏳ required |
| E4 | Mapping tampering grants device access | DB least privilege; ownership re-checked per request | ⏳ required |
| E5 | Device token lifted to impersonate account | Device token scoped to one device; cannot act as account | ✅ design |

---

## 5. Key Threat Deep-Dives

### 5.1 IDOR on device endpoints (I4 / E4)
**Scenario:** authenticated user requests another user's `platform_device_id`.
**Control:** FastAPI must resolve the device *from the JWT's `user_id`*, never
accept a raw `platform_device_id` from the client, or must verify the mapping
before proxying. A valid JWT is insufficient on its own.

### 5.2 `/link` abuse (S2 / D1)
**Scenario:** attacker links arbitrary FavorIoT device ids to pollute the
mapping or hijack a device before its owner.
**Controls:** verify the device exists in FavorIoT, enforce uniqueness
(idempotent), per-IP and global rate limits, and bound total devices per user.

### 5.3 Physical actuator abuse (T4 / E3)
**Scenario:** attacker sends `triggerRefill` to flood a plant.
**Controls:** RPC method allow-list; ownership check; the device-side
`safety_lockout` timeout closes the valve regardless of command source.

### 5.4 FavorIoT API key compromise (I1 / E1)
**Scenario:** `FAVORIOT_API_KEY` leaked → attacker controls all devices/telemetry.
**Controls:** never leaves server, environment-injected, rotate on suspicion,
scope the FavorIoT account to the minimum required, monitor anomalies.

---

## 6. Risk Summary

| Likelihood ↓ / Impact → | Low | Medium | High |
|-------------------------|-----|--------|------|
| **High** | — | D2, I8 | S2, D1 |
| **Medium** | S4 | T1, T2, I4, E2 | S1, I1 |
| **Low** | R3 | S3, T5 | E5, I6 |

Highest-priority items: **S1 (JWT verification)**, **I4/E4 (ownership
enforcement)**, **I1 (FavorIoT API key protection)**, **T1/T2 (TLS
enforcement)**, **S2/D1 (device-link abuse)**.

---

## 7. Out-of-Scope Threats

- Compromise of Supabase or the hosting provider itself.
- Nation-state / physical access to the server.
- Malicious firmware flashed by someone with physical device access.
- Supply-chain compromise of the Flutter/Dart toolchain.

---

## 8. Review Cadence

Re-review this model when: a new endpoint is added, a new data class is stored,
the provisioning flow changes, or TLS/auth configuration changes.

---

## 9. Related Documents

| Document | Purpose |
|----------|---------|
| [SECURITY.md](SECURITY.md) | Controls referenced above |
| [AUTH.md](AUTH.md) | Auth boundary detail |
| [DATA_SECURITY.md](DATA_SECURITY.md) | Data classification |
| [SECURITY_CHECKLIST.md](SECURITY_CHECKLIST.md) | Verification gates |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System + trust layout |
