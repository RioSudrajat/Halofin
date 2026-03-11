# ADR-004: Next.js As Web Application Framework

| Field | Value |
| --- | --- |
| Status | Accepted |
| Date | 2026-03-08 |
| Decision Maker | Rio Ferdana Sudrajat, Engineering Lead |

## Context

HaloFin memiliki tiga web application surfaces: admin app, consultant app, dan landing page. Ketiga surface ini membutuhkan framework yang menyediakan server-side rendering, routing, TypeScript support, dan developer experience yang solid.

## Options Considered

| Option | Pros | Cons |
| --- | --- | --- |
| **Next.js (App Router)** | SSR/SSG/ISR bawaan, App Router modern, excellent TypeScript support, large ecosystem, Vercel deployment option | Opinionated, Vercel-centric ecosystem, App Router masih evolving |
| Vite + React SPA | Lightweight, fast, sederhana | Tidak ada SSR/SSG built-in, SEO lebih sulit untuk landing page, routing manual |
| Remix | Full-stack, progressive enhancement, good DX | Smaller community dibanding Next.js, kurang mainstream di Indonesia |
| SvelteKit | Excellent performance, minimal boilerplate | Ecosystem lebih kecil, hiring pool lebih terbatas |

## Decision

Pilih **Next.js** dengan App Router sebagai framework untuk semua web application surfaces.

## Rationale

1. Satu framework untuk tiga surfaces mengurangi context switching dan skill requirement.
2. App Router menyediakan layout system yang cocok untuk admin dashboard layout reuse.
3. SSG cocok untuk landing page (SEO, performance).
4. SSR cocok untuk admin dan consultant app (dynamic data, role-based views).
5. TypeScript strict mode memberikan type safety yang dibutuhkan untuk financial data handling.
6. `@tanstack/react-query` sebagai server state management bekerja seamless dengan Next.js.
7. `shadcn/ui` sebagai component approach cocok karena in-repo, customizable, dan tidak menambah vendor lock-in.

## Consequences

1. Tiga web apps berbagi stack yang sama — shared packages atau monorepo script bisa mempercepat development.
2. Admin dan consultant app menggunakan App Router only — Pages Router tidak diperbolehkan.
3. Tailwind CSS menjadi shared styling baseline.
4. Deployment perlu support Node.js server (bukan pure static hosting) untuk SSR surfaces.
