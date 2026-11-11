# Lextari Implementation Plan

> **Purpose:** The phased delivery plan for Lextari — what is shipped, what is
> in progress, and what remains.
> **Status legend:** ✅ Done · 🚧 In progress · ⏳ Pending · 🔒 Blocked (external)

---

## 1. Deliverables

| Deliverable | Repo | Status |
|-------------|------|--------|
| Flutter mobile app | this repo | ✅ Core shipped |
| FastAPI backend | separate | ⏳ |
| ESP32 firmware | separate | ⏳ |
| Thesis report | on request | ✅ Submitted lineage |
| UAT results (73 respondents) | thesis | ✅ |

---

## 2. Phase Overview

| Phase | Theme | Status |
|-------|-------|--------|
| 0 | Project setup & tooling | ✅ |
| 1 | Design system & theming | ✅ |
| 2 | Authentication | ✅ |
| 3 | Domain logic (GHS) | ✅ |
| 4 | Dashboard UI | 🚧 |
| 5 | Realtime integration (WS) | 🚧 |
| 6 | Device provisioning (BLE) | ⏳ |
| 7 | Backend + FavorIoT | ⏳ |
| 8 | Stats & Settings | ⏳ |
| 9 | Reliability, security & hardening | 🚧 |
| 10 | Testing, UAT & docs | 🚧 |

---

## 3. Phase 0 — Project Setup & Tooling ✅

- [x] Flutter project scaffold, all platform folders.
- [x] `very_good_analysis` (200+ rules) configured (`analysis_options.yaml`).
- [x] Husky + commitlint (conventional commits) + lint-staged.
- [x] `pnpm` scripts: `lint`, `lint:fix`, `format`, `format:check`.
- [x] Riverpod/Freezed/JSON codegen pipeline via `build_runner`.
- [x] Lexend font embedded in binary.

## 4. Phase 1 — Design System & Theming ✅

- [x] `AppColors` token set (`app_colors.dart`).
- [x] `AppTypography` (Lexend weights) + `AppTheme` (Material 3).
- [x] Shared widgets: `AppTextField`, `AppButton`, `BackgroundEllipse`,
      `LextariLogo`, `HealthGauge`, `SensorTile`, `StatusBadge`,
      `SensorErrorBoundary`, `OfflineBanner`.
- [x] Splash screen.

## 5. Phase 2 — Authentication ✅

- [x] `LextariAuth` Supabase wrapper (static API).
- [x] `AuthRepository` + Supabase error → user-friendly message mapping.
- [x] Login page, sign-up page.
- [x] `authStateProvider` stream + `ApiClient` token sync.
- [x] `AuthGuard` (cold-start safe) + GoRouter redirect.
- [x] Logout from dashboard avatar.
- [ ] Google Sign-In (stub only).

## 6. Phase 3 — Domain Logic (GHS) ✅

- [x] `SensorKey`, `SensorReading` (staleness), `HealthConfig`.
- [x] `GrowthHealthScore` bell-curve algorithm + partial-data re-weighting.
- [x] `HealthScoreResult` + status thresholds.
- [x] 24 unit tests (`growth_health_score_test.dart`).

## 7. Phase 4 — Dashboard UI 🚧

- [x] `DashboardShell` (green canvas, ellipse, floating nav, carousel).
- [x] `DashboardScreen` pinned-top + scrollable layout.
- [x] `ActionSwitch`, `HealthScoreCard`, `MiniGauge`, `SensorCard`.
- [x] Stats/Settings placeholder branches.
- [ ] Wire cards to live providers (currently placeholder data).
- [ ] Water-system state card + safety-lockout alert.
- [x] Skipped dashboard widget tests noted (2 skipped).

## 8. Phase 5 — Realtime Integration 🚧

- [x] `ApiClient` (HTTP + JWT attach + typed failures).
- [x] `WsClient` + `DashboardRepository.connect`.
- [x] `DashboardUpdate` freezed union + `fromJson`.
- [ ] Silent WS auto-reconnect with backoff.
- [ ] Hive-backed offline cache read/write.
- [ ] GHS snapshot endpoint integration.

## 9. Phase 6 — Device Provisioning (BLE) ⏳ 🔒

- [ ] BLE scan / discover base firmware.
- [ ] Send Wi-Fi creds + `user_id`.
- [ ] Provisioning progress + success/error UI.
- [ ] Device list / management screen.

> Blocked pending ESP32 base firmware and the FastAPI device-link endpoint.

## 10. Phase 7 — Backend + FavorIoT ⏳ 🔒

- [ ] FastAPI service skeleton + config.
- [ ] JWT verification middleware (`user_id` extraction).
- [ ] `POST /api/v1/devices/link` (verify device in FavorIoT + DB insert).
- [ ] `GET /api/devices`, `GET /api/telemetry/{key}`.
- [ ] `POST /api/rpc` proxy → FavorIoT RPC (offline = logged, not an error).
- [ ] Alarm evaluation in FastAPI (thresholds) + `device_state` tracking.
- [ ] WS fan-out from FastAPI to clients.
- [ ] PostgreSQL schema (`devices`, `device_state`, `alarms`, `rpc_commands`).
- [ ] Docker Compose stack + nginx + TLS (see [NETWORKING.md](NETWORKING.md)).

> Blocked pending VPS provisioning and a FavorIoT account with devices registered.

## 11. Phase 8 — Stats & Settings ⏳

- [ ] 30-day trend charts (`fl_chart`) from `/api/telemetry/{key}`.
- [ ] Species presets → mutable `HealthConfig`.
- [ ] Notification preferences.
- [ ] Account management screen.

## 12. Phase 9 — Reliability, Security & Hardening 🚧

- [x] Three-tier error handling (toast + Sentry + metrics).
- [x] Per-widget error boundaries; offline banner; stale indicator.
- [ ] WS reconnect guarantees (demo risk #1).
- [ ] Full security review against [SECURITY_CHECKLIST.md](SECURITY_CHECKLIST.md).
- [ ] Dependency audit (`flutter pub outdated`, SCA).
- [ ] Rate-limit handling surfaced gracefully.

## 13. Phase 10 — Testing, UAT & Docs 🚧

- [x] Unit tests: GHS (24).
- [x] Widget tests: shared widgets + screens (see README table).
- [x] Flow tests: navigation (5).
- [ ] Dashboard widget tests (2 currently skipped).
- [ ] `integration_test/` full-device flows.
- [x] Core docs (architecture, models, networking, conventions, …).
- [x] Requirements / flow / security doc set (this batch).

---

## 14. Milestones

| Milestone | Definition of done | Status |
|-----------|--------------------|--------|
| M1 — Auth complete | register/login/logout with guard + tests | ✅ |
| M2 — Demo dashboard | GHS + sensor cards render from live WS | 🚧 |
| M3 — Provisioning | one BLE flow creates a working device | ⏳ |
| M4 — Full loop | telemetry → GHS → app + RPC control | ⏳ |
| M5 — Viva-ready | all demo risk points mitigated + tests green | ⏳ |

---

## 15. Demo Risk Mitigations (from README)

| # | Risk | Mitigation | Status |
|---|------|-----------|--------|
| 1 | WebSocket drops mid-demo | Silent auto-reconnect | ⏳ |
| 2 | Sensor offline | Per-tile `SensorErrorBoundary` | ✅ |
| 3 | Session token expires | Transparent refresh | ⏳ |
| 4 | Autonomous refill fails | Manual refill trigger in app | ⏳ |
| 5 | No Wi-Fi | Stale data + indicator, never spinner | ✅ |
| 6 | Chart loads slowly | Skeleton immediately, never block | 🚧 |

---

## 16. Build & Verification Workflow

```bash
dart analyze                 # very_good_analysis, 200+ rules
dart fix --apply             # auto-fix
dart format lib/ test/       # format project source
dart run build_runner build  # after annotation changes
flutter test                 # 98 active + 2 skipped
```

CI-quality gate: `flutter analyze` clean; tests green; formatting clean
(`format:check`).

---

## 17. Related Documents

| Document | Purpose |
|----------|---------|
| [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) | Feature requirements + status |
| [TECHNICAL_REQUIREMENTS.md](TECHNICAL_REQUIREMENTS.md) | Stack + constraints |
| [APP_FLOW.md](APP_FLOW.md) | User journeys |
| [SECURITY_CHECKLIST.md](SECURITY_CHECKLIST.md) | Security gates |
| [TESTING.md](TESTING.md) | Test strategy |
