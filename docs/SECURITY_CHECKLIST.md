# Lextari Security Checklist

> **Purpose:** Actionable, verifiable security gates for the Lextari app,
> backend, and deployment. Each item references the controlling document.
> **Legend:** ✅ Implemented · ⏳ Required before release · 🔒 Requires infra
> **Related:** [SECURITY.md](SECURITY.md), [AUTH.md](AUTH.md),
> [DATA_SECURITY.md](DATA_SECURITY.md), [THREAT_MODEL.md](THREAT_MODEL.md)

---

## 1. Secrets & Configuration

- [x] No secrets hardcoded in source (`AppConfig` uses `String.fromEnvironment`).
- [x] `.env` git-ignored; `.env.example` committed with placeholders.
- [x] Supabase anon key only in the app (never `service_role`).
- [ ] ⏳ Production secrets provided via a secrets manager, not `.env` files.
- [ ] ⏳ `FAVORIOT_API_KEY`, `POSTGRES_PASSWORD`, `FASTAPI_SECRET_KEY` in host env only.
- [ ] ⏳ Secret rotation runbook documented ([SECURITY.md](SECURITY.md) §11).
- [ ] ⏳ CI secret scanning enabled (detect committed keys).

## 2. Transport

- [x] Local dev may use `http://` / `ws://` (emulator only).
- [ ] ⏳ HTTPS enforced for all Flutter → FastAPI traffic (TLS 1.2+).
- [ ] ⏳ HSTS enabled at nginx.
- [ ] ⏳ MQTT over TLS (8883) enforced in production.
- [ ] ⏳ Release build refuses cleartext endpoints.
- [ ] ⏳ Certificate validation not disabled in release.

## 3. Authentication

- [x] Single auth provider via one wrapper (`LextariAuth`).
- [x] Raw provider errors mapped to friendly text (`AuthRepository`).
- [x] 401 clears token and redirects silently (`ApiClient`).
- [x] Cold-start guard uses synchronous token (`AuthGuard`).
- [ ] ⏳ FastAPI verifies Supabase JWT signature.
- [ ] ⏳ FastAPI rejects expired tokens.
- [ ] ⏳ FastAPI rejects `alg: none` / algorithm confusion.
- [ ] ⏳ Token audience/issuer validated.

## 4. Authorization

- [ ] ⏳ Every device request resolved through `user_id → platform_device_id` mapping.
- [ ] ⏳ Client-supplied `platform_device_id` never trusted without ownership check (IDOR).
- [ ] ⏳ RPC methods restricted to an allow-list
      (`triggerWatering`, `triggerMisting`, `triggerRefill`, `setThreshold`).
- [ ] ⏳ `/link` verifies the device exists in FavorIoT and enforces uniqueness (idempotent).
- [ ] ⏳ Database user runs with least privilege.

## 5. Input & Output Handling

- [x] Telemetry keys validated via `SensorKey.fromTelemetryKey`; unknown keys ignored.
- [ ] ⏳ FastAPI uses parameterised queries (no string-interpolated SQL).
- [ ] ⏳ Request body size limits configured.
- [ ] ⏳ JSON schema validation on all write endpoints.
- [ ] ⏳ Error responses never include stack traces or internals.

## 6. Data Protection

- [x] Hive cache (`telemetry_cache`) stores only non-sensitive telemetry.
- [x] Sentry reports carry no PII / credentials.
- [x] FavorIoT device access token stored only in device flash.
- [x] FavorIoT API key never leaves the server.
- [ ] ⏳ Hive cache cleared on logout.
- [ ] ⏳ PostgreSQL disk + backups encrypted.
- [ ] ⏳ FavorIoT storage encryption policy reviewed.
- [ ] ⏳ Account deletion / data export procedure documented.

## 7. Client App Hardening

- [x] `very_good_analysis` with `avoid_print` (no debug logging leaks).
- [x] Typed `Failure` hierarchy — no raw exceptions to the UI.
- [x] Per-widget error boundaries (`SensorErrorBoundary`).
- [x] `mounted` checks after async gaps.
- [ ] ⏳ Remove or wire the unused `firebase_messaging` dependency.
- [ ] ⏳ Disable debug logging / verbose errors in release builds.

## 8. Platform & Permissions

- [ ] ⏳ Request only required Android permissions (BLE, network).
- [ ] ⏳ iOS `Info.plist` usage strings for BLE + network.
- [ ] ⏳ App Transport Security (iOS) / cleartext config (Android) set for prod.
- [ ] ⏳ No unnecessary `usesCleartextTraffic` in release manifest.

## 9. Infrastructure & Deployment

- [x] Only nginx is public (443).
- [x] FastAPI and PostgreSQL are internal-only.
- [x] FavorIoT console access limited to admins (external SaaS).
- [ ] ⏳ Rate limiting on nginx for `/link` and auth-adjacent routes.
- [ ] ⏳ Container images run as non-root.
- [ ] ⏳ Dependencies pinned and audited (no known critical CVEs).
- [ ] ⏳ Automated backups for PostgreSQL + FavorIoT device config.
- [ ] ⏳ Monitoring/alerting for auth failures and 5xx spikes.

## 10. Logging & Monitoring

- [x] Sentry gated to non-debug, only 5xx + network errors.
- [x] In-memory error metrics (`ErrorHandler.errorCounts`), no identifiers.
- [ ] ⏳ No JWT/password/token values in any log sink.
- [ ] ⏳ Audit log for actuator commands (`rpc_commands`).
- [ ] ⏳ Provisioning events logged.

## 11. Testing & Verification

- [x] `AuthGuard` is a pure function — unit-testable, no Supabase mock needed.
- [x] GHS domain logic unit-tested (pure Dart).
- [ ] ⏳ Authorization tests: user A cannot read/act on user B's device.
- [ ] ⏳ JWT tamper/expiry tests on FastAPI.
- [ ] ⏳ `/link` abuse tests (dup device, missing device, rate limit).
- [ ] ⏳ Dependency/SCA scan in CI.
- [ ] ⏳ `flutter analyze` + `dart format --set-exit-if-changed` gate in CI.

---

## 12. Pre-Release Sign-Off

Before any production/viva build:

- [ ] All ⏳ items in §2–§4 cleared (transport, auth, authz).
- [ ] Redis? No — confirmed not required for current scope.
- [ ] Security checklist reviewed and signed by the team.
- [ ] [THREAT_MODEL.md](THREAT_MODEL.md) highest-priority items mitigated:
      S1, I4/E4, I1, T1/T2, S2/D1.
- [ ] Incident-response contacts documented ([SECURITY.md](SECURITY.md) §11).

---

## 13. Related Documents

| Document | Purpose |
|----------|---------|
| [SECURITY.md](SECURITY.md) | Security posture + controls |
| [AUTH.md](AUTH.md) | Authentication/authorization |
| [DATA_SECURITY.md](DATA_SECURITY.md) | Data classification + privacy |
| [THREAT_MODEL.md](THREAT_MODEL.md) | STRIDE threats and mitigations |
| [NETWORKING.md](NETWORKING.md) | Ports, network, deployment |
