# System Architecture

| Field | Value |
| --- | --- |
| Project | HaloFin |
| Document Version | 3.0 |
| Status | Approved For MVP Planning |
| Last Updated | 2026-03-11 |
| Audience | Engineering, Product, Security, AI Coding Agent |

## Change Summary

| Date | Change |
| --- | --- |
| 2026-03-11 | Added C4 Component diagram for Go service, Entity Relationship Diagram, Non-Functional Requirements, and new domain objects for Notification, Report, and multi-currency. |
| 2026-03-09 | Synced current mobile phase architecture with frontend-approved screen clusters, route keys, and mock data boundaries. |
| 2026-03-09 | Added target-vs-current delivery architecture, four app surfaces, frontend-only mode, mock contract boundary, and phase delivery diagrams. |
| 2026-03-08 | Reframed architecture from vague microservice wording into a concrete MVP architecture: managed backend plus one Go application service plus external providers. |

## 1. Architecture Summary

HaloFin end-state menggunakan arsitektur:

`mobile app + admin app + consultant app + landing page + managed Supabase backend + single Go application service + Redis + external providers`

Dokumen ini sengaja tidak menyebut sistem sebagai microservices, karena pada tahap MVP hanya ada satu application service yang menjalankan orkestrasi bisnis di luar managed platform. Jika di masa depan service dipecah, perubahan itu harus dinyatakan eksplisit sebagai evolusi arsitektur, bukan diasumsikan sejak awal.

Rationale untuk setiap keputusan teknologi utama tersedia di folder [decisions/](../decisions/).

## 2. Architectural Principles

1. Managed services dipakai untuk mempercepat time-to-market pada kapabilitas standar.
2. Logika finansial sensitif, orkestrasi AI, dan integrasi provider ditempatkan pada application service yang terkontrol.
3. AI dan provider eksternal hanya boleh menghasilkan draft, bukan transaksi final.
4. Consent, audit trail, dan access boundary lebih penting daripada automasi penuh.
5. Semua webhook provider harus idempotent.
6. Pada fase frontend-only, tidak ada backend implementation yang dikerjakan.
7. Real API harus mengikuti frontend flow dan MockContract yang sudah approved pada phase sebelumnya.

## 3. Target Architecture Topology

Ini adalah bentuk sistem final saat seluruh app surface sudah selesai dibangun.

```mermaid
graph TD
    subgraph Clients
        Mobile["Mobile App"]
        Admin["Admin App"]
        Consultant["Consultant App"]
        Landing["Landing Page"]
    end

    subgraph HaloFinCore
        Supabase["Supabase Platform\nAuth, Postgres, Realtime, Storage"]
        API["Go Application Service\nAI orchestration, provider sync, recommendation, booking, admin logic"]
        Redis["Redis\ncache, rate limit, ephemeral status"]
    end

    subgraph ExternalProviders
        Finance["Financial Data Provider\ncandidate"]
        AI["AI Provider"]
        Payment["Payment Gateway\ncandidate"]
        Meeting["Video Provider\noptional candidate"]
        Currency["Currency Rate Provider"]
    end

    Mobile --> Supabase
    Mobile --> API
    Admin --> Supabase
    Admin --> API
    Consultant --> Supabase
    Consultant --> API
    Landing --> API

    Finance --> API
    API --> AI
    API --> Payment
    API --> Meeting
    API --> Currency
    API --> Supabase
    API --> Redis
```

## 4. C4 Component Diagram: Go Application Service

```mermaid
graph TD
    subgraph GoService["Go Application Service"]
        Router["HTTP Router\nrequest routing, middleware"]
        AuthMiddleware["Auth Middleware\ntoken validation, rate limiting"]
        
        subgraph Handlers["API Handlers"]
            TransactionHandler["Transaction Handler\ncreate, read, draft management"]
            WalletHandler["Wallet Handler\nCRUD, balance computation"]
            AIHandler["AI Handler\nchat, voice, OCR orchestration"]
            SyncHandler["Sync Handler\nwebhook intake, dedup, normalization"]
            RecommendHandler["Recommendation Handler\neligibility check, nudge delivery"]
            BookingHandler["Booking Handler\nsession creation, payment orchestration"]
            ReportHandler["Report Handler\naggregation queries, export"]
            NotifHandler["Notification Handler\nevent detection, delivery"]
            AdminHandler["Admin Handler\nconsultant verification, monitoring"]
            CurrencyHandler["Currency Handler\nrate fetch, conversion display"]
        end
        
        subgraph Services["Business Logic Layer"]
            DraftService["Draft Service\nAI parsing, provider normalization"]
            FinanceService["Finance Service\nbalance calc, budget tracking"]
            ConsentService["Consent Service\ngrant management, access check"]
            AuditService["Audit Service\nevent logging, trail management"]
            NotifService["Notification Service\nrule engine, delivery dispatch"]
        end
        
        subgraph Adapters["External Adapters"]
            DBAdapter["Database Adapter\npgx, sqlc queries"]
            AIAdapter["AI Provider Adapter\nGenAI SDK"]
            PayAdapter["Payment Adapter\nprovider SDK"]
            SyncAdapter["Sync Provider Adapter\nHTTP client"]
            CacheAdapter["Redis Adapter\ncache, rate limit"]
            CurrencyAdapter["Currency Rate Adapter\nHTTP client"]
        end
    end
    
    Router --> AuthMiddleware
    AuthMiddleware --> Handlers
    Handlers --> Services
    Services --> Adapters
```

## 5. Entity Relationship Diagram

```mermaid
erDiagram
    USER ||--o{ WALLET : owns
    USER ||--o{ TRANSACTION : creates
    USER ||--o{ DRAFT_TRANSACTION : receives
    USER ||--o{ BUDGET : sets
    USER ||--o{ GOAL : creates
    USER ||--o{ BILL : tracks
    USER ||--o{ PROVIDER_CONNECTION : connects
    USER ||--o{ NOTIFICATION : receives
    USER ||--o{ CONSENT_GRANT : authorizes
    
    WALLET ||--o{ TRANSACTION : contains
    WALLET ||--o{ DRAFT_TRANSACTION : targets
    
    TRANSACTION }o--|| WALLET : affects_balance
    
    DRAFT_TRANSACTION }o--o| PROVIDER_CONNECTION : sourced_from
    
    CONSULTANT ||--o{ CONSULTATION_SESSION : hosts
    USER ||--o{ CONSULTATION_SESSION : books
    CONSULTATION_SESSION ||--o| CONSENT_GRANT : requires
    
    RECOMMENDATION }o--|| WALLET : targets
    USER ||--o{ RECOMMENDATION : receives

    USER {
        uuid user_id PK
        string email
        string display_name
        string preferred_currency
        boolean onboarding_completed
        json notification_preferences
        timestamp created_at
    }
    
    WALLET {
        uuid wallet_id PK
        uuid user_id FK
        string name
        enum type
        string currency
        decimal balance
        enum status
        timestamp created_at
    }
    
    TRANSACTION {
        uuid transaction_id PK
        uuid user_id FK
        uuid wallet_id FK
        enum type
        string category
        decimal amount
        string currency
        string description
        date transaction_date
        enum status
        enum source
        timestamp created_at
    }
    
    DRAFT_TRANSACTION {
        uuid draft_id PK
        uuid user_id FK
        uuid wallet_id FK
        enum type
        string category
        decimal amount
        string description
        date draft_date
        enum status
        enum source
        string provider_event_id
        float confidence_score
        timestamp created_at
    }
    
    BUDGET {
        uuid budget_id PK
        uuid user_id FK
        string category
        decimal amount_limit
        enum period_type
        date period_start
    }
    
    GOAL {
        uuid goal_id PK
        uuid user_id FK
        string name
        decimal target_amount
        decimal saved_amount
        date target_date
        enum priority
    }
    
    BILL {
        uuid bill_id PK
        uuid user_id FK
        string name
        decimal amount
        date due_date
        enum recurrence
        enum status
        boolean auto_pay
    }
    
    NOTIFICATION {
        uuid notification_id PK
        uuid user_id FK
        enum type
        string title
        string body
        string deep_link
        enum status
        timestamp created_at
    }
    
    CONSULTANT {
        uuid consultant_id PK
        string name
        string specialization
        json certifications
        decimal rating
        decimal hourly_rate
        enum verification_status
    }
    
    CONSULTATION_SESSION {
        uuid session_id PK
        uuid user_id FK
        uuid consultant_id FK
        enum service_type
        timestamp scheduled_at
        enum status
        string payment_reference
    }
    
    CONSENT_GRANT {
        uuid consent_id PK
        uuid user_id FK
        uuid consultant_id FK
        uuid session_id FK
        enum status
        timestamp granted_at
        timestamp expires_at
    }
    
    PROVIDER_CONNECTION {
        uuid connection_id PK
        uuid user_id FK
        string provider_name
        enum status
        timestamp last_sync_at
        string last_sync_status
    }
    
    RECOMMENDATION {
        uuid recommendation_id PK
        uuid user_id FK
        uuid wallet_id FK
        string instrument_type
        enum status
        timestamp created_at
    }
```

## 6. Delivery Architecture Strategy

Dokumen ini membedakan dua bentuk arsitektur yang harus dipahami terpisah.

### 6.1 Target Architecture

Target architecture adalah bentuk final sistem saat semua app surface selesai dan semua integrasi aktif.

### 6.2 Current Delivery Phase Architecture

Current delivery phase architecture adalah bentuk sistem yang relevan untuk fase aktif saat ini. Pada saat dokumen ini diperbarui, fase aktif adalah `mobile_frontend`.

Konsekuensi fase aktif:

1. Hanya `mobile app` yang sedang dikerjakan.
2. Fokus pekerjaan adalah UI, interaction flow, screen states, mock contracts, local fixtures, dan state management.
3. `Go Application Service`, real auth, database integration, dan provider integration belum diimplementasikan pada fase ini.
4. App surface lain belum menjadi target implementation aktif.

### 6.3 Current Mobile Screen Cluster

Pada fase aktif, mobile app tidak lagi diperlakukan sebagai kumpulan screen generik. Frontend-approved cluster saat ini adalah:

| MobileRouteKey | Screen Cluster | Mock Data Boundary |
| --- | --- | --- |
| `onboarding` | Registration, wallet setup, category selection | onboarding state, wallet creation mock |
| `home` | Dashboard utama, quick actions, expert help, recent activity | dashboard summary, expert help preview, recent activity preview |
| `wallet` | Wallet overview with asset distribution | wallet list, asset distribution, sort and filter state |
| `budget` | Budget summary and category list | budget summary, budget category list |
| `goals` | Goals overview and create-goal entry point | goals list, goal progress, smart tip |
| `bills` | Bills summary, upcoming payments, paid bills | bills summary, upcoming bills, paid bills |
| `consult_list` | Consultant discovery and filter | consultant list, category filters, search result state |
| `consult_detail` | Consultant profile and booking CTA | consultant detail, reviews, pricing summary |
| `transaction_entry` | Manual entry flow | transaction draft input, wallet options, category state |
| `transaction_history` | Search and filtered history | transaction history query state, grouped transaction list, totals |
| `reporting` | Income vs expense, category breakdown, trend | report summary, chart data, period filter |
| `notifications` | Notification center, read/unread state | notification list, badge count, deep link targets |

```mermaid
flowchart TD
    Onboarding["onboarding"] --> Home["home"]
    Home --> Wallet["wallet"]
    Home --> Budget["budget"]
    Home --> ConsultList["consult_list"]
    Home --> TransactionHistory["transaction_history"]
    Home --> TransactionEntry["transaction_entry"]
    Home --> Reporting["reporting"]
    Home --> Notifications["notifications"]
    Budget --> Goals["goals"]
    Budget --> Bills["bills"]
    ConsultList --> ConsultDetail["consult_detail"]
```

Arsitektur fase aktif harus membaca cluster di atas sebagai unit delivery UI yang sudah tervalidasi. Selama `mobile_frontend`, relasi antar-cluster ini hanya bergantung pada navigation, local state, dan MockContract, bukan pada backend implementation.

```mermaid
flowchart LR
    A["mobile_frontend"] --> B["mobile_backend_integration"]
    B --> C["mobile_test_fix"]
    C --> D["admin_frontend"]
    D --> E["admin_backend_integration"]
    E --> F["admin_test_fix"]
    F --> G["consultant_frontend"]
    G --> H["consultant_backend_integration"]
    H --> I["consultant_test_fix"]
    I --> J["landing_frontend"]
```

## 7. Frontend-Only Development Mode

Frontend-only mode adalah mode delivery saat UI dikembangkan tanpa backend implementation.

### Allowed In Frontend-Only Mode

1. Screen building
2. Navigation and interaction flow
3. Local state and view model
4. Mock JSON and local fixtures
5. MockContract request and response placeholder
6. Error, loading, empty, and success state simulation

Contoh boundary mock yang relevan untuk fase aktif saat ini:

1. `onboarding_flow_state`
2. `dashboard_summary` dan `recent_activity_preview`
3. `wallet_list` dan `asset_distribution`
4. `budget_summary`, `goal_list`, dan `bills_list`
5. `consultant_list` dan `consultant_detail`
6. `transaction_entry_draft` dan `transaction_history_query`
7. `report_summary` dan `chart_data`
8. `notification_list` dan `notification_badge`

### Not Allowed In Frontend-Only Mode

1. Real backend endpoint implementation
2. Database schema implementation
3. Provider webhook handling
4. Real auth integration
5. Secret management for production integration

```mermaid
flowchart TD
    UI["UI screens and interactions"] --> MockData["Mock data and local fixtures"]
    MockData --> Contracts["MockContract placeholders"]
    Contracts --> Review["Frontend flow approved"]
    Review --> NextPhase["Backend and integration phase starts"]

    UI -. no real backend .-> Blocked1["No API implementation yet"]
    MockData -. no provider secrets .-> Blocked2["No real integration yet"]
```

## 8. Component Responsibilities And Boundaries

| Component | Responsibilities | Must Not Own |
| --- | --- | --- |
| Mobile App | User transaction entry, draft review, wallet view, sync connection flow, recommendation view, consultation experience, reporting display, notifications, onboarding | Provider credentials, business rules source of truth |
| Admin App | Verifikasi konsultan, monitoring operasional, audit support, operational dashboards | End-user product flow ownership |
| Consultant App | Session management, client access based on consent, consultant workflow | Platform-wide admin controls |
| Landing Page | Brand communication, public information, lead or user acquisition | Authenticated user transaction domain |
| Supabase | Auth, primary relational data, realtime events, storage, row-level access control | AI orchestration, provider normalization logic |
| Go Application Service | Provider webhook intake, AI orchestration, recommendation eligibility, booking/payment orchestration, audit logging hooks, report aggregation, notification orchestration, currency rate management | Long-term user session UI state |
| Redis | Cache, rate limiting, transient sync state, short-lived coordination data, currency rate cache | Source of truth for financial records |
| External Providers | Data ingestion, payment processing, optional meeting/session services, currency rates | HaloFin domain ownership |

## 9. Canonical Domain And Delivery Objects

| Object | Purpose | Canonical Status |
| --- | --- | --- |
| Wallet | Menyimpan saldo yang ditampilkan ke user | `active`, `archived` |
| Transaction | Catatan finansial final yang memengaruhi saldo | `posted`, `voided` |
| DraftTransaction | Draft dari AI atau provider yang menunggu review | `review_needed`, `confirmed`, `rejected` |
| ProviderConnection | Hubungan user dengan provider finansial | `connected`, `syncing`, `needs_reauth`, `failed` |
| Recommendation | Saran kontekstual yang dihasilkan sistem | `eligible`, `dismissed`, `clicked` |
| ConsultationSession | Sesi layanan user dan konsultan | `pending_payment`, `confirmed`, `completed`, `cancelled` |
| ConsentGrant | Izin akses data untuk konsultan | `active`, `revoked`, `expired` |
| Notification | Pesan proaktif tentang event yang perlu perhatian | `unread`, `read`, `dismissed`, `actioned` |
| Report | Ringkasan analitik keuangan per periode | Generated on demand |
| AppSurface | Surface aplikasi yang sedang dibahas | `mobile`, `admin`, `consultant`, `landing` |
| DeliveryPhase | Fase delivery implementasi | lihat daftar fase resmi pada PRD |
| MockContract | Placeholder interface frontend sebelum real API | `draft`, `approved`, `implemented` |

## 10. Non-Functional Requirements

| Aspect | Requirement | Target |
| --- | --- | --- |
| **Response Time** | API response time for critical read paths (dashboard, wallet list, transaction history) | p95 < 500ms |
| **Response Time** | API response time for write paths (create transaction, confirm draft) | p95 < 1000ms |
| **Response Time** | AI draft generation (chat/voice/OCR) | p95 < 5000ms |
| **Throughput** | Concurrent active users at MVP launch | Support 1,000 concurrent users |
| **Throughput** | Transactions per second (create + read combined) | Support 100 TPS |
| **Availability** | System uptime target | 99.5% monthly |
| **Availability** | Planned maintenance window | Max 30 min, announced 24h prior |
| **Data Durability** | Transaction data backup | Daily automated backup, 30-day retention |
| **Scalability** | Horizontal scaling for Go service | Stateless design, container-based scaling |
| **Mobile Performance** | App cold start time | < 3 seconds on mid-range Android |
| **Mobile Performance** | Screen transition time | < 300ms |
| **Storage** | Receipt image max size | 5MB per image |
| **Storage** | Data export max period | Up to 12 months in one export |
| **Currency** | Exchange rate update frequency | Minimum once daily |

## 11. Data Ownership Rules

1. Postgres adalah source of truth untuk wallet, transaction, draft transaction, provider connection metadata, recommendation events, booking, notification records, dan audit records.
2. Redis hanya boleh menyimpan data sementara seperti rate-limit counters, sync progress, currency rate cache, dan cache yang dapat direkonstruksi.
3. Provider credentials tidak boleh disimpan oleh HaloFin.
4. AI request or response yang berisi data sensitif harus diperlakukan sebagai data terkontrol dan tidak menjadi source of truth tanpa review user.
5. Konsultan hanya dapat melihat data yang dicakup oleh ConsentGrant aktif.
6. Pada frontend-only phase, source of truth hanya berada pada mock fixtures atau local state sementara, bukan backend domain implementation.
7. Currency rate cache di Redis dapat di-invalidate kapan saja; fallback ke last-known-good rate.

## 12. Auth And Access Model

### End User

1. User login melalui managed auth platform pada fase integrasi.
2. Mobile app membaca data user langsung dari platform data untuk operasi yang diizinkan.
3. Untuk operasi yang memerlukan orkestrasi bisnis atau provider interaction, mobile app memanggil Go application service dengan token user.

### Consultant

1. Consultant login melalui managed auth platform saat consultant app memasuki fase backend/integration.
2. Consultant app memuat data yang diizinkan berdasarkan role dan consent.

### Admin

1. Admin menggunakan admin app dengan role terpisah.
2. Aksi administratif harus diaudit.

```mermaid
flowchart LR
    EndUser["End User"] --> Mobile["Mobile App"]
    Consultant["Consultant"] --> ConsultantApp["Consultant App"]
    Admin["Admin"] --> AdminApp["Admin App"]

    Mobile --> Auth["Managed Auth"]
    ConsultantApp --> Auth
    AdminApp --> Auth
    Mobile --> API["Go Application Service"]
    ConsultantApp --> API
    AdminApp --> API
    API --> Supabase["Supabase Data Access"]
    API --> Audit["Audit Trail"]
```

## 13. Canonical Flows

### 13.1 AI Draft Transaction Flow

1. User mengirim input teks, suara, atau gambar dari mobile app.
2. Mobile app mengirim request ke Go application service.
3. Service membersihkan payload, mengirim bagian relevan ke AI provider, lalu memetakan hasil ke DraftTransaction.
4. DraftTransaction disimpan dengan status `review_needed`.
5. Notification dikirim ke user bahwa ada draft baru.
6. Mobile app menampilkan hasil review ke user.
7. Hanya setelah user mengonfirmasi, DraftTransaction dikonversi menjadi Transaction final.

```mermaid
sequenceDiagram
    participant U as User
    participant M as Mobile App
    participant A as Go Application Service
    participant AI as AI Provider
    participant DB as Supabase

    U->>M: Input text, voice, or image
    M->>A: Send AI draft request
    A->>AI: Send sanitized payload
    AI-->>A: Extracted fields
    A->>DB: Save DraftTransaction(review_needed)
    A->>DB: Create Notification(draft_review)
    A-->>M: Return draft data
    M-->>U: Show review screen
    U->>M: Confirm or edit
    M->>A: Finalize approved draft
    A->>DB: Create final Transaction
```

### 13.2 Provider Sync Review Flow

1. User memulai koneksi akun melalui provider flow yang di-embed di client.
2. Provider mengelola autentikasi dan mengirim callback atau webhook ke Go application service.
3. Service memverifikasi signature, melakukan deduplication, menormalisasi payload, lalu membuat DraftTransaction.
4. ProviderConnection dan sync status diperbarui.
5. Notification dikirim ke user bahwa ada draft baru untuk ditinjau.
6. Event realtime atau polling memberi tahu client bahwa ada draft baru untuk ditinjau.
7. User mengonfirmasi, mengedit, atau menolak draft satu per satu atau secara bulk sesuai aturan produk.

```mermaid
sequenceDiagram
    participant U as User
    participant M as Mobile App
    participant P as Financial Data Provider
    participant A as Go Application Service
    participant DB as Supabase

    U->>M: Start connect account flow
    M->>P: Open provider connection flow
    P-->>A: Send callback or webhook
    A->>A: Verify signature and deduplicate
    A->>DB: Save DraftTransaction(review_needed)
    A->>DB: Update ProviderConnection and sync status
    A->>DB: Create Notification(draft_review)
    DB-->>M: Realtime update or poll result
    M-->>U: Show draft review list
    U->>M: Confirm, edit, or reject
```

### 13.3 Recommendation Eligibility Flow

1. User membuka detail wallet.
2. Client meminta eligibility check ke Go application service.
3. Service membaca saldo wallet, tipe wallet, dan aturan recommendation aktif.
4. Jika syarat terpenuhi, service membuat payload Recommendation dengan status `eligible`.
5. Client menampilkan nudge. Jika user dismiss atau klik, event direkam untuk analytics dan audit.
6. Jika user meminta penjelasan lanjutan, AI provider hanya memberi penjelasan edukatif; bukan keputusan investasi final.

```mermaid
sequenceDiagram
    participant U as User
    participant C as Mobile App
    participant A as Go Application Service
    participant DB as Supabase
    participant AI as AI Provider

    U->>C: Open wallet detail
    C->>A: Request eligibility check
    A->>DB: Read wallet balance and rules
    A-->>C: Return Recommendation(eligible) or no nudge
    C-->>U: Show dismissible nudge
    U->>C: Click learn more
    C->>A: Request explanation
    A->>AI: Generate educational explanation
    AI-->>A: Safe explanatory output
    A-->>C: Return explanation
```

### 13.4 Consultation Booking Flow

1. User memilih konsultan, layanan, dan slot.
2. Client meminta service membuat booking intent.
3. Service memanggil payment gateway candidate dan menunggu hasil pembayaran.
4. Setelah pembayaran valid, ConsultationSession menjadi `confirmed`.
5. Notification dikirim ke user dan consultant.
6. ConsentGrant untuk ClientVault dibuat hanya jika dibutuhkan sesi dan disetujui user.
7. Saat sesi selesai atau consent dicabut, akses consultant ke data tersebut berhenti.

```mermaid
sequenceDiagram
    participant U as User
    participant C as Mobile App
    participant A as Go Application Service
    participant Pay as Payment Gateway
    participant DB as Supabase
    participant Kons as Consultant App

    U->>C: Choose consultant, service, and slot
    C->>A: Create booking intent
    A->>Pay: Create payment request
    Pay-->>A: Payment success callback
    A->>DB: Mark ConsultationSession confirmed
    A->>DB: Create ConsentGrant if needed
    A->>DB: Create Notification for both parties
    A-->>C: Return confirmed booking
    C-->>Kons: Session becomes available
```

### 13.5 Notification Delivery Flow

1. Sistem mendeteksi event yang memerlukan notifikasi (bill due, draft baru, budget alert, booking update).
2. Notification Service mengevaluasi user preferences.
3. Jika user mengizinkan jenis notifikasi tersebut, Notification record dibuat.
4. In-app: realtime channel atau polling memberitahu client ada notifikasi baru.
5. User melihat badge count dan dapat membuka notification center.

```mermaid
sequenceDiagram
    participant S as System Event
    participant NS as Notification Service
    participant DB as Supabase
    participant M as Mobile App
    participant U as User

    S->>NS: Trigger event (bill_due, draft_new, budget_alert)
    NS->>DB: Check user notification preferences
    NS->>DB: Create Notification record
    DB-->>M: Realtime notification update
    M-->>U: Show badge and notification
    U->>M: Tap notification
    M->>M: Navigate via deep link
```

## 14. Draft To Final Transaction Lifecycle

| Source | Initial State | User Action | Result |
| --- | --- | --- | --- |
| AI input | `review_needed` | Confirm | Menjadi `Transaction` final |
| AI input | `review_needed` | Edit + Confirm | Draft diperbarui lalu menjadi `Transaction` final |
| AI input | `review_needed` | Cancel | Tidak menjadi transaksi final |
| Provider sync | `review_needed` | Confirm | Menjadi `Transaction` final |
| Provider sync | `review_needed` | Reject | Menjadi `rejected`, tidak memengaruhi saldo |

Aturan utama:

1. Tidak ada auto-commit dari AI atau provider sync.
2. Hanya Transaction final yang memengaruhi saldo utama.
3. DraftTransaction yang ditolak tetap dapat disimpan untuk audit sesuai kebijakan retensi.

```mermaid
stateDiagram-v2
    [*] --> review_needed
    review_needed --> review_needed: edit
    review_needed --> confirmed: confirm
    review_needed --> rejected: reject
    review_needed --> cancelled: cancel AI draft
    confirmed --> posted: create final transaction
```

## 15. Mock Contract Boundary

MockContract adalah boundary resmi antara frontend-only phase dan backend-integration phase.

### Rules

1. Frontend boleh membuat placeholder request and response shape.
2. MockContract dipakai untuk menguji flow UX, state transitions, dan screen logic.
3. Backend implementation tidak boleh dimulai sebelum MockContract disetujui untuk flow utama app surface aktif.
4. Saat backend phase dimulai, real API harus memetakan dirinya ke MockContract yang approved atau mendokumentasikan perubahan yang disetujui.

```mermaid
flowchart LR
    UI["Approved frontend flow"] --> Mock["MockContract approved"]
    Mock --> Backend["Backend implementation starts"]
    Backend --> RealAPI["Real API and integration"]
    RealAPI --> QA["End-to-end QA"]
```

## 16. Reliability, Idempotency, And Failure Handling

### Webhook And Provider Rules

1. Semua webhook provider wajib diverifikasi signature atau mekanisme autentikasi ekuivalen.
2. Event provider harus idempotent berdasarkan kombinasi provider event id, provider connection, dan fingerprint payload.
3. Retry dari provider tidak boleh membuat duplicate DraftTransaction.
4. Jika provider payload tidak valid, event ditolak dan dicatat dengan alasan.

### AI And Internal Processing Rules

1. Jika AI gagal merespons, user menerima error yang dapat ditangani dan tidak ada transaksi final yang dibuat.
2. Jika parsing AI sebagian berhasil, sistem boleh membuat draft parsial selama user masih diwajibkan review.
3. Rate limit ke AI dan provider dikelola di application service dengan dukungan Redis.

### Reconciliation Rules

1. Draft hasil sync yang sama tidak boleh mengurangi saldo dua kali.
2. ProviderConnection dengan error berulang harus berpindah ke `needs_reauth` atau `failed`.
3. Sync status harus dapat dibedakan antara sukses terakhir, gagal terakhir, dan proses sedang berjalan.

```mermaid
flowchart TD
    Webhook["Incoming provider webhook"] --> Verify["Verify signature"]
    Verify --> Dedup["Check duplicate fingerprint"]
    Dedup -->|Duplicate| Ignore["Ignore and log duplicate"]
    Dedup -->|New event| Normalize["Normalize payload"]
    Normalize --> SaveDraft["Save DraftTransaction"]
    SaveDraft --> UpdateConn["Update ProviderConnection status"]
    UpdateConn --> Notify["Notify client via realtime or poll"]
    UpdateConn --> NotifRecord["Create Notification record"]
```

## 17. Security And Compliance Controls

1. HaloFin tidak menyimpan username, PIN, atau password akun finansial pengguna.
2. Semua akses data harus dibatasi dengan role dan row-level access control.
3. Data sensitif dienkripsi in transit dan memanfaatkan enkripsi at-rest dari managed platform.
4. Deskripsi transaksi yang mengandung referensi sensitif harus disanitasi sebelum dipakai untuk analytics atau AI.
5. Semua akses consultant ke ClientVault harus berbasis ConsentGrant aktif dan tercatat.
6. Semua keputusan recommendation tunduk pada anti-speculation rule dari PRD.

Detail lebih lanjut tersedia di [Security.md](./Security.md).

## 18. Audit And Observability

### Audit Trail Minimum

1. Perubahan status DraftTransaction.
2. Pembuatan, aktivasi, dan pencabutan ConsentGrant.
3. Booking, pembayaran, dan perubahan status ConsultationSession.
4. Provider webhook yang diterima, ditolak, atau dianggap duplikat.
5. Aksi administratif seperti verifikasi konsultan.
6. Notification delivery events.

### Observability Minimum

1. Structured logging untuk semua call ke provider dan AI.
2. Metrics untuk sync success rate, AI parse success rate, webhook dedup rate, dan payment success rate.
3. Alert untuk lonjakan webhook failure, payment failure, atau AI latency tinggi.
4. Dashboard monitoring untuk notification delivery rate dan failure rate.

## 19. Deployment Topology

| Environment | Purpose | Notes |
| --- | --- | --- |
| Local | Pengembangan individual | Menggunakan managed service dev project atau sandbox, local Redis, dan stub provider bila perlu |
| Staging | Uji integrasi end-to-end | Harus menggunakan provider sandbox dan data non-produksi |
| Production | Aplikasi live | Semua secret dikelola di secret manager, observability aktif, audit retention berlaku |

## 20. Provider Decision Status

| Capability | Status | Decision Rule |
| --- | --- | --- |
| Financial data provider | Candidate | Pilih provider yang memenuhi coverage institusi target, keamanan, sandbox quality, webhook reliability, dan kepatuhan bisnis |
| Payment gateway | Candidate | Pilih provider dengan dukungan escrow atau flow pembayaran yang cocok untuk booking konsultasi |
| Video provider | Candidate | Hanya diperlukan jika sesi video dilakukan in-app pada MVP |
| AI provider | Selected at architecture level | Model name harus dikonfigurasi di runtime, bukan di-hardcode dalam dokumen ini |
| Currency rate provider | Candidate | Pilih provider dengan coverage IDR/USD, free tier untuk MVP, daily update minimum |

## 21. Architecture Risks To Track

1. Coverage provider finansial mungkin tidak merata antar institusi yang dibutuhkan user awal.
2. AI extraction quality untuk OCR dan bahasa natural bisa berbeda menurut kualitas input user.
3. Consent dan audit scope untuk consultant workflow harus direview bersama legal dan compliance sebelum launch.
4. Frontend contracts yang terlalu longgar dapat membuat fase backend ambigu jika tidak disetujui lebih awal.
5. Notification volume yang tinggi bisa menyebabkan user fatigue jika rules tidak diatur dengan baik.
6. Currency rate stale data bisa menyebabkan inaccurate total balance display.
