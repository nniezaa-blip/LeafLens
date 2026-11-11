# Lextari Security

> **Purpose:** The security posture of Lextari — principles, boundaries,
> controls, and known gaps.
> **Related:** [AUTH.md](AUTH.md), [DATA_SECURITY.md](DATA_SECURITY.md),
> [THREAT_MODEL.md](THREAT_MODEL.md), [SECURITY_CHECKLIST.md](SECURITY_CHECKLIST.md)

---

## 1. Security Principles

1. **Least privilege** — the app holds only the Supabase anon key; the FavorIoT
   API key never leaves the server.
2. **Single gateway** — Flutter talks only to Supabase and FastAPI. FavorIoT
   is never directly reachable from the client.
3. **Server-side secrets** — no secret is hardcoded or shipped in the binary.
4. **Fail closed** — unauthenticated or unmapped requests are rejected, not
   served with defaults.
5. **Don't leak internals** — raw provider errors, stack traces, and credential
   material are never surfaced to the user.
6. **Defense in depth** — transport, auth, authorization, and input validation
   are layered, not relied upon individually.

---

## 2. Trust Boundaries

```
┌───────────────────────────────────────────────────────────────────┐
│  UNTRUSTED: internet                                              │
│                                                                    │
│   Flutter app ─────┐        ESP32 ──────┐                         │
│   (user device)    │        (field dev) │                         │
└────────────────────┼────────────────────┼─────────────────────────┘
                     │ HTTPS :443         │ MQTT/TLS :8883
            ┌────────▼────────┐  ┌────────▼─────────┐
            │  nginx (public) │  │  FavorIoT (SaaS) │
            └────────┬────────┘  └────────┬─────────┘
                     │                    │
   ┌─────────────────▼────────────────────▼──────────────────────────┐
   │  TRUSTED: internal Docker network + server env                   │
   │  FastAPI  ──→  PostgreSQL                                        │
   │  FastAPI  ──→  FavorIoT :443  (API key, server-side only)        │
   └──────────────────────────────────────────────────────────────────┘
```

| Boundary | Crossing rule |
|----------|---------------|
| Public → nginx | TLS only (443) |
| nginx → FastAPI | internal, no direct host exposure |
| FastAPI → FavorIoT | outbound HTTPS, API key header |
| FastAPI → PostgreSQL | internal, password auth |
| ESP32 → FavorIoT | outbound MQTT/TLS, device access token |
| App → FastAPI | Bearer Supabase JWT, verified |

---

## 3. Transport Security

| Path | Protocol | Requirement |
|------|----------|-------------|
| Flutter → FastAPI | HTTPS | TLS 1.2+; cleartext only for local dev (`10.0.2.2`) |
| ESP32 → FavorIoT | MQTT | TLS (port 8883) |
| FastAPI → FavorIoT | HTTPS | TLS, API key header |
| FastAPI → PostgreSQL | TCP | Internal Docker network only |

**Rule:** production builds must refuse cleartext. Local dev may use
`http://10.0.2.2:8000` (Android emulator) and `ws://`; these are compile-time
values and must be overridden in release.

---

## 4. Secrets Management

| Secret | Location | Rule |
|--------|----------|------|
| `SUPABASE_URL` | build-time `--dart-define` | not secret |
| `SUPABASE_ANON_KEY` | build-time `--dart-define` | public by design |
| `SENTRY_DSN` | build-time `--dart-define` | optional |
| `FAVORIOT_API_KEY` | host env only | **never** in app/repo |
| `POSTGRES_PASSWORD` | host env only | **never** in app/repo |
| `FASTAPI_SECRET_KEY` | host env only | **never** in app/repo |
| Supabase `service_role` key | server only | **never** in app |

- `.env` is git-ignored; only `.env.example` is committed.
- Source code contains **no** hardcoded keys (`app_config.dart` reads
  `String.fromEnvironment`).
- Production should replace `.env` with a secrets manager (see
  [NETWORKING.md](NETWORKING.md)).

---

## 5. Authentication & Authorization

Full design in [AUTH.md](AUTH.md). Summary:

- **Authentication:** Supabase JWT, verified by FastAPI on every protected call.
- **Authorization:** every device-scoped request must resolve
  `user_id → platform_device_id` via the `devices` mapping. A valid JWT alone is
  not sufficient (prevents IDOR / horizontal privilege escalation).
- **Device credentials:** one FavorIoT device access token per ESP32,
  MQTT-scoped, never exposed to the app.
- **FavorIoT API key:** held only server-side; blast radius is contained by the
  gateway design.

---

## 6. Application-Layer Controls (shipped)

| Control | Implementation |
|---------|----------------|
| Typed failures, no raw errors to user | `failures.dart`, `AuthRepository._mapSupabaseError` |
| Silent 401 handling | `ApiClient._handle` clears token, no toast |
| Sentry gated to non-debug, 5xx/network only | `error_handler.dart`, `!kDebugMode` |
| Per-widget error isolation | `SensorErrorBoundary` |
| Offline degradation (no data leak, no spinner) | `OfflineBanner`, stale indicator |
| `mounted` checks after async gaps | screens (`login_page`, `signup_page`) |
| Build-time config, no hardcoded secrets | `AppConfig` |

---

## 7. Input Validation

| Input | Validation |
|-------|-----------|
| Email | Supabase validation + `validation_failed` mapping |
| Password | Supabase `weak_password` mapping |
| Terms checkbox | Client gate before submit |
| Telemetry keys | `SensorKey.fromTelemetryKey` — unknown keys ignored |
| RPC methods | Must be allow-listed server-side (`triggerWatering`, `triggerMisting`, `triggerRefill`, `setThreshold`) |
| Device params | `platform_device_id`, `device_name` validated server-side (planned) |

**Rule:** the client validates for UX; the server validates for security. Never
trust client input server-side.

---

## 8. Logging & Monitoring

- **Sentry:** 5xx + network errors only, `tracesSampleRate = 0.2`, disabled in
  debug. No PII is attached to reports.
- **Metrics:** in-memory failure counts (`ErrorHandler.errorCounts`) — no
  persistence, no client identifier.
- **Prohibited in logs:** passwords, JWTs, FavorIoT API key, device access
  tokens, `service_role` keys.

---

## 9. Dependency & Supply-Chain Security

- `very_good_analysis` enforces `avoid_print` (no accidental debug logging).
- Generated code is committed — codegen packages upgraded as a coordinated set.
- Run `flutter pub outdated` and an SCA scan before release.
- Pin versions; review lockfiles (`pubspec.lock`, `pnpm-lock.yaml`).

---

## 10. Known Gaps / Roadmap

| Gap | Risk | Planned control |
|-----|------|-----------------|
| Google Sign-In is a stub | none (disabled) | implement or remove |
| MQTT currently dev-cleartext in examples | interception | enforce 8883/TLS in prod |
| No server-side rate limit on `/link` | abuse | per-IP throttle + idempotency |
| No pinned TLS / certificate validation config documented | MITM on hostile networks | document/verify on prod builds |
| Firebase Messaging dependency unwired | unused attack surface | remove if unused |
| No automated security tests | regressions | add authz tests in CI |

---

## 11. Incident Response (baseline)

1. **Credential suspected leaked** → rotate: Supabase keys, `FAVORIOT_API_KEY`,
   device access tokens, `POSTGRES_PASSWORD`.
2. **Device token compromised** → regenerate the access token in the FavorIoT
   console, re-provision the device.
3. **Sentry alert spike** → triage 5xx classes via `ErrorHandler.errorCounts`.
4. **Version control accident** → rotate the committed secret immediately; do
   not rely on history rewrite alone.

---

## 12. Reporting a Vulnerability

Report privately to the Lextari maintainers (FYP team, IIUM). Do not open a
public issue for an unpatched vulnerability. Include reproduction steps and
affected version.

---

## 13. Related Documents

| Document | Purpose |
|----------|---------|
| [AUTH.md](AUTH.md) | Authentication + authorization design |
| [DATA_SECURITY.md](DATA_SECURITY.md) | Data classification + privacy |
| [THREAT_MODEL.md](THREAT_MODEL.md) | STRIDE analysis |
| [SECURITY_CHECKLIST.md](SECURITY_CHECKLIST.md) | Actionable gates |
| [NETWORKING.md](NETWORKING.md) | Ports, network, secrets |
