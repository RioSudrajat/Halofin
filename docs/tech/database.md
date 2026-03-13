# Database Strategy

| Field | Value |
| --- | --- |
| Project | HaloFin |
| Document Version | 1.0 |
| Status | Active |
| Last Updated | 2026-03-11 |

## 1. Purpose

Dokumen ini menjelaskan strategi database HaloFin, termasuk entity relationship model, migration strategy, indexing guidelines, seed data approach, dan backup policy.

ERD visual tersedia di [Architecture.md](./Architecture.md) Section 5. Data dictionary lengkap tersedia di [glossary.md](../glossary.md) Section 5.

## 2. Database Platform

| Aspect | Decision |
| --- | --- |
| Primary database | PostgreSQL (managed by Supabase) |
| Version | Record exact major version at Supabase project provisioning |
| Query layer | `sqlc` — type-safe SQL-first queries |
| Driver | `pgx/v5` |
| Row-Level Security | Mandatory for all user-facing tables |
| Extensions | Enable only when needed (see below) |

## 3. Schema Design Principles

1. **Normalized by default** — avoid denormalization unless proven performance requirement.
2. **UUID primary keys** — all tables use UUID v4 as primary key.
3. **Timestamps** — all tables include `created_at` (auto-generated) and `updated_at` (auto-updated).
4. **Soft delete preferred** — use `status` or `deleted_at` instead of hard delete for financial data.
5. **Enum as text** — store enums as text/varchar for flexibility, validate in application layer.
6. **Money as integer** — store monetary amounts as integer (smallest unit); avoid floating point.
7. **Currency explicit** — every monetary field has an associated `currency` field.

## 4. Core Tables

### User Table

```sql
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    avatar_url TEXT,
    preferred_currency TEXT NOT NULL DEFAULT 'IDR',
    onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE,
    notification_preferences JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Wallet Table

```sql
CREATE TABLE wallets (
    wallet_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('cash', 'bank', 'e_wallet', 'investment')),
    sync_mode TEXT NOT NULL DEFAULT 'manual' CHECK (sync_mode IN ('manual', 'auto')),
    currency TEXT NOT NULL DEFAULT 'IDR',
    balance BIGINT NOT NULL DEFAULT 0,
    icon_url TEXT,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_wallets_user_id ON wallets(user_id);
```

### Transaction Table

```sql
CREATE TABLE transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    wallet_id UUID NOT NULL REFERENCES wallets(wallet_id),
    type TEXT NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
    category TEXT NOT NULL,
    amount BIGINT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'IDR',
    description TEXT,
    transaction_date DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'posted' CHECK (status IN ('posted', 'voided')),
    source TEXT NOT NULL DEFAULT 'manual' CHECK (source IN ('manual', 'ai_draft', 'provider_sync')),
    transfer_to_wallet_id UUID REFERENCES wallets(wallet_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_wallet_id ON transactions(wallet_id);
CREATE INDEX idx_transactions_date ON transactions(user_id, transaction_date DESC);
CREATE INDEX idx_transactions_category ON transactions(user_id, category);
```

### Draft Transaction Table

```sql
CREATE TABLE draft_transactions (
    draft_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    wallet_id UUID REFERENCES wallets(wallet_id),
    type TEXT CHECK (type IN ('income', 'expense', 'transfer')),
    category TEXT,
    amount BIGINT,
    currency TEXT DEFAULT 'IDR',
    description TEXT,
    draft_date DATE,
    status TEXT NOT NULL DEFAULT 'review_needed' CHECK (status IN ('review_needed', 'confirmed', 'rejected', 'cancelled')),
    source TEXT NOT NULL CHECK (source IN ('ai_chat', 'ai_voice', 'ai_ocr', 'provider_sync')),
    provider_event_id TEXT,
    confidence_score REAL,
    raw_input TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_drafts_user_status ON draft_transactions(user_id, status);
CREATE UNIQUE INDEX idx_drafts_provider_event ON draft_transactions(provider_event_id) WHERE provider_event_id IS NOT NULL;
```

### Budget Table

```sql
CREATE TABLE budgets (
    budget_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    category TEXT NOT NULL,
    amount_limit BIGINT NOT NULL,
    period_type TEXT NOT NULL DEFAULT 'monthly' CHECK (period_type IN ('monthly', 'weekly')),
    period_start DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, category, period_start)
);
```

### Goal Table

```sql
CREATE TABLE goals (
    goal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    name TEXT NOT NULL,
    target_amount BIGINT NOT NULL,
    saved_amount BIGINT NOT NULL DEFAULT 0,
    target_date DATE,
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('normal', 'urgent')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'archived')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Bill Table

```sql
CREATE TABLE bills (
    bill_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    name TEXT NOT NULL,
    amount BIGINT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'IDR',
    due_date DATE NOT NULL,
    recurrence TEXT NOT NULL DEFAULT 'monthly' CHECK (recurrence IN ('monthly', 'weekly', 'one_time')),
    status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'paid', 'overdue')),
    auto_pay BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_bills_user_due ON bills(user_id, due_date);
```

### Notification Table

```sql
CREATE TABLE notifications (
    notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    type TEXT NOT NULL CHECK (type IN ('bill_reminder', 'draft_review', 'budget_alert', 'booking_update', 'system')),
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    deep_link TEXT,
    status TEXT NOT NULL DEFAULT 'unread' CHECK (status IN ('unread', 'read', 'dismissed', 'actioned')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_status ON notifications(user_id, status);
CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at DESC);
```

### Consultant Table

```sql
CREATE TABLE consultants (
    consultant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    name TEXT NOT NULL,
    specialization TEXT NOT NULL,
    bio TEXT,
    certifications JSONB NOT NULL DEFAULT '[]',
    rating REAL DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    hourly_rate BIGINT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'IDR',
    verification_status TEXT NOT NULL DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_consultants_status ON consultants(verification_status);
```

### Consultation Session Table

```sql
CREATE TABLE consultation_sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    consultant_id UUID NOT NULL REFERENCES consultants(consultant_id),
    service_type TEXT NOT NULL CHECK (service_type IN ('chat', 'video_call')),
    scheduled_at TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending_payment' CHECK (status IN ('pending_payment', 'confirmed', 'completed', 'cancelled')),
    payment_reference TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Consent Grant Table

```sql
CREATE TABLE consent_grants (
    consent_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    consultant_id UUID NOT NULL REFERENCES consultants(consultant_id),
    session_id UUID REFERENCES consultation_sessions(session_id),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'revoked', 'expired')),
    granted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ
);

CREATE INDEX idx_consent_active ON consent_grants(consultant_id, status) WHERE status = 'active';
```

### Provider Connection Table

```sql
CREATE TABLE provider_connections (
    connection_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    provider_name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'connected' CHECK (status IN ('connected', 'syncing', 'needs_reauth', 'failed')),
    last_sync_at TIMESTAMPTZ,
    last_sync_status TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Currency Rate Table

```sql
CREATE TABLE currency_rates (
    rate_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    base_currency TEXT NOT NULL,
    target_currency TEXT NOT NULL,
    rate NUMERIC(18, 8) NOT NULL,
    source TEXT NOT NULL,
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(base_currency, target_currency, fetched_at)
);

CREATE INDEX idx_currency_latest ON currency_rates(base_currency, target_currency, fetched_at DESC);
```

### Audit Log Table

```sql
CREATE TABLE audit_logs (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id),
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    old_value JSONB,
    new_value JSONB,
    ip_address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_user ON audit_logs(user_id, created_at DESC);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
```

## 5. Row-Level Security (RLS) Strategy

| Table | Policy | Rule |
| --- | --- | --- |
| `wallets` | User can only access own wallets | `user_id = auth.uid()` |
| `transactions` | User can only access own transactions | `user_id = auth.uid()` |
| `draft_transactions` | User can only access own drafts | `user_id = auth.uid()` |
| `budgets` | User can only access own budgets | `user_id = auth.uid()` |
| `goals` | User can only access own goals | `user_id = auth.uid()` |
| `bills` | User can only access own bills | `user_id = auth.uid()` |
| `notifications` | User can only access own notifications | `user_id = auth.uid()` |
| `consultation_sessions` | User sees own sessions; consultant sees assigned sessions | Role-based policy |
| `consent_grants` | User and associated consultant only | Cross-reference user_id and consultant_id |
| `consultants` | Public read for verified; full access for own profile | `verification_status = 'verified'` for public |

## 6. Migration Strategy

Refer to [Backend.md](./Backend.md) Section 6 for migration tool, naming convention, and process.

## 7. Seed Data

| Environment | What To Seed | How |
| --- | --- | --- |
| Local/Dev | Sample user, wallets, transactions, consultants, categories | SQL seed file run manually or via script |
| Staging | Realistic test data (anonymized) | CI pipeline, refreshed periodically |
| Production | Default category list only | Initial migration |

### Default Categories

```
Income: salary, freelance, investment_return, gift, other_income
Expense: food_and_drink, transport, entertainment, shopping, health, education, bills_and_utilities, personal_care, other_expense
Transfer: (no category — transfer is between wallets)
```

## 8. Backup And Recovery

| Aspect | Policy |
| --- | --- |
| Automated backup | Daily, managed by Supabase |
| Retention | 30 days minimum |
| Point-in-time recovery | Enabled via Supabase (WAL-based) |
| Manual backup | Before major migrations |
| Recovery testing | Quarterly dry-run restore to staging |

## 9. Extensions

| Extension | Purpose | Status |
| --- | --- | --- |
| `pgvector` | Vector similarity search for AI features | Deferred — enable when AI-assisted search is needed |
| `pg_cron` | Scheduled jobs (bill reminders, sync schedules) | Deferred — use application-level cron first |
| `pg_trgm` | Fuzzy text search for consultant/transaction search | Consider for MVP — improves search quality |
