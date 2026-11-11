# Lextari Data Security

> **Purpose:** How Lextari classifies, stores, transmits, and retains data —
> including personal data — and what privacy guarantees it makes.
> **Related:** [SECURITY.md](SECURITY.md), [THREAT_MODEL.md](THREAT_MODEL.md),
> [BACKEND_SCHEMA.md](BACKEND_SCHEMA.md)

---

## 1. Data Inventory & Classification

| Data | Class | Where stored | At rest | In transit |
|------|-------|--------------|---------|-----------|
| Email address | **PII** | Supabase `auth.users` | Supabase-managed encryption | TLS |
| Password | **Secret** | Supabase (hashed) | Provider hashing (bcrypt/argon) | TLS (never stored client-side) |
| Full name, phone | **PII** | ⏳ target: Supabase profile | Provider-managed | TLS |
| Session JWT | **Sensitive** | Supabase secure storage (device) | OS keychain/keystore | TLS |
| `user_id` ↔ `platform_device_id` mapping | **Internal / linkable** | FastAPI PostgreSQL | Disk (VPS) | internal network |
| `mac_address` | **Device identifier** | FastAPI PostgreSQL | Disk (VPS) | TLS (provisioning) |
| Telemetry (soil, temp, humidity, water) | **Operational** | FavorIoT | FavorIoT-managed | MQTT/TLS |
| GHS score | **Derived** | Computed on demand | not stored | TLS |
| FavorIoT API key | **Secret** | host env, FastAPI memory | env file | internal network |
| FavorIoT device access token | **Secret** | ESP32 flash | flash | MQTT/TLS |
| Error telemetry (Sentry) | **Diagnostic** | Sentry | provider-managed | TLS |

**Guiding rule:** Lextari stores the **minimum** needed. There is no sensor
history in the app database and no analytics profile of the user.

---

## 2. PII Handling

Lextari collects the minimum PII required to identify an account:
**email** (required), and *name + phone* on sign-up (target: stored in Supabase
profile). No location, contacts, or device analytics are collected.

| Principle | Practice |
|-----------|----------|
| Data minimisation | Only email/password required to authenticate |
| Purpose limitation | PII used only for account identity |
| No third-party PII sharing | Only Supabase + Sentry (diagnostics) |
| No PII in logs | Sentry reports carry error context, not credentials |
| No PII to device | ESP32 receives Wi-Fi creds + FavorIoT device identity, never email/name/phone |

---

## 3. Encryption

### In transit
- Client ↔ Supabase: TLS (HTTPS).
- Client ↔ FastAPI: HTTPS (TLS 1.2+).
- ESP32 ↔ FavorIoT: MQTT over TLS (8883).
- FastAPI ↔ FavorIoT / PostgreSQL: HTTPS (outbound) and internal Docker network.

### At rest
- Supabase: encryption at rest + password hashing (provider responsibility).
- FavorIoT: storage-level encryption (provider responsibility).
- PostgreSQL (VPS): full-disk encryption recommended; secrets in host env.
- Device JWT: Supabase SDK persists to OS secure storage (Keychain / Keystore).
- Hive cache (`telemetry_cache`): contains **only** non-sensitive telemetry,
  never tokens or credentials.

---

## 4. Token & Secret Handling

| Item | Rule |
|------|------|
| Supabase JWT | In memory (`ApiClient.token`) + SDK secure storage; never in Hive, never logged |
| FavorIoT API key | Server memory only; never sent to client or device |
| FavorIoT device access token | Device flash only; never sent to the app |
| `service_role` key | Never in the app binary |
| Passwords | Never logged, never cached, transmitted only to Supabase |

On `401`, `ApiClient` **clears the token immediately** before raising
`SessionExpiredFailure` (`api_client.dart:78`).

---

## 5. Data Flow & Isolation

```
User email/password ──TLS──→ Supabase ──hash──→ Supabase auth DB
FastAPI ──verify JWT──→ user_id ──SQL──→ devices(user_id, platform_device_id, mac)
Flutter ──Bearer JWT──→ FastAPI ──apikey──→ FavorIoT ──→ telemetry
```

**Isolation guarantees:**
- A user's JWT maps to exactly their `platform_device_id`(s) — cross-user access
  is rejected at the mapping lookup.
- Telemetry is queried per mapped device; there is no global "list all
  telemetry" endpoint.
- The app stores no copy of another user's data.

---

## 6. Retention

| Data | Retention |
|------|-----------|
| Account (email) | Until account deletion |
| Devices mapping | Until device unlink / account deletion |
| Telemetry | FavorIoT retention policy (configurable) |
| GHS | Not stored (recomputed) |
| Client Hive cache | Overwritten on each fresh reading; clearable on logout |
| Sentry events | Sentry retention window (provider config) |
| Error metrics | In-memory; lost on app restart |

**Recommendation:** on logout, clear the local telemetry cache to avoid residual
data on a shared device.

---

## 7. Privacy Commitments

- No advertising, tracking, or behavioural analytics SDK is present.
- No user data is sold or shared beyond infrastructure providers (Supabase,
  FavorIoT, Sentry).
- Error reports exclude PII by design; no email, token, or password is attached.
- The device learns only its FavorIoT identity, never the account owner's
  identifying information.

---

## 8. Regulatory Considerations

- **PDPA (Malaysia)** — applies to PII handling; email/name/phone must be
  collected lawfully and with consent (the sign-up terms checkbox is the consent
  gate).
- **GDPR-style rights** (good practice) — support account deletion and data
  export on request; document the process.
- **Data residency** — note that Supabase/FavorIoT hosting region determines
  where PII resides.

---

## 9. Data Security Controls Checklist

- [x] No secrets in source control.
- [x] No PII in Sentry reports.
- [x] Tokens cleared on 401.
- [x] Hive cache holds only non-sensitive telemetry.
- [x] Device receives no PII (only FavorIoT device identity).
- [x] Server-side ownership mapping enforced.
- [ ] TLS enforced on all production paths (nginx + MQTT).
- [ ] Hive cache cleared on logout.
- [ ] Database disk encryption + backup encryption documented.
- [ ] Account deletion / data export procedure documented.

---

## 10. Related Documents

| Document | Purpose |
|----------|---------|
| [SECURITY.md](SECURITY.md) | Security posture |
| [AUTH.md](AUTH.md) | Token lifecycle |
| [THREAT_MODEL.md](THREAT_MODEL.md) | Threat analysis |
| [BACKEND_SCHEMA.md](BACKEND_SCHEMA.md) | Data stores |
