# ADR-002: Go As Application Service Language

| Field | Value |
| --- | --- |
| Status | Accepted |
| Date | 2026-03-08 |
| Decision Maker | Rio Ferdana Sudrajat, Engineering Lead |

## Context

HaloFin membutuhkan satu application service yang menangani logika bisnis sensitif di luar managed platform: AI orchestration, provider webhook intake, recommendation eligibility, booking/payment orchestration, dan audit logging. Bahasa ini harus performant, type-safe, dan mudah di-deploy.

## Options Considered

| Option | Pros | Cons |
| --- | --- | --- |
| **Go** | Fast compilation, excellent concurrency model, small binary, strong stdlib, easy deployment | Kurang ekspresif untuk complex business logic, generics masih relatif baru, smaller ecosystem dibanding Node |
| Node.js (TypeScript) | Sama dengan web stack, besar ecosystem, rapid prototyping | Single-threaded, memory overhead lebih tinggi, type safety bergantung pada TypeScript discipline |
| Python (FastAPI) | Excellent AI/ML ecosystem, rapid prototyping | GIL limitation, deployment complexity, type safety kurang strict |
| Rust | Maximum performance, memory safety | Steep learning curve, slow development velocity untuk MVP |

## Decision

Pilih **Go** sebagai bahasa untuk application service.

## Rationale

1. Webhook intake dan provider sync membutuhkan handling concurrent connections yang efisien — goroutines cocok untuk ini.
2. Single binary deployment menyederhanakan containerization dan CI/CD.
3. Strong typing mengurangi runtime errors pada logika finansial.
4. `net/http` standard library sudah cukup powerful untuk MVP; `gin` tersedia sebagai upgrade path.
5. Compilation cepat mempercepat feedback loop development.
6. Go tooling (gofmt, go vet, go test) sudah built-in dan mature.
7. Separation of concerns jelas: AI/ML inference tetap di provider (Gemini API), Go hanya orchestrate.

## Consequences

1. Tim backend perlu skill Go — jika belum ada, perlu learning ramp-up.
2. AI orchestration dilakukan via API call ke provider, bukan native ML inference.
3. Complex business logic mungkin lebih verbose dibanding dynamic language.
4. Go modules digunakan untuk dependency management; tidak ada shared package manager dengan web apps.
