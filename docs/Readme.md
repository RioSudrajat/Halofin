# HaloFin Documentation Map

## Current Active Phase

`mobile_frontend`

Arti fase aktif saat ini:

1. Fokus hanya pada mobile app.
2. Yang dikerjakan hanya frontend, interaction flow, local state, mock contracts, dan UI states.
3. Backend, auth integration, database integration, dan provider integration belum menjadi target implementation aktif.

## Document Reading Order

Baca dokumen dalam urutan berikut:

1. [PRD.md](D:/Projekan/Halofin/docs/PRD.md)
   Menjelaskan produk, 4 app surface, fitur, dan urutan delivery.
2. [Architecture.md](D:/Projekan/Halofin/docs/tech/Architecture.md)
   Menjelaskan arsitektur final, arsitektur fase aktif, dan boundary mock vs real integration.
3. [Techstack.md](D:/Projekan/Halofin/docs/tech/Techstack.md)
   Menjelaskan stack per app surface dan aturan penggunaan per phase.
4. [Frontend.md](D:/Projekan/Halofin/docs/tech/Frontend.md)
   Menjelaskan strategi frontend-first, definition of done frontend, serta source of truth untuk screen inventory, route map fase aktif, dan slicing UI mobile yang mengacu ke `docs/assets/ui_halofin`.
5. [Backend.md](D:/Projekan/Halofin/docs/tech/Backend.md)
   Menjelaskan kapan backend dimulai dan bagaimana integrasi mengikuti frontend contract.
6. [Security.md](D:/Projekan/Halofin/docs/tech/Security.md)
   Menjelaskan security posture per phase.

## Document Purpose Map

| Document | Primary Purpose |
| --- | --- |
| `PRD.md` | Source of truth untuk intent produk dan delivery strategy |
| `Architecture.md` | Source of truth untuk target architecture dan phase-aware architecture |
| `Techstack.md` | Source of truth untuk stack, baseline runtime, dan phase usage rules |
| `Frontend.md` | Source of truth untuk phase frontend-only |
| `Backend.md` | Source of truth untuk phase backend/integration |
| `Security.md` | Source of truth untuk security posture lintas phase |

## AppSurface Summary

| AppSurface | Status In Delivery Order |
| --- | --- |
| `mobile` | Active first |
| `admin` | Queued after mobile complete |
| `consultant` | Queued after admin complete |
| `landing` | Queued last |

## Golden Rules

1. Jangan mengerjakan semua app surface sekaligus.
2. Jangan mengerjakan backend implementation saat phase aktif masih frontend-only.
3. Gunakan MockContract sebagai jembatan resmi antara phase frontend dan backend.
4. Pindah ke phase berikutnya hanya setelah phase sebelumnya selesai sesuai definition of done.
