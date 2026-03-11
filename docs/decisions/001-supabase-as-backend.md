# ADR-001: Supabase As Managed Backend Platform

| Field | Value |
| --- | --- |
| Status | Accepted |
| Date | 2026-03-08 |
| Decision Maker | Rio Ferdana Sudrajat, Engineering Lead |

## Context

HaloFin membutuhkan backend platform yang menyediakan authentication, relational database (Postgres), realtime capabilities, dan object storage. Tim MVP berukuran kecil dan perlu mempercepat time-to-market tanpa membangun infrastruktur dari nol.

## Options Considered

| Option | Pros | Cons |
| --- | --- | --- |
| **Supabase** | Open-source, built on Postgres, auth + realtime + storage built-in, row-level security, generous free tier, self-host possible | Kurang mature dibanding Firebase, RLS bisa complex, vendor lock-in pada Supabase-specific features |
| Firebase | Very mature, excellent mobile SDK, large community | NoSQL (Firestore) kurang cocok untuk data finansial relasional, vendor lock-in Google, sulit self-host |
| Custom backend (bare Postgres + custom auth) | Full control, no vendor dependency | Sangat lambat untuk MVP, butuh banyak boilerplate, maintenance overhead tinggi |
| AWS Amplify | Scalable, backed by AWS | Over-engineered untuk MVP, complex pricing, steep learning curve |

## Decision

Pilih **Supabase** sebagai managed backend platform.

## Rationale

1. Data finansial bersifat relasional (wallet has many transactions, user has many wallets) — Postgres lebih natural dibanding NoSQL.
2. Built-in auth mengurangi effort integrasi auth secara signifikan.
3. Realtime channel cocok untuk notification draft transaction baru dan booking updates.
4. Row-Level Security (RLS) menyediakan data isolation per user di level database.
5. Object storage cocok untuk receipt images dan berkas pendukung.
6. Self-hosting option mengurangi risiko vendor lock-in jangka panjang.
7. Tim kecil mendapat benefit terbesar dari managed platform yang mengurangi ops overhead.

## Consequences

1. Tim harus memahami RLS policy design sebelum menulis schema.
2. Logika bisnis yang sensitif (AI orchestration, provider sync) tetap harus di Go Application Service, bukan di Supabase Edge Functions.
3. Supabase CLI harus menjadi bagian dari dev workflow.
4. Jika di masa depan perlu migrasi, maka karena Supabase berbasis Postgres, migrasi ke managed Postgres lain relatif straightforward.
