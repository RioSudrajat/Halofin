# HaloFin Glossary And Data Dictionary

| Field | Value |
| --- | --- |
| Project | HaloFin |
| Document Version | 1.0 |
| Status | Active |
| Last Updated | 2026-03-11 |

## 1. Purpose

Dokumen ini adalah referensi tunggal untuk semua istilah kanonikal dan definisi data yang digunakan di seluruh dokumen produk dan teknis HaloFin. Jika ada ambiguitas istilah, dokumen ini menjadi source of truth.

## 2. Canonical Product Terms

| Term | Definition | Context |
| --- | --- | --- |
| Wallet | Tempat penyimpanan saldo yang dilihat pengguna. Bisa berupa cash, rekening bank, e-wallet, atau akun investasi. | Core Tracker |
| Transaction | Catatan finansial final yang sudah dikonfirmasi pengguna dan memengaruhi saldo wallet. | Core Tracker |
| DraftTransaction | Hasil input AI atau sinkronisasi eksternal yang masih menunggu review pengguna. Belum memengaruhi saldo. | AI Quick Actions, Auto Sync |
| ProviderConnection | Hubungan aktif antara akun pengguna dan provider data finansial pihak ketiga. | Auto Sync |
| Recommendation | Saran kontekstual yang muncul berdasarkan kondisi wallet atau profil pengguna. Bersifat edukatif. | Smart Recommendation |
| ConsultationSession | Sesi layanan antara pengguna dan konsultan, termasuk chat atau video call. | Consultant Marketplace |
| ClientVault | Ringkasan data finansial pengguna yang dapat diakses konsultan hanya selama consent aktif. | Consultant Marketplace |
| ConsentGrant | Izin eksplisit dari pengguna yang memperbolehkan konsultan mengakses data tertentu. | Consultant Marketplace |
| Idle Cash | Dana pada wallet yang dianggap mengendap dan layak diberi nudge sesuai aturan produk. | Smart Recommendation |
| Report | Ringkasan analitik keuangan pengguna berdasarkan periode, kategori, atau wallet. | Reporting & Analytics |
| Notification | Pesan proaktif dari sistem ke pengguna tentang event finansial yang membutuhkan perhatian. | Notification System |
| OnboardingFlow | Rangkaian langkah pertama kali saat pengguna baru mendaftar dan menyiapkan akun. | Onboarding |

## 3. Canonical Delivery Terms

| Term | Definition |
| --- | --- |
| AppSurface | Salah satu aplikasi produk: `mobile`, `admin`, `consultant`, atau `landing`. |
| DeliveryPhase | Fase delivery resmi yang dikerjakan tim pada urutan implementasi tertentu. |
| MockContract | Bentuk request/response placeholder yang dipakai frontend selama fase frontend-only sebelum real API diimplementasikan. |
| Frontend-Only Phase | Fase saat UI dan mock state dikerjakan tanpa backend implementation. |
| Backend-Integration Phase | Fase saat backend, auth, database, dan provider integration mulai dikerjakan. |

## 4. Canonical Status Values

### Transaction Lifecycle

| Object | Status | Meaning |
| --- | --- | --- |
| Transaction | `posted` | Transaksi final yang memengaruhi saldo |
| Transaction | `voided` | Transaksi yang dibatalkan setelah posting |
| DraftTransaction | `review_needed` | Menunggu user review |
| DraftTransaction | `confirmed` | User mengonfirmasi, siap jadi Transaction |
| DraftTransaction | `rejected` | User menolak, tidak memengaruhi saldo |
| DraftTransaction | `cancelled` | User membatalkan AI draft |

### Wallet

| Status | Meaning |
| --- | --- |
| `active` | Wallet aktif dan terlihat di daftar utama |
| `archived` | Wallet diarsipkan, tidak muncul di view utama |

### ProviderConnection

| Status | Meaning |
| --- | --- |
| `connected` | Koneksi aktif dan siap sync |
| `syncing` | Sedang dalam proses sinkronisasi |
| `needs_reauth` | Perlu re-autentikasi dari user |
| `failed` | Koneksi gagal, perlu investigasi |

### Recommendation

| Status | Meaning |
| --- | --- |
| `eligible` | Recommendation siap ditampilkan |
| `dismissed` | User menutup nudge |
| `clicked` | User klik untuk detail lebih lanjut |

### ConsultationSession

| Status | Meaning |
| --- | --- |
| `pending_payment` | Menunggu pembayaran |
| `confirmed` | Pembayaran berhasil, sesi terkonfirmasi |
| `completed` | Sesi selesai |
| `cancelled` | Sesi dibatalkan |

### ConsentGrant

| Status | Meaning |
| --- | --- |
| `active` | Consent aktif, konsultan bisa akses data |
| `revoked` | Dicabut oleh user |
| `expired` | Kadaluarsa otomatis |

### MockContract

| Status | Meaning |
| --- | --- |
| `draft` | Masih dalam development |
| `approved` | Disetujui sebagai acuan backend |
| `implemented` | Sudah dipetakan ke real API |

### Notification

| Status | Meaning |
| --- | --- |
| `unread` | Belum dibaca user |
| `read` | Sudah dibaca user |
| `dismissed` | User dismiss tanpa action |
| `actioned` | User melakukan aksi dari notifikasi |

## 5. Data Dictionary — Core Entities

### User

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| user_id | UUID | Yes | Primary identifier |
| email | String | Yes | Login credential |
| display_name | String | Yes | Nama tampilan |
| avatar_url | String | No | URL foto profil |
| preferred_currency | String | Yes | Default IDR |
| onboarding_completed | Boolean | Yes | Status onboarding |
| notification_preferences | JSON | Yes | Preferensi notifikasi |
| created_at | Timestamp | Yes | Waktu registrasi |

### Wallet

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| wallet_id | UUID | Yes | Primary identifier |
| user_id | UUID (FK) | Yes | Pemilik wallet |
| name | String | Yes | Nama wallet (misal: BCA, GoPay) |
| type | Enum | Yes | cash, bank, e-wallet, investment |
| currency | String | Yes | Default IDR |
| balance | Decimal | Yes | Saldo saat ini |
| icon_url | String | No | Ikon custom |
| status | Enum | Yes | active, archived |
| created_at | Timestamp | Yes | Waktu pembuatan |

### Transaction

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| transaction_id | UUID | Yes | Primary identifier |
| user_id | UUID (FK) | Yes | Pemilik transaksi |
| wallet_id | UUID (FK) | Yes | Wallet terkait |
| type | Enum | Yes | income, expense, transfer |
| category | String | Yes | Kategori transaksi |
| amount | Decimal | Yes | Nominal |
| currency | String | Yes | Mata uang transaksi |
| description | String | No | Catatan user |
| date | Date | Yes | Tanggal transaksi |
| status | Enum | Yes | posted, voided |
| source | Enum | Yes | manual, ai_draft, provider_sync |
| created_at | Timestamp | Yes | Waktu pembuatan |

### DraftTransaction

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| draft_id | UUID | Yes | Primary identifier |
| user_id | UUID (FK) | Yes | Pemilik draft |
| wallet_id | UUID (FK) | No | Wallet terkait (bisa null saat AI parsing) |
| type | Enum | No | income, expense, transfer |
| category | String | No | Kategori yang di-suggest |
| amount | Decimal | No | Nominal yang di-extract |
| description | String | No | Deskripsi raw |
| date | Date | No | Tanggal yang di-extract |
| status | Enum | Yes | review_needed, confirmed, rejected, cancelled |
| source | Enum | Yes | ai_chat, ai_voice, ai_ocr, provider_sync |
| provider_event_id | String | No | ID event dari provider (untuk dedup) |
| confidence_score | Float | No | Confidence AI parsing |
| created_at | Timestamp | Yes | Waktu pembuatan |

### Budget

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| budget_id | UUID | Yes | Primary identifier |
| user_id | UUID (FK) | Yes | Pemilik budget |
| category | String | Yes | Kategori budget |
| amount_limit | Decimal | Yes | Batas anggaran |
| period_type | Enum | Yes | monthly, weekly |
| period_start | Date | Yes | Awal periode |
| spent_amount | Decimal | Yes | Total terpakai (computed) |

### Goal

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| goal_id | UUID | Yes | Primary identifier |
| user_id | UUID (FK) | Yes | Pemilik goal |
| name | String | Yes | Nama goal |
| target_amount | Decimal | Yes | Target tabungan |
| saved_amount | Decimal | Yes | Jumlah tersimpan |
| target_date | Date | No | Target tanggal tercapai |
| priority | Enum | No | normal, urgent |

### Bill

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| bill_id | UUID | Yes | Primary identifier |
| user_id | UUID (FK) | Yes | Pemilik tagihan |
| name | String | Yes | Nama tagihan |
| amount | Decimal | Yes | Nominal tagihan |
| due_date | Date | Yes | Tanggal jatuh tempo |
| recurrence | Enum | Yes | monthly, weekly, one_time |
| status | Enum | Yes | upcoming, paid, overdue |
| auto_pay | Boolean | Yes | Apakah auto-pay |

### Notification

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| notification_id | UUID | Yes | Primary identifier |
| user_id | UUID (FK) | Yes | Penerima notifikasi |
| type | Enum | Yes | bill_reminder, draft_review, budget_alert, booking_update, system |
| title | String | Yes | Judul notifikasi |
| body | String | Yes | Isi notifikasi |
| deep_link | String | No | Route tujuan saat di-tap |
| status | Enum | Yes | unread, read, dismissed, actioned |
| created_at | Timestamp | Yes | Waktu pembuatan |

## 6. Supported Currencies

| Code | Name | Status |
| --- | --- | --- |
| IDR | Indonesian Rupiah | Active (default) |
| USD | US Dollar | Active |

Currency lain ditambahkan berdasarkan demand setelah MVP launch.
