# ADR-003: Flutter As Mobile Framework

| Field | Value |
| --- | --- |
| Status | Accepted |
| Date | 2026-03-08 |
| Decision Maker | Rio Ferdana Sudrajat, Engineering Lead |

## Context

HaloFin mobile app harus tersedia di Android dan iOS. Tim MVP berukuran kecil sehingga membutuhkan satu codebase yang menghasilkan native-quality experience di kedua platform.

## Options Considered

| Option | Pros | Cons |
| --- | --- | --- |
| **Flutter** | Single codebase, native performance, hot reload, rich widget library, growing ecosystem, compile-safe (Dart) | Dart kurang populer, APK size lebih besar, platform-specific features butuh plugin |
| React Native | JavaScript ecosystem besar, large community, banyak library | Bridge overhead, complex native modules, debugging lebih sulit, performance kurang smooth untuk complex UI |
| Native (Kotlin + Swift) | Best performance, full platform access | Dua codebase, dua tim, dua kali effort — tidak realistis untuk MVP |
| KMP + Compose Multiplatform | Kotlin shared logic, native UI | Masih relatif baru untuk production, iOS support masih evolving |

## Decision

Pilih **Flutter** sebagai mobile framework.

## Rationale

1. Single codebase untuk Android dan iOS mengurangi development effort hingga 40-50%.
2. Dart compile-time safety mengurangi runtime errors pada financial calculations.
3. Hot reload mempercepat iterasi UI secara signifikan.
4. Widget-based architecture cocok untuk card-heavy, list-heavy financial UI.
5. Riverpod sebagai state management memberi pattern yang testable dan scalable.
6. Growing fintech adoption di Indonesia (Bank Jago, Dana) membuktikan Flutter viable untuk financial apps.
7. `go_router` menyediakan deep linking dan nested routing yang dibutuhkan untuk complex navigation.

## Consequences

1. Tim mobile perlu skill Dart — learning curve relatif rendah bagi developer yang familiar dengan typed languages.
2. Platform-specific features (biometrics, camera untuk OCR) membutuhkan plugin atau platform channel.
3. APK size perlu dimonitor — gunakan `--split-per-abi` untuk mengurangi download size.
4. Testing framework bawaan Flutter (widget test, integration test) harus dipakai dari awal.
