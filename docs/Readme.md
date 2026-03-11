# HaloFin Documentation Hub

| Field | Value |
| --- | --- |
| Project | HaloFin |
| Active Phase | `mobile_frontend` |
| Last Updated | 2026-03-11 |

## Reading Order

Baca dokumen dalam urutan ini agar mendapat konteks yang utuh:

1. [PRD.md](./PRD.md) — Product Requirements Document
2. [glossary.md](./glossary.md) — Canonical terms and data dictionary
3. [Architecture.md](./tech/Architecture.md) — System architecture
4. [Techstack.md](./tech/Techstack.md) — Technology stack
5. [Frontend.md](./tech/Frontend.md) — Frontend delivery details
6. [Backend.md](./tech/Backend.md) — Backend strategy
7. [Security.md](./tech/Security.md) — Security architecture and compliance
8. [API Design](./tech/api-design.md) — API conventions and error codes
9. [Database](./tech/database.md) — Schema, migration, and data strategy
10. [Testing Strategy](./tech/testing-strategy.md) — Test pyramid and coverage

## Golden Rules

1. Baca PRD sebelum masuk ke dokumen teknis.
2. Selalu cek active phase sebelum memilih apa yang harus dikerjakan.
3. Tidak boleh memulai backend implementation pada fase frontend-only.
4. MockContract adalah boundary resmi antara frontend dan backend phase.
5. Semua istilah mengikuti [glossary.md](./glossary.md) sebagai source of truth.

## Document Purpose Map

| Document | Purpose | Required For |
| --- | --- | --- |
| [PRD.md](./PRD.md) | Definisi produk, fitur, prioritas, personas, RACI, risk register | Semua tim |
| [glossary.md](./glossary.md) | Canonical terms, status values, data dictionary | Semua tim |
| [Architecture.md](./tech/Architecture.md) | Topology, C4, ERD, deliverable boundary, NFRs | Engineering, Product |
| [Techstack.md](./tech/Techstack.md) | Stack choices, version pins, bootstrap steps | Engineering |
| [Frontend.md](./tech/Frontend.md) | Screen specs, layout, route map, component naming | Frontend engineering |
| [Backend.md](./tech/Backend.md) | Service architecture, folder structure, deployment, error handling | Backend engineering |
| [Security.md](./tech/Security.md) | Threat model, data classification, compliance, incident response | Engineering, Security, Legal |
| [API Design](./tech/api-design.md) | RESTful conventions, error codes, pagination, rate limiting | Engineering |
| [Database](./tech/database.md) | SQL schema, RLS, migration, backup | Backend engineering |
| [Testing Strategy](./tech/testing-strategy.md) | Test pyramid, coverage targets, mocking boundaries | Engineering, QA |

## Architecture Decision Records (ADRs)

| ADR | Decision |
| --- | --- |
| [ADR-001](./decisions/001-supabase-as-backend.md) | Supabase as managed backend platform |
| [ADR-002](./decisions/002-go-application-service.md) | Go as application service language |
| [ADR-003](./decisions/003-flutter-mobile.md) | Flutter as mobile framework |
| [ADR-004](./decisions/004-nextjs-web-apps.md) | Next.js as web application framework |
| [ADR-005](./decisions/005-riverpod-state-management.md) | Riverpod as Flutter state management |

## Engineering Guides

| Guide | Purpose |
| --- | --- |
| [Dev Setup](./guides/dev-setup.md) | Step-by-step development environment setup |
| [Engineering Standards](./guides/engineering-standards.md) | Branch model, commit convention, PR guidelines, code style |
| [CI/CD Pipeline](./guides/ci-cd-pipeline.md) | Pipeline stages, deployment, rollback |
| [Component Catalog](./guides/component-catalog.md) | Aggregated reusable mobile component catalog |

## Current App Surface Status

| AppSurface | Status | Notes |
| --- | --- | --- |
| `mobile` | 🟡 Frontend in progress | Active development |
| `admin` | ⚪ Not started | Starts after mobile complete |
| `consultant` | ⚪ Not started | Starts after admin complete |
| `landing` | ⚪ Not started | Last surface |

## Onboarding For New Team Members

1. Clone the repository.
2. Read this Readme to understand the documentation structure.
3. Follow [Dev Setup Guide](./guides/dev-setup.md) to set up your environment.
4. Read the [PRD](./PRD.md) to understand the product.
5. Read [Engineering Standards](./guides/engineering-standards.md) for coding and PR conventions.
6. Check the current active phase (above) and focus on relevant documents.
7. For frontend work: read [Frontend.md](./tech/Frontend.md) and [Component Catalog](./guides/component-catalog.md).
8. For backend work (when active): read [Backend.md](./tech/Backend.md), [API Design](./tech/api-design.md), and [Database](./tech/database.md).
