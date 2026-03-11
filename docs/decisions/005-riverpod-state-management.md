# ADR-005: Riverpod As Flutter State Management

| Field | Value |
| --- | --- |
| Status | Accepted |
| Date | 2026-03-08 |
| Decision Maker | Rio Ferdana Sudrajat, Engineering Lead |

## Context

HaloFin mobile app membutuhkan state management solution yang dapat mengelola complex financial state (wallet balances, draft transactions, budget progress, notification counts) secara testable, type-safe, dan scalable.

## Options Considered

| Option | Pros | Cons |
| --- | --- | --- |
| **Riverpod** | Compile-safe, testable, no BuildContext dependency, supports async/stream, code generation option | Learning curve untuk developer yang terbiasa setState, code generator dependency |
| Provider | Simple, Flutter-recommended | BuildContext dependency, sulit testing, tidak compile-safe |
| BLoC/Cubit | Predictable state, good separation | Boilerplate tinggi, over-engineered untuk banyak simple use cases |
| GetX | Minimal boilerplate, rapid development | Kurang testable, anti-pattern menurut banyak Flutter community, maintenance concern |
| `get_it` + injectable | Lightweight DI, flexible | Tidak compile-safe, runtime registration errors possible |

## Decision

Pilih **Riverpod** (`flutter_riverpod`) sebagai primary state management dan dependency injection solution.

## Rationale

1. Compile-time safety mengurangi state-related bugs pada financial calculations.
2. No `BuildContext` dependency memungkinkan test tanpa widget tree scaffolding.
3. `AsyncValue` built-in menangani loading/error/data states secara natural — cocok untuk financial data yang selalu async.
4. Auto-dispose capability menghindari memory leaks pada screen yang complex.
5. Provider family dan modifier mendukung parameterized state (wallet tertentu, budget periode tertentu).
6. Code generation option (`riverpod_generator`) mengurangi boilerplate di kemudian hari.
7. Riverpod sebagai standard tunggal menghindari kebutuhan `get_it` sebagai DI terpisah.

## Consequences

1. Tim perlu memahami Riverpod paradigm (providers, notifiers, consumers) sebelum productive.
2. State harus dimodelkan sebagai domain-first, bukan widget-local — ini memerlukan disiplin arsitektur.
3. Complex provider chains perlu documented dependency graph agar maintainable.
4. Migration dari Riverpod ke solution lain akan costly — tapi ini acceptable karena Riverpod actively maintained.
