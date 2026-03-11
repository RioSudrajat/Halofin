# Development Environment Setup Guide

| Field | Value |
| --- | --- |
| Project | HaloFin |
| Last Updated | 2026-03-11 |

## 1. Prerequisites

### Required Software

| Software | Version | Purpose | Install |
| --- | --- | --- | --- |
| Git | Latest stable | Version control | [git-scm.com](https://git-scm.com) |
| Flutter SDK | 3.41.2 (stable) | Mobile app development | [flutter.dev/get-started](https://flutter.dev/docs/get-started/install) |
| Node.js | 24.14.0 LTS | Web apps and JS tooling | [nodejs.org](https://nodejs.org) (use nvm recommended) |
| pnpm | Latest (recorded in `packageManager`) | JS package manager | `npm install -g pnpm` |
| Go | 1.26.1 | Backend service | [go.dev/dl](https://go.dev/dl/) |
| Docker Desktop | Latest stable | Containerization, Supabase local | [docker.com](https://docker.com) |
| Supabase CLI | >= 1.69.0 | Local Supabase instance | `npm install -g supabase` |
| Redis | Latest (via Docker) | Cache / rate limiting | Included in Docker Compose |

### Recommended Tools

| Tool | Purpose |
| --- | --- |
| VS Code or Android Studio | IDE |
| Flutter & Dart VS Code extensions | Flutter development |
| Go VS Code extension | Go development |
| Postman or Bruno | API testing |
| TablePlus or pgAdmin | Database inspection |
| Redis Insight | Redis inspection |

## 2. Repository Setup

```bash
# Clone the repository
git clone <repo-url>
cd halofin

# Repository structure
# halofin/
# ├── apps/
# │   ├── mobile/          # Flutter app
# │   ├── admin/           # Next.js admin app
# │   ├── consultant/      # Next.js consultant app
# │   └── landing/         # Next.js landing page
# ├── services/
# │   └── api/             # Go application service
# └── docs/                # Documentation (you are here)
```

## 3. Mobile App Setup (Flutter)

```bash
# Verify Flutter installation
flutter doctor

# Navigate to mobile app
cd apps/mobile

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Run tests
flutter test

# Run with specific device
flutter devices                  # List available devices
flutter run -d <device-id>
```

### Flutter Configuration Checklist

1. [ ] Flutter SDK 3.41.2 installed and in PATH.
2. [ ] Android Studio installed with Android SDK (for Android emulator).
3. [ ] Xcode installed (macOS only, for iOS simulator).
4. [ ] `flutter doctor` shows no errors.
5. [ ] `flutter pub get` succeeds.
6. [ ] App runs on emulator/device.

## 4. Web Apps Setup (Next.js)

```bash
# Navigate to web app (example: admin)
cd apps/admin

# Install dependencies
pnpm install

# Run development server
pnpm dev

# Build for production
pnpm build

# Run tests
pnpm test

# Run linting
pnpm lint
```

### Web App Configuration Checklist

1. [ ] Node.js 24.14.0 LTS installed.
2. [ ] pnpm installed globally.
3. [ ] `pnpm install` succeeds.
4. [ ] `pnpm dev` starts without errors.
5. [ ] `pnpm lint` passes.

## 5. Backend Service Setup (Go)

```bash
# Navigate to service
cd services/api

# Download dependencies
go mod download

# Run the service
go run cmd/server/main.go

# Run tests
go test ./...

# Run linting
gofmt -l .
go vet ./...
```

### Backend Configuration

Create `services/api/.env` (gitignored):

```env
SERVER_PORT=8080
DATABASE_URL=postgresql://postgres:postgres@localhost:54322/postgres
REDIS_URL=redis://localhost:6379
SUPABASE_URL=http://localhost:54321
SUPABASE_JWT_SECRET=<from-supabase-local>
AI_PROVIDER_URL=<your-provider-url>
AI_API_KEY=<your-api-key>
AI_MODEL_NAME=<model-name>
```

### Backend Configuration Checklist

1. [ ] Go 1.26.1 installed.
2. [ ] `go mod download` succeeds.
3. [ ] `.env` file created with local values.
4. [ ] `go run cmd/server/main.go` starts without errors.
5. [ ] `go test ./...` passes.

## 6. Supabase Local Setup

```bash
# Initialize Supabase (if not already done)
supabase init

# Start local Supabase
supabase start

# This starts:
# - Postgres (port 54322)
# - Supabase Auth (port 54321)
# - Supabase Storage
# - Supabase Realtime

# Run migrations
supabase db push

# Open Supabase Studio (local dashboard)
# Usually at http://localhost:54323

# Stop Supabase
supabase stop
```

## 7. Redis Local Setup

```bash
# Via Docker (recommended)
docker run -d --name halofin-redis -p 6379:6379 redis:alpine

# Verify
redis-cli ping
# Should return: PONG
```

## 8. Running Everything Together

```bash
# Terminal 1: Supabase
cd halofin && supabase start

# Terminal 2: Redis
docker start halofin-redis

# Terminal 3: Go Service
cd services/api && go run cmd/server/main.go

# Terminal 4: Mobile App
cd apps/mobile && flutter run

# Terminal 5: Admin App (when active)
cd apps/admin && pnpm dev
```

## 9. Troubleshooting

| Problem | Solution |
| --- | --- |
| `flutter doctor` shows issues | Follow the specific instructions Flutter provides |
| `pnpm install` fails | Clear cache: `pnpm store prune` then retry |
| Go module download fails | Check proxy: `go env GOPROXY` should be `https://proxy.golang.org,direct` |
| Supabase start fails | Ensure Docker is running; try `supabase stop` then `supabase start` |
| Port conflict | Check which process is using the port: `lsof -i :<port>` (Mac/Linux) or `netstat -ano | findstr :<port>` (Windows) |

## 10. Phase Awareness

Remember the current active phase: **`mobile_frontend`**.

During this phase:
- Only `apps/mobile` is actively developed.
- No `services/api` implementation needed yet.
- Supabase and Redis are NOT required for frontend-only work.
- Use mock repositories and local fixtures for data.

When backend phase starts, you'll need Supabase and Redis running locally.
