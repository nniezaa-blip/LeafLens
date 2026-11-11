# Lextari Networking Plan

All own services run in a single Docker Compose stack on one VPS. Only nginx is
exposed to the internet. Telemetry ingestion and MQTT are handled by **FavorIoT**
(a hosted SaaS), not by a container in this stack.

---

## Docker Compose

```yaml
services:
  nginx:
    image: nginx
    ports:
      - "443:443"    # HTTPS + WebSocket — Flutter → nginx → FastAPI
    depends_on:
      - fastapi

  fastapi:
    build: .
    environment:
      - FAVORIOT_API_KEY=${FAVORIOT_API_KEY}
      - DB_URL=postgresql://postgres:5432/lextari
    # no ports exposed to host

  postgres:
    image: postgres:16
    # no ports exposed to host
```

FavorIoT is a **managed cloud service**, so there is no IoT broker container in
this stack. No MQTT listener is needed on the VPS because the ESP32 connects
outbound to `mqtt.favoriot.com` directly.

All own services share one internal Docker network. FastAPI reaches PostgreSQL
via `postgres:5432` — never through a public URL.

---

## Traffic Flow

```
Internet
   │
   └── HTTPS/WS :443 ──→ nginx ──→ FastAPI   (Flutter app traffic)

Hardware (outbound only)
   ESP32 ──MQTT/TLS──→ mqtt.favoriot.com :8883   (telemetry + RPC)
   ESP32 ──Wi-Fi──→ home router (no inbound ports, no port forwarding)

Internal Docker network only:
   FastAPI ──→ PostgreSQL :5432
   FastAPI ──HTTPS──→ apiv2.favoriot.com :443   (outbound REST)
```

---

## What Is and Isn't Exposed

| Service | Public | Notes |
|---------|--------|-------|
| nginx | Yes — 443 | Only public-facing service |
| FastAPI | No | Internal only — nginx proxies to it |
| PostgreSQL | No | Internal only |
| FavorIoT (MQTT + REST) | Yes — managed SaaS | ESP32 + FastAPI connect outbound |
| FavorIoT console :443 | Yes (browser) | Admin only — device provisioning |

Because the ESP32 makes an **outbound** MQTT connection to FavorIoT, there is
**no port forwarding and no public broker**. Lextari works behind any home
router, NAT, or mobile network.

---

## Secrets

Secrets are injected as environment variables at runtime via a `.env` file on
the host. Never baked into Docker images, never committed to source control.

```env
FAVORIOT_API_KEY=...
POSTGRES_PASSWORD=...
FASTAPI_SECRET_KEY=...
```

`FAVORIOT_API_KEY` is account-wide and controls every device, so it is the
highest-value secret in the system — server-only, never shipped to the app or a
device.

For production, replace `.env` with a secrets manager (AWS Secrets Manager,
Doppler, etc.).

---

## FavorIoT Console

Device registration and device access tokens live in the FavorIoT console
(`https://platform.favoriot.com`), over HTTPS. Only an admin uses it; app users
never see it. No SSH tunnel is required — it is an external SaaS dashboard.

Workflow:
1. Admin logs in to the FavorIoT console.
2. Creates a device → gets `device_developer_id`.
3. Copies the device **access token** (eye icon) for flashing to the ESP32.
4. Links the device to a user in the app (`POST /api/v1/devices/link`).

---

## Deployment

```bash
docker compose up -d
```

Single command brings up nginx, FastAPI, and PostgreSQL. All inter-service
communication stays on the internal Docker network; all IoT traffic goes to
FavorIoT over the public internet.
