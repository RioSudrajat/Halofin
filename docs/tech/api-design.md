# API Design Guidelines

| Field | Value |
| --- | --- |
| Project | HaloFin |
| Document Version | 1.0 |
| Status | Active |
| Last Updated | 2026-03-11 |

## 1. Purpose

Dokumen ini menetapkan konvensi desain API untuk Go Application Service HaloFin. Semua endpoint yang menghadap client harus mengikuti standar ini agar konsisten, predictable, dan mudah di-consume oleh semua app surfaces.

## 2. General Principles

1. **RESTful design** — resource-oriented URLs, standard HTTP methods.
2. **Consistent naming** — snake_case untuk JSON fields, lowercase plural untuk resource paths.
3. **Stateless** — setiap request membawa semua informasi yang diperlukan (via JWT).
4. **Version-aware** — API prefix dengan version number.
5. **Contract-first** — API harus sesuai dengan approved MockContracts.

## 3. Base URL Pattern

```
{base_url}/api/v1/{resource}
```

Example:
```
https://api.halofin.id/api/v1/wallets
https://api.halofin.id/api/v1/transactions
```

## 4. HTTP Methods

| Method | Usage | Idempotent |
| --- | --- | --- |
| `GET` | Read resources | Yes |
| `POST` | Create new resource | No |
| `PUT` | Full update of resource | Yes |
| `PATCH` | Partial update of resource | Yes |
| `DELETE` | Soft-delete or remove resource | Yes |

## 5. URL Naming Conventions

### Rules

1. Use lowercase, plural nouns for resources.
2. Use hyphens for multi-word resources.
3. Nest resources max 2 levels deep.
4. Actions that don't map to CRUD use POST with verb suffix.

### Examples

```
GET    /api/v1/wallets                          # List wallets
GET    /api/v1/wallets/institutions             # List supported institutions for sync
GET    /api/v1/wallets/{wallet_id}              # Get wallet detail
POST   /api/v1/wallets                          # Create wallet manual
POST   /api/v1/wallets/connect                  # Connect auto-sync wallet
PATCH  /api/v1/wallets/{wallet_id}              # Update wallet
DELETE /api/v1/wallets/{wallet_id}              # Archive wallet

GET    /api/v1/transactions                     # List transactions (with filters)
POST   /api/v1/transactions                     # Create transaction
GET    /api/v1/transactions/{transaction_id}    # Get transaction detail

POST   /api/v1/drafts/{draft_id}/confirm        # Confirm draft (action)
POST   /api/v1/drafts/{draft_id}/reject         # Reject draft (action)

GET    /api/v1/reports/monthly                  # Get monthly report
GET    /api/v1/reports/category-breakdown       # Get category breakdown

GET    /api/v1/notifications                    # List notifications
PATCH  /api/v1/notifications/{id}/read          # Mark as read
PUT    /api/v1/notifications/preferences        # Update preferences

GET    /api/v1/consultants                      # List consultants
GET    /api/v1/consultants/{id}                 # Get consultant detail

POST   /api/v1/bookings                         # Create booking
GET    /api/v1/sessions                         # List active/past branch sessions (My Orders)
GET    /api/v1/sessions/{session_id}            # Get session details

POST   /api/v1/exports/csv                      # Trigger CSV export
POST   /api/v1/exports/pdf                      # Trigger PDF export

GET    /api/v1/currency/rates                   # Get current rates
POST   /api/v1/users/goals                      # Setup financial goals (Onboarding)
```

## 6. Request Format

### Headers

| Header | Required | Value |
| --- | --- | --- |
| `Authorization` | Yes (except public) | `Bearer {access_token}` |
| `Content-Type` | Yes (for POST/PUT/PATCH) | `application/json` |
| `Accept` | Recommended | `application/json` |
| `X-Request-ID` | Recommended | UUID — for tracing |

### Request Body (JSON)

```json
{
  "wallet_id": "uuid-here",
  "type": "expense",
  "category": "food_and_drink",
  "amount": 85000,
  "currency": "IDR",
  "description": "Lunch at restaurant",
  "date": "2026-03-11"
}
```

Rules:
1. Use `snake_case` for all field names.
2. Amounts are integers in smallest unit (IDR: already integer, USD: cents).
3. Dates use ISO 8601 format (`YYYY-MM-DD`).
4. Timestamps use ISO 8601 with timezone (`2026-03-11T14:30:00+07:00`).

## 7. Response Format

### Success Response

```json
{
  "data": {
    "transaction_id": "uuid-here",
    "amount": 85000,
    "currency": "IDR",
    "created_at": "2026-03-11T14:30:00+07:00"
  },
  "meta": {
    "request_id": "req_abc123"
  }
}
```

### List Response (with Pagination)

```json
{
  "data": [
    { "wallet_id": "uuid-1", "name": "BCA", "balance": 8545000 },
    { "wallet_id": "uuid-2", "name": "GoPay", "balance": 350000 }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total_items": 45,
    "total_pages": 3,
    "has_next": true
  },
  "meta": {
    "request_id": "req_def456"
  }
}
```

### Error Response

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Amount must be greater than zero",
    "details": [
      {
        "field": "amount",
        "reason": "must be positive"
      }
    ],
    "request_id": "req_abc123"
  }
}
```

## 8. Pagination

| Parameter | Type | Default | Max | Description |
| --- | --- | --- | --- | --- |
| `page` | Integer | 1 | — | Page number (1-indexed) |
| `per_page` | Integer | 20 | 100 | Items per page |

### Usage

```
GET /api/v1/transactions?page=2&per_page=20
```

For cursor-based pagination (if needed for real-time feeds):

```
GET /api/v1/notifications?cursor=abc123&limit=20
```

## 9. Filtering And Sorting

### Filter Parameters

```
GET /api/v1/transactions?wallet_id=uuid&category=food_and_drink&date_from=2026-03-01&date_to=2026-03-31&type=expense
```

### Sort Parameters

```
GET /api/v1/transactions?sort_by=date&sort_order=desc
```

| Parameter | Values | Default |
| --- | --- | --- |
| `sort_by` | Field name (e.g., `date`, `amount`, `created_at`) | `created_at` |
| `sort_order` | `asc`, `desc` | `desc` |

## 10. Error Codes

| Code | HTTP Status | When To Use |
| --- | --- | --- |
| `VALIDATION_ERROR` | 400 | Request body fails validation |
| `INVALID_PARAMETER` | 400 | Query parameter invalid |
| `UNAUTHORIZED` | 401 | Missing or invalid auth token |
| `TOKEN_EXPIRED` | 401 | Access token expired |
| `FORBIDDEN` | 403 | Authenticated but insufficient permissions |
| `NOT_FOUND` | 404 | Resource does not exist or not owned by user |
| `CONFLICT` | 409 | Duplicate resource or conflicting state transition |
| `DRAFT_ALREADY_PROCESSED` | 409 | Draft already confirmed/rejected |
| `RATE_LIMITED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Unexpected server-side error |
| `AI_PROVIDER_ERROR` | 502 | AI provider failure |
| `SYNC_PROVIDER_ERROR` | 502 | Financial data provider failure |
| `PAYMENT_PROVIDER_ERROR` | 502 | Payment gateway failure |
| `SERVICE_UNAVAILABLE` | 503 | Service temporarily down |

## 11. Rate Limiting

| Endpoint Category | Rate Limit | Window |
| --- | --- | --- |
| Standard read (GET) | 100 requests | Per minute per user |
| Standard write (POST/PATCH) | 30 requests | Per minute per user |
| AI endpoints | 10 requests | Per minute per user |
| Export endpoints | 5 requests | Per hour per user |
| Public endpoints (health) | 60 requests | Per minute per IP |

Rate limit headers returned on every response:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1710123456
```

When rate limited, return `429` with `Retry-After` header.

## 12. Versioning

1. API version in URL path: `/api/v1/`.
2. Breaking changes require new version (`v2`).
3. Non-breaking additions (new optional fields, new endpoints) do NOT require version bump.
4. Old versions deprecated with minimum 3-month notice.
5. For MVP, only `v1` exists.

## 13. API Documentation (Swagger/OpenAPI)

1. **Swagger / OpenAPI 3.0** adalah standar wajib untuk dokumentasi semua kontrak API HaloFin.
2. Spec file OpenAPI harus di-maintain dalam repository backend (contoh: `docs/swagger.yaml` atau menggunakan auto-generation tools seperti `swaggo/swag` di Go).
3. **Swagger UI** harus tersedia secara interaktif di environment *development* dan *staging* pada *path* `/api/docs` atau `/swagger/index.html`.
4. Swagger UI ini akan digunakan oleh *Frontend Developer* dan *Mobile Developer* sebagai *Single Source of Truth* untuk mock data dan struktur response API selama fase pengembangan.
5. Akses ke Swagger UI harus di-disable di environment *production* demi keamanan.
