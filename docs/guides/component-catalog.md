# Mobile Component Catalog

| Field | Value |
| --- | --- |
| Project | HaloFin |
| Last Updated | 2026-03-11 |
| Source | Aggregated from [Frontend.md](../tech/Frontend.md) screen specs |

## 1. Purpose

Dokumen ini mengumpulkan semua reusable components yang teridentifikasi dari screen specs di Frontend.md ke dalam satu katalog tunggal. Tujuannya agar engineer tidak membuat komponen duplikat dan dapat melihat semua building blocks sebelum memulai slicing.

## 2. Navigation Components

| Component | Used In | Description |
| --- | --- | --- |
| `component_bottom_nav` | All main screens | Bottom navigation bar with 5 items: Home, Budget, Add (+), Consult, Wallet. Active state per route. |
| `component_back_header` | Transaction history, detail screens | Top bar with back button and title |
| `component_centered_title_header` | Consult list | Centered title with action icon |

## 3. Header Components

| Component | Used In | Description |
| --- | --- | --- |
| `component_user_header` | Home | Greeting with user name, avatar, notification icon |
| `component_month_header` | Wallet, Budget, Goals, Bills | Period label with optional action buttons |
| `component_modal_header` | Transaction entry | Close (X) button, title, upload action |

## 4. Card Components

| Component | Used In | Description | Variants |
| --- | --- | --- | --- |
| `component_total_balance_card` | Home | Hero card showing total balance with portfolio split and wallet type chips | — |
| `component_asset_distribution_card` | Wallet | Donut chart showing asset distribution with total balance | — |
| `component_consultant_card` | Consult list | Consultant card with name, title, tags, price, rating, and schedule CTA | Active CTA, disabled/fully booked, mini (home) |
| `component_consultant_mini_card` | Home (expert help) | Compact consultant card for home preview | — |
| `component_budget_summary_card` | Home, Budget | Budget progress with progress bar, total, remaining | Compact (home), full (budget) |
| `component_budget_overview_card` | Budget | Full budget overview with total, remaining, percentage | — |
| `component_budget_category_card` | Budget | Individual category budget with spent, remaining, progress | Normal, over-limit |
| `component_goal_card` | Goals | Goal progress with name, percentage, saved amount, timeline | Normal, urgent |
| `component_bills_summary_card` | Bills | Total bills overview with paid/remaining progress | — |
| `component_wallet_card` | Wallet | Individual wallet card with name, balance, progress indicator | With logo, with initials |
| `component_smart_tip_card` | Goals | AI-generated financial tip | — |
| `component_review_card` | Consult detail | User review quote card | — |
| `component_profile_hero_header` | Consult detail | Hero section with portrait, name, title, verified badge, stats | — |
| `component_accordion_card` | Consult detail | Expandable card for expertise, certificates, education, experience | Collapsed, expanded |

## 5. List Item Components

| Component | Used In | Description |
| --- | --- | --- |
| `component_recent_transaction_row` | Home | Compact transaction row with icon, name, amount |
| `component_transaction_history_row` | Transaction history | Full transaction row with time, category, merchant, amount |
| `component_transaction_group_header` | Transaction history | Date group header (TODAY, YESTERDAY, etc.) |
| `component_upcoming_bill_row` | Bills | Upcoming bill with name, amount, due info, pay CTA |
| `component_paid_bill_row` | Bills | Paid bill compact row |
| `component_stat_item` | Consult detail | Single stat (clients, rating, experience) |

## 6. Input And Form Components

| Component | Used In | Description |
| --- | --- | --- |
| `component_search_input` | Consult list, Transaction history | Search bar with placeholder text |
| `component_large_amount_display` | Transaction entry | Large formatted amount with currency prefix |
| `component_category_selector_row` | Transaction entry | Category dropdown/selector |
| `component_notes_textarea` | Transaction entry | Multiline notes input |
| `component_wallet_chip` | Transaction entry | Selectable wallet chip in form |

## 7. Chip And Tab Components

| Component | Used In | Description |
| --- | --- | --- |
| `component_filter_chip` | Consult list, Transaction history, Wallet | Filterable category chip (All, Tax, Investment, etc.) |
| `component_finance_tabs` | Budget, Goals, Bills | Segmented tab switcher: Goals / Budget / Bills |
| `component_transaction_type_pill` | Transaction entry | Type selector pill: Pengeluaran / Pemasukan / Transfer |
| `component_wallet_filter_chip` | Wallet | Wallet type filter: Semua / E-Wallet / Bank / Investasi |
| `component_skill_chip` | Consult detail | Read-only skill/expertise tag |

## 8. CTA And Action Components

| Component | Used In | Description |
| --- | --- | --- |
| `component_sticky_cta_bar` | Consult detail | Fixed bottom bar with price and booking button |
| `component_quick_action_item` | Home | Quick action icon button (Budget, History, Score, Report, Bills) |
| `component_match_expert_banner` | Consult list | Promotional banner for AI expert matching |
| `component_ai_assist_banner` | Transaction entry | Banner suggesting AI-assisted input |
| `component_swipe_finish_hint` | Transaction entry | "Swipe up to finish" gesture hint |
| `component_add_wallet_tile` | Wallet | "Add New Wallet/Asset" tile in wallet grid |
| `component_create_goal_tile` | Goals | "Create New Goal" tile in goal grid |

## 9. Badge And Status Components

| Component | Used In | Description |
| --- | --- | --- |
| `component_verified_badge` | Consult detail | Verified consultant badge |
| `component_progress_bar` | Budget, Bills, Goals | Horizontal progress bar with percentage |
| `component_in_out_summary` | Transaction history | Total in/out summary row |
| `component_notification_badge` | Home header | Unread notification count badge |

## 10. State Components

| Component | Applied To | Description |
| --- | --- | --- |
| `state_loading_skeleton` | All screens | Shimmer/skeleton placeholder during loading |
| `state_empty_placeholder` | Lists with no data | Illustration with message and optional CTA |
| `state_error_card` | All screens | Error message with retry button |

## 11. Design Tokens Reference

| Token | Value | Usage |
| --- | --- | --- |
| Font family | Manrope | All text |
| Primary accent | Lime green (#C5F536 approx) | CTAs, active states, progress bars |
| Card border radius | Large (16-20px) | All cards |
| Card shadow | Soft, low elevation | Content cards |
| Spacing unit | 4px base grid | All spacing |
| Theme | Light (primary) | Default theme |

## 12. Implementation Priority

Build components in this order to maximize reuse:

1. `component_bottom_nav` — used everywhere
2. `component_month_header` — shared across Budget/Goals/Bills/Wallet
3. `component_finance_tabs` — shared across Budget/Goals/Bills
4. `component_filter_chip` — shared across Consult/History/Wallet
5. `component_search_input` — shared across Consult/History
6. `component_progress_bar` — shared across Budget/Bills/Goals
7. Screen-specific cards (wallet, consultant, budget category, etc.)
8. Form components (transaction entry)
9. State components (loading, empty, error)
