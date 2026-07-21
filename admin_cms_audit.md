# Kingdom Heirs Platform — Production Admin CMS Architecture Audit

> **Document type:** Architectural audit (read-only). No code is being modified.
> **Date:** 2026-07-15
> **Scope:** Full Flutter codebase, Supabase schema, migrations, repositories, providers, services, Edge Functions, feature modules.
> **Output target:** Production-ready Admin CMS blueprint for the Kingdom Heirs platform.

---

## 0. Executive Summary

The Kingdom Heirs platform is a multi-tenant, multilingual church and discipleship app built on Flutter + Supabase. The backend is feature-rich but the Admin CMS is **incomplete**: roughly 40 % of the production schema is currently manageable from a CMS screen, and the rest is either unmanaged, statically hard-coded, or mutated only via direct DB access. The 90-Day Devotional system, the global Prayer Wall, the YouTube media pipeline, and the Prayer Moderation workflow are the only end-to-end managed features today.

This audit catalogues every feature in the platform, assigns each one a CMS-management profile (CRUD / read-only / moderated / scheduled / versioned / archived / translated / analytics-enabled / role-restricted / workflow-approval), and produces the design for the production Admin CMS: navigation, permissions matrix, workflows, missing tables, missing features, and a production-readiness score.

| Item | Status |
| --- | --- |
| **Backend schema maturity** | **High** — 30+ migrations, 90+ tables, RLS throughout, idempotent recent migration set. |
| **Admin CMS coverage (functional)** | **Medium-Low** — 12 admin screens, 8 of which are partly-mocked or hard-coded. |
| **Roles & permissions** | **Low** — binary `is_admin()` only. No `app_role` enum, no `user_roles` table. |
| **Workflow support** | **Medium** — prayer moderation and devotionals have approval flows. Most other content does not. |
| **Audit logging** | **Write side complete, read side missing.** |
| **i18n & translation pipeline** | **Strong** on schema, **weak** on tooling. |
| **Production readiness score** | **64 / 100** — see §11. |

---

## 1. CMS Module List (Complete)

Each row is a discrete module of the platform. **Req. CMS** indicates whether the module must be manageable from the Admin CMS in production. The **Operations** columns list what a CMS must support for that module.

Legend: **C**=Create, **R**=Read, **U**=Update, **D**=Delete, **S**=Status (publish/draft/archive), **Sch**=Schedule, **V**=Version, **T**=Translate, **Mod**=Moderate, **An**=Analytics, **RR**=Role-restricted, **Wf**=Approval workflow.

| # | Module | Purpose | Req. CMS | Operations | Deps | Roles Allowed | Priority |
|---|---|---|---|---|---|---|---|
| 1 | Authentication | Supabase Auth, email/password + Google OAuth | No (managed by Auth provider) | — | `auth.users` | System | — |
| 2 | Users / Profiles | Identity, role, language, country, soft-delete | **Yes** | C, R, U, S, D-soft | `profiles`, `auth.users` | Super Admin, Admin | P0 |
| 3 | Roles & Permissions | `is_admin()`, `is_leader()`, leader levels | **Yes (limited)** | R | `app_metadata.role`, `profiles.role` | Super Admin | P0 |
| 4 | User Devices & Installations | Push tokens, platform, version | **Yes (read)** | R | `user_devices`, `app_installations` | Admin | P2 |
| 5 | Dashboard (Stats) | DAU/WAU/MAU, online users, donation totals | **Yes (read)** | R, Export-CSV | `view_*` analytics views | Admin, Support | P0 |
| 6 | Featured Content | Home-screen cards, Explore tiles | **Yes** | C, R, U, D, S, Sch | `home_dashboard_state`, `featured_content` (missing) | Content Editor, Admin | P0 |
| 7 | Today's Walk | Daily verse + prayer + reflection | **Yes** | C, R, U, Sch | `daily_verses`, `daily_journey_tasks` | Content Editor | P0 |
| 8 | 90-Day Challenge | Primary devotional challenge | **Yes** | C, R, U, S, T, An, Wf | `devotional_series` (primary flag) | Content Editor, Admin | P0 |
| 9 | Devotional Series | Multilingual 90-day curricula | **Yes** | C, R, U, S, T | `devotional_series` | Content Editor, Translator, Admin | P0 |
| 10 | Devotional Days | Per-day entries (scripture, body, reflection, prayer, action) | **Yes** | C, R, U, S, T, V, Wf | `devotional_entries` | Content Editor, Translator, Admin | P0 |
| 11 | Translations | Per-language overlay of devotionals | **Yes** | C, R, U, S, Wf | `devotional_translations` | Translator, Content Editor, Admin | P0 |
| 12 | Prayer Requests | User-submitted prayer needs | **Yes (read-only after moderation)** | R, An | `prayer_requests` | Prayer Moderator, Admin | P0 |
| 13 | Prayer Wall Moderation | 3-state workflow: pending → approved/rejected | **Yes** | R, U, Wf | `prayer_requests` (RPCs) | Prayer Moderator, Admin | P0 |
| 14 | Testimonies | User-submitted stories with media | **Yes** | R, U, Mod | `testimonies` | Prayer Moderator, Admin | P0 |
| 15 | Sermons | Sermon catalogue (title, video URL, speaker, date) | **Yes (CRUD partial)** | C, R, U, D, S, T | `sermons`, `sermon_series` | Content Editor, Admin | P0 |
| 16 | Sermon Notes / Bookmarks | Per-user notes on sermons | No (user-owned) | — | `sermon_notes`, `sermon_bookmarks` | — | — |
| 17 | Podcasts | Podcast feed & episodes | **Yes (missing UI)** | C, R, U, D | `podcasts`, `podcast_episodes` | Content Editor | P1 |
| 18 | Live Service | Live stream metadata + chat moderation | **Yes (partial)** | C, R, U, Mod, Sch | `live_services`, `live_chat_messages` | Admin, Media Manager | P1 |
| 19 | Events | Calendar, registration, tickets | **Yes (CRUD partial)** | C, R, U, D, S, Sch | `events`, `tickets` | Events Manager, Admin | P0 |
| 20 | Giving / Donations | Donation records, recurring mandates | **Yes (read-only)** | R, Refund, An, Export | `donations`, `recurring_mandates`, `payment_webhooks_log` | Admin, Finance | P0 |
| 21 | Resources | Curated resource library | **Yes (missing UI)** | C, R, U, D, T | `resources` (missing — see §7) | Content Editor | P1 |
| 22 | Books | Bookstore catalogue | **Yes (missing UI)** | C, R, U, D | `bookstore_products`, `bookstore_inventory` | Content Editor | P2 |
| 23 | Amazon Links | Affiliate links for books (default URL on series) | **Yes (per-series field)** | U | `devotional_series.amazon_purchase_url` | Content Editor | P2 |
| 24 | Bible Reading Plans | Plans + daily readings | **Yes (missing UI)** | C, R, U, D, T | `reading_plans`, `reading_plan_days` | Content Editor | P1 |
| 25 | Discipleship Pathways | Curriculum paths (Vessel School) | **Yes (missing UI)** | C, R, U, D, T | (missing tables — see §7) | Content Editor | P1 |
| 26 | Lessons | Lesson content within pathways | **Yes (missing UI)** | C, R, U, D, T, V | `lessons` (missing) | Content Editor | P1 |
| 27 | Groups | Community groups + memberships | **Yes (missing UI)** | C, R, U, D, Mod | `groups`, `group_memberships`, `group_messages` | Admin, Group Leader | P0 |
| 28 | Group Reports | Salvation/baptism/attendance submissions | **Yes (read + workflow)** | R, U, An, Wf | `group_reports` | Admin, Group Leader | P1 |
| 29 | Notifications | User-targeted push + in-app | **Yes (composer missing)** | C, R, U, Sch | `push_subscriptions`, `notification_router` | Admin, Communications | P1 |
| 30 | Announcements | Global church announcements | **Yes (UI missing)** | C, R, U, D, S, Sch, T | `announcements` | Content Editor, Admin | P0 |
| 31 | Home Screen Cards | Card order, visibility, weight | **Yes (UI missing)** | C, R, U, D | `home_dashboard_state` | Content Editor, Admin | P1 |
| 32 | Explore Screen | Explore-page configuration | **Yes (UI missing)** | C, R, U | `explore_config` (missing) | Content Editor, Admin | P2 |
| 33 | Vision | Static vision text | **Yes (CMS-key-value)** | R, U | `app_settings` (key-value) | Admin | P2 |
| 34 | Mission | Static mission text | **Yes (CMS-key-value)** | R, U | `app_settings` | Admin | P2 |
| 35 | Languages | Supported UI languages | **Yes (read-only after seed)** | R | `languages` | Admin | P2 |
| 36 | Countries | Supported countries, flags, calling codes | **Yes (read-only after seed)** | R | `countries` | Admin | P2 |
| 37 | Church Plants | Multi-tenant church plant records | **Yes (missing UI)** | C, R, U, D | `church_plants` (missing) | Admin | P2 |
| 38 | Media Categories | Tags for media content | **Yes (read + edit)** | R, U | `media_categories` (missing — use enum) | Content Editor | P2 |
| 39 | App Settings | Key-value global config | **Yes (key-value UI)** | R, U | `app_settings` | Super Admin | P0 |
| 40 | Push Notifications | Cross-user broadcast | **Yes (composer missing)** | C, R, U, Sch, T | `push_subscriptions` | Admin, Communications | P1 |
| 41 | Analytics | Custom event ingestion | **Yes (read)** | R, An | `analytics_events` | Admin | P2 |
| 42 | Content Scheduling | Future-published content | **Yes (field-level)** | C, R, U, Sch | per-table `published_at`, `scheduled_for` | Content Editor | P1 |
| 43 | YouTube Sync | Periodic pull from YouTube Data API v3 | **Yes (trigger + read)** | R, Trigger | `media_content`, `media_sync_runs`, `sync-youtube-content` Edge Function | Admin, Media Manager | P1 |
| 44 | Media Review | Triage imported media | **Yes** | R, U, Mod, Wf | `media_content` | Media Manager, Admin | P0 |
| 45 | Volunteer Opportunities | Open volunteer roles | **Yes (missing UI)** | C, R, U, D | `volunteers`, `volunteer_teams`, `volunteer_assignments` | Admin, Volunteer Lead | P2 |
| 46 | Attendance | Service attendance | **Yes (read + import)** | R, Import, An | `group_attendance`, `attendance` (missing) | Admin, Group Leader | P2 |
| 47 | Kids Ministry | Kids check-in, parent linkage | **Yes (missing UI)** | R, Mod | `kids`, `kids_checkin`, `kids_guardians` | Admin, Kids Lead | P2 |
| 48 | Admin Accounts | Promote/demote admins | **Yes** | C, R, U, S | `profiles.role`, `app_metadata.role` | Super Admin | P0 |
| 49 | Content Editors | Granular editor permissions | **Yes (missing)** | C, R, U, D | `user_roles` (missing) | Super Admin | P1 |
| 50 | Moderators | Prayer/testimony/media moderator roster | **Yes (uses roles)** | C, R, U | `profiles.role` | Super Admin | P1 |
| 51 | Audit Logs | Action history across the CMS | **Yes (read)** | R, Filter, Export | `admin_audit_logs` | Super Admin, Admin | P0 |
| 52 | System Configuration | Feature flags, maintenance mode | **Yes** | R, U | `app_settings` | Super Admin | P0 |
| 53 | Leader Applications | Vetting pipeline for new leaders | **Yes** | R, U, Wf | `leader_applications` | Admin, Bishop | P1 |
| 54 | Covenant Signatures | Signed leader covenants | **Yes (read)** | R | `covenant_signatures` | Admin, Bishop | P2 |
| 55 | Certificates & Badges | Auto-issued on group reports | **Yes (read + revoke)** | R, U, D | `certificates`, `leader_badges` | Admin | P2 |
| 56 | Devotional Reflections (user) | Personal reflection journal per entry | No (user-owned) | — | `devotional_reflections` | — | — |
| 57 | Journal Entries | Free-form journal | No (user-owned) | — | `journal_entries`, `journal_tags` | — | — |
| 58 | Streaks & Achievements | Per-user gamification | No (user-owned) | — | `daily_streaks`, `user_achievements`, `achievement_progress` | — | — |
| 59 | Watch History / Continue Watching | Per-user media progress | No (user-owned) | — | `watch_history`, `continue_watching` | — | — |
| 60 | Bible Bookmarks / Highlights / Plans | Per-user Bible study | No (user-owned) | — | `bible_bookmarks`, `bible_highlights`, `bible_plans`, `bible_progress` | — | — |
| 61 | Reading Progress | Per-user reading state | No (user-owned) | — | `reading_progress` | — | — |
| 62 | Preferences | Per-user UI prefs | No (user-owned) | — | `user_preferences`, `notification_preferences` | — | — |
| 63 | Reported Content | User-flagged content triage | **Yes (UI missing)** | R, U, Mod, Wf | `reported_content` | Admin, Moderator | P1 |
| 64 | Live Chat Reports | Chat moderation queue | **Yes (UI missing)** | R, U, Mod | `live_chat_reports` | Admin, Moderator | P2 |
| 65 | Home Dashboard State | Per-user dashboard cards | No (user-owned) | — | `home_dashboard_state` (read) | — | — |
| 66 | Service Schedules | Weekly recurring services | **Yes (missing UI)** | C, R, U, D, Sch | `service_schedules` | Events Manager, Admin | P1 |
| 67 | Community Highlights | Hero members + impact cards | **Yes (read + edit)** | R, U | `community_highlights_user` | Admin, Communications | P2 |
| 68 | Daily Journey Tasks | Today's checklist items | **Yes (read + edit)** | C, R, U, S, Sch, T | `daily_journey_tasks` | Content Editor, Admin | P1 |
| 69 | Prayer Streaks | Per-user prayer engagement | No (user-owned) | — | `prayer_streaks` | — | — |
| 70 | Continue Progress | Per-user "continue where you left off" | No (user-owned) | — | `continue_progress` | — | — |
| 71 | Leader Recognition | Public recognition of leaders | **Yes (UI placeholder)** | C, R, U, S | (missing tables — see §7) | Admin, Communications | P2 |
| 72 | Global Impact Dashboard | Aggregate metrics | **Yes (read + edit placeholders)** | R, U | derived from `groups`, `group_reports`, `profiles` | Admin | P2 |
| 73 | Vessel School Prospects | Track prospects in discipleship pathway | **Yes (missing UI)** | C, R, U, S | `vessel_school_prospects` (missing) | Content Editor, Admin | P2 |
| 74 | Challenges | In-app challenges (separate from devotions) | **Yes (missing UI)** | C, R, U, S, T | `challenges`, `challenge_progress`, `challenge_groups` | Content Editor, Admin | P1 |
| 75 | Translation Status | Which translations exist for which entries | **Yes (read + filter)** | R, Filter | `devotional_translations.translation_status` | Translator, Content Editor | P0 |

**Totals**: 75 modules, 51 require CMS management (68 %).

---

## 2. Navigation Structure (Proposed Production CMS)

A NavigationRail (desktop ≥ 800 px) + bottom NavigationBar (mobile) shell with **8 primary sections**. The Admin CMS is the single entry point in the app; it is gated by `LocalStorageKeys.userRole == 'admin'` at the router, and the DB `is_admin()` is the source of truth.

```
/admin                        Dashboard          (Stats: DAU/WAU/MAU, online, donations, geo, lang)
/admin/members                Members            (Profiles, role mgmt, soft-delete)
/admin/content                Content (group)    (Sermons, Events, Podcasts, Resources, Books, Reading Plans)
/admin/devotionals            Devotionals        (Series list → day editor → translations)
/admin/media                  Media              (Review queue, YouTube sync, feature flags)
/admin/moderation             Moderation         (Prayer wall, Testimonies, Live chat, Reported content)
/admin/groups                 Groups             (List, members, reports, attendance)
/admin/announcements          Announcements      (Comms, push composer, banners)
/admin/insights               Insights           (Donations, Devotional progress, Country/Lang analytics, Audit log)
/admin/settings               Settings           (Roles, App config, Feature flags, Vision/Mission, Languages, Countries)
```

### Mobile NavigationBar (4 of 8)

Per the existing `admin_shell.dart`, the mobile bar shows a reduced set. For production, recommend **5 destinations on mobile**: Stats, Members, Content, Moderation, More. The "More" sheet opens the full rail.

### Existing admin screens (12 today, mapped to navigation above)

| Path | Screen | Section |
|---|---|---|
| `/admin` | `AdminAnalyticsDashboardScreen` | Dashboard |
| `/admin/members` | `AdminMembersScreen` | Members |
| `/admin/sermons` | `AdminSermonsScreen` | Content → Sermons |
| `/admin/events` | `AdminEventsScreen` | Content → Events |
| `/admin/moderation` | `AdminModerationScreen` | Moderation → Testimonies |
| `/admin/prayer-moderation` | `AdminPrayerModerationScreen` | Moderation → Prayer wall |
| `/admin/leader-applications` | `AdminLeaderApplicationsScreen` | Groups → Leader apps |
| `/admin/global-impact` | `AdminGlobalImpactDashboardScreen` | Insights → Global impact |
| `/admin/leader-recognition` | `AdminLeaderRecognitionDashboardScreen` | Groups → Recognition (placeholder) |
| `/admin/media-review` | `AdminMediaReviewScreen` | Media |
| `/admin/devotional-series` | `AdminDevotionalSeriesScreen` | Devotionals |
| `/admin/devotional-series/:seriesId/days/:dayNumber` | `AdminDevotionalDayEditorScreen` | Devotionals (nested) |

---

## 3. Database Dependencies

### 3.1 Tables already managed by Admin UI

| Table | Screen | Operations supported |
|---|---|---|
| `profiles` | `/admin/members` | R, U-role, soft-D (`is_deleted`) |
| `sermons` | `/admin/sermons` | R, U-status, D |
| `events` | `/admin/events` | R, U-status, D |
| `testimonies` | `/admin/moderation` | R, U-approve, D-reject |
| `prayer_requests` | `/admin/prayer-moderation` | R, U via SECURITY DEFINER RPCs |
| `leader_applications` | `/admin/leader-applications` | R, U-approve/reject |
| `media_content` | `/admin/media-review` | R, U-status, U-content_type |
| `media_sync_runs` | (read) | via RPC `get_latest_sync_run` |
| `devotional_series` | `/admin/devotional-series` | C, R, U-status, U-primary |
| `devotional_entries` | `/admin/devotional-series/:id/days/:n` | C/U (upsert) |
| `devotional_translations` | `/admin/devotional-series/:id/days/:n` | C/U (upsert per language) |
| `admin_audit_logs` | (write only) | every repo's `_logAction` |

### 3.2 Tables defined but NOT managed by Admin UI (need screens)

`announcements`, `groups`, `group_memberships`, `group_messages`, `group_announcements`, `group_events`, `group_reports`, `certificates`, `leader_badges`, `volunteers`, `volunteer_teams`, `volunteer_assignments`, `kids`, `kids_checkin`, `kids_guardians`, `bookstore_products`, `bookstore_inventory`, `bookstore_orders`, `news_articles`, `news_categories`, `podcasts`, `podcast_episodes`, `donations`, `recurring_mandates`, `payment_webhooks_log`, `subscribers`, `push_subscriptions`, `live_services`, `live_chat_reports`, `app_installations`, `user_devices`, `countries`, `languages`, `reported_content`, `sermon_series`, `sermon_translations`, `journal_entries`, `journal_tags`, `reading_plans`, `reading_plan_days`, `covenant_signatures`, `devotional_reflections_legacy`, `service_schedules`, `daily_verses`, `daily_journey_tasks`, `community_highlights_user`.

### 3.3 Tables MISSING entirely (need migrations)

`app_settings` (key-value store), `featured_content` (home screen cards), `explore_config`, `church_plants`, `vessel_school_prospects`, `discipleship_pathways`, `lessons`, `leader_recognition_*`, `attendance`, `media_categories`, `resources` (curated library — distinct from bookstore).

### 3.4 Views used by Admin

`view_online_users`, `view_dau`, `view_wau`, `view_mau`, `view_donation_analytics`, `view_country_analytics`, `view_language_analytics`, `view_admin_dashboard_stats` (defined but not consumed), `devotional_progress_analytics` (new in 20260712000001), `prayer_requests_approved`.

---

## 4. API Dependencies

### 4.1 Supabase REST (auto from PostgREST)

All tables have RLS. The Admin CMS will use the `supabase-flutter` client with `Supabase.instance.client.from(...).select()` etc. Existing repositories demonstrate the pattern (`lib/features/admin/data/repositories/`).

### 4.2 Database functions (RPCs) used by Admin

| Function | Defined in | Used by |
|---|---|---|
| `is_admin()` / `is_leader()` | `20260611000000_security_hardening` | every RLS policy |
| `get_latest_sync_run()` | (search) | Admin Media Review |
| `approve_prayer_request(uuid, notes)` | `20260706000000_prayer_moderation_workflow` | Admin Prayer Mod |
| `reject_prayer_request(uuid, notes)` | same | Admin Prayer Mod |
| `set_prayer_request_pending(uuid, notes)` | same | Admin Prayer Mod |
| `get_pending_prayer_requests_for_admin()` | same | Admin Prayer Mod |
| `get_approved_prayer_requests_for_admin()` | same | Admin Prayer Mod |
| `get_rejected_prayer_requests_for_admin()` | same | Admin Prayer Mod |
| `log_admin_action()` | `20260612000003_admin_cms` | triggers |
| `handle_updated_at()` | (search) | triggers |
| `initialize_devotional_progress(uuid)` | `20260712000001_devotional_series` | Devotional (user) |
| `complete_devotional_day(uuid, int)` | same | Devotional (user) |
| `get_devotional_progress(uuid)` | same | Devotional (user) |

**Missing RPCs needed for production CMS** (recommended design):

- `admin_set_user_role(target_user_id, new_role)` — wraps `app_metadata.role` update
- `admin_publish_devotional_entry(entry_id, published bool)` — single-source publish toggle
- `admin_archive_devotional_series(series_id)` — cascades to entries + translations
- `admin_set_translation_status(entry_id, language_code, status, reviewer_id)`
- `admin_upsert_app_setting(key, value, type)` — key-value store
- `admin_search_audit_log(filters jsonb, page int, page_size int)` — paginated audit query
- `admin_get_dashboard_overview()` — single round-trip for the dashboard
- `admin_upsert_feature_flag(key, enabled bool)` — for system configuration
- `admin_create_church_plant(payload jsonb)` / `admin_list_church_plants`
- `admin_publish_announcement(payload jsonb)` / `admin_schedule_announcement`

### 4.3 Supabase Edge Functions

| Function | Used by Flutter today | Notes |
|---|---|---|
| `initialize-payment` | **No** (legacy) | in-app checkout deleted; redirects to `pay.kingdomheirsfoundation.com` |
| `payment-webhooks` | (gateway call) | Paystack/Flutterwave |
| `sync-youtube-content` | **Yes** | `AdminMediaReviewScreen._triggerSync` |

**Recommended additional Edge Functions**:

- `send-push-notification` (broadcast) — current schema is `push_subscriptions` + `notification_router`, but no composer
- `summarize-prayer-wall` (weekly digest) — optional, analytics
- `auto-translate-devotional` (placeholder) — pre-fill `devotional_translations` for new languages via DeepL/Google
- `recalculate-devotional-streaks` — backfill for `devotional_progress`
- `generate-daily-verse` (cron) — keeps `daily_verses` populated
- `process-prayer-notifications` (cron) — sends push when prayer is approved

### 4.4 Storage buckets

`avatars`, `testimonies_media`, `sermon_media`, `journal_images`, `live_thumbnails`. No admin screen lets operators browse or remove orphan blobs.

---

## 5. Permissions Matrix

### 5.1 Role design (recommended)

The current production system is **binary admin / not-admin**. Production needs a granular RBAC. Recommended roles:

| Role | Description | Typical users |
|---|---|---|
| `super_admin` | Full control, role management, destructive ops | Founders, lead pastors |
| `admin` | All CMS actions except role management | Operations team |
| `content_editor` | Sermons, events, devotionals, podcasts, resources, books | Pastors, media team |
| `translator` | Devotional translations (read content, write only `devotional_translations`) | Multilingual volunteers |
| `prayer_moderator` | Approve / reject prayer requests and testimonies | Pastoral care team |
| `media_manager` | Media review queue, YouTube sync, content_type | Media team |
| `events_manager` | Events, service schedules, attendance | Events coordinator |
| `finance` | Donations, recurring mandates, refunds (read) | Finance team |
| `group_leader` | Own group(s): members, messages, reports, attendance | Group leaders |
| `communications` | Announcements, push composer | Communications team |
| `support` | Read users, read donations, audit log (no writes) | Customer support |
| `member` | Default authenticated user | All app users |

### 5.2 Permission matrix

✓ = allowed, ✗ = denied, R = read-only, A = approval required.

| Module / Action | super_admin | admin | content_editor | translator | prayer_mod | media_mgr | events_mgr | finance | group_leader | comms | support | member |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **Users** | | | | | | | | | | | | |
| List profiles | ✓ | ✓ | R | — | R | R | R | R | R (own group) | R | R | — |
| Change role | ✓ | ✗ | ✗ | — | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Soft-delete | ✓ | ✓ | ✗ | — | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Restore | ✓ | ✓ | ✗ | — | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **Content (Sermons, Events, Podcasts, Resources, Books, Reading Plans)** | | | | | | | | | | | | |
| Create | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ |
| Edit | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ |
| Delete | ✓ | ✓ | A (if published) | ✗ | ✗ | A | A | ✗ | ✗ | A | ✗ | ✗ |
| Publish | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ |
| Schedule | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ |
| **Devotionals** | | | | | | | | | | | | |
| Create series | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Edit series metadata | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Toggle primary challenge | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Create/edit entry | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Publish entry | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Add translation (draft) | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Approve translation (publish status) | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **Moderation** | | | | | | | | | | | | |
| Approve prayer | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Reject prayer | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Approve testimony | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Triage reported content | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Moderate live chat | ✓ | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **Media** | | | | | | | | | | | | |
| Trigger YouTube sync | ✓ | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Update media status | ✓ | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Set content type | ✓ | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Feature media | ✓ | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **Groups** | | | | | | | | | | | | |
| List all groups | ✓ | ✓ | R | — | R | R | R | R | R (own) | R | R | — |
| Approve new group | ✓ | ✓ | ✗ | — | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Suspend group | ✓ | ✓ | ✗ | — | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Submit own group report | — | — | — | — | — | — | — | — | ✓ | — | — | — |
| Approve group report | ✓ | ✓ | ✗ | — | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **Announcements / Communications** | | | | | | | | | | | | |
| Create announcement | ✓ | ✓ | ✗ | — | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ |
| Schedule announcement | ✓ | ✓ | ✗ | — | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ |
| Send push | ✓ | ✓ | ✗ | — | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ |
| **Finance** | | | | | | | | | | | | |
| List donations | ✓ | ✓ | — | — | — | — | — | ✓ | — | — | R | — |
| Issue refund | ✓ | ✗ | — | — | — | — | — | ✓ | — | — | ✗ | — |
| View recurring mandates | ✓ | ✓ | — | — | — | — | — | ✓ | — | — | R | — |
| **Analytics** | | | | | | | | | | | | |
| View dashboard | ✓ | ✓ | R | R | R | R | R | R | R (own) | R | R | — |
| View audit log | ✓ | ✓ | — | — | — | — | — | R | — | — | R | — |
| Export CSV | ✓ | ✓ | ✗ | — | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✓ | — |
| **System** | | | | | | | | | | | | |
| App settings | ✓ | ✗ | ✗ | — | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Feature flags | ✓ | ✗ | ✗ | — | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Languages / Countries | ✓ | R | — | — | — | — | — | — | — | — | — | — |
| Vision / Mission text | ✓ | ✓ | ✗ | — | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ |
| Maintenance mode | ✓ | ✗ | ✗ | — | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

### 5.3 Database representation of roles

**Recommended implementation:**

1. Add a `user_roles` table:
   ```sql
   create table public.user_roles (
     user_id    uuid primary key references auth.users(id) on delete cascade,
     role       text not null check (role in (
       'super_admin','admin','content_editor','translator',
       'prayer_moderator','media_manager','events_manager',
       'finance','group_leader','communications','support','member'
     )),
     granted_by uuid references auth.users(id),
     granted_at timestamptz default now(),
     expires_at timestamptz
   );
   ```
2. Update `is_admin()` to read from this table **and** keep JWT `app_metadata.role` as a fast-path cache.
3. Add `current_user_has_role(text)` helper.
4. Add granular policies per table for the modules that need fine-grained control (`devotional_translations`, `donations`, `groups`).

### 5.4 The `MODERATOR` bug — current state

`admin_members_screen.dart` exposes a `'USER' | 'MODERATOR' | 'ADMIN'` dropdown, but:
- The DB `is_admin()` checks `app_metadata.role IN ('admin','bishop','pastor')` — `'MODERATOR'` is unknown.
- The router guard requires `LocalStorageKeys.userRole == 'admin'`.
- Promoting a user to `'MODERATOR'` **locks them out of the CMS** while granting no compensating permissions.

**Resolution:** Replace the free-text `role TEXT` with the new `user_roles.role` enum; remove `'MODERATOR'` from the dropdown; map `'MODERATOR'` legacy values to `'prayer_moderator'` in a backfill.

---

## 6. Workflow Diagrams

### 6.1 Prayer Request (existing, validated)

```
USER SUBMITS PRAYER
   ↓
status = 'pending' (visible only to admin/moderator)
   ↓
ADMIN REVIEWS
   ↓
approve_prayer_request(uuid, notes)    reject_prayer_request(uuid, notes)
   ↓                                       ↓
status = 'approved'                    status = 'rejected'
is_approved = true                     notify_prayer_decision() trigger
notify_prayer_decision() trigger       (fcm to author)
   ↓
VISIBLE ON PRAYER WALL (prayer_requests_approved view)
   ↓
ADMIN CAN RETURN TO PENDING via set_prayer_request_pending(uuid, notes)
```

### 6.2 Devotional Entry (proposed)

```
DRAFT  →  INTERNAL REVIEW  →  PUBLISHED  →  ARCHIVED (optional)
  ↑             ↓                    ↓
  ↑       content_editor         devotional_progress
  ↑       or super_admin         unlock is server-enforced
  ↑
translator adds translation
  (translation_status = 'draft')
        ↓
translator sets translation_status = 'review'
        ↓
content_editor sets translation_status = 'published'
        ↓
visible to users in that language
```

### 6.3 YouTube Media Import (existing)

```
YOUTUBE DATA API v3
   ↓ (cron or admin trigger)
sync-youtube-content Edge Function
   ↓
INSERT new media_content (status='pending_review')
UPDATE existing media_content (preserve admin-managed fields)
INSERT media_sync_runs row
   ↓
AdminMediaReviewScreen lists pending
   ↓
Admin sets status = 'published' | 'archived' | 'pending_review'
Admin sets content_type
Admin toggles is_featured
   ↓
VISIBLE on Home / Explore
```

### 6.4 Testimonies (existing)

```
USER SUBMITS TESTIMONY
   ↓
status = 'pending' (or default draft)
   ↓
ADMIN APPROVES → status = 'published', is_approved = true
ADMIN REJECTS   → DELETE (hard)
```

### 6.5 Announcement (proposed)

```
DRAFT
  ↓
SCHEDULED (published_at future)
  ↓ (cron)
PUBLISHED
  ↓ (manual)
ARCHIVED
```

### 6.6 Leader Application (existing)

```
USER SUBMITS leader_applications (status = 'pending')
   ↓
ADMIN REVIEWS
   ↓
APPROVED → handle_covenant_signed() trigger fires if user signs covenant
              → user promoted to 'group_leader' role
REJECTED → application marked rejected
```

### 6.7 Devotional Translation (proposed)

```
TRANSLATOR CREATES devotional_translations row
  translation_status = 'draft'
   ↓
translator saves changes (still draft)
   ↓
translator flips translation_status = 'review'
   ↓
content_editor reviews
   ↓
content_editor flips translation_status = 'published'   OR   back to 'draft' with notes
```

---

## 7. Missing Tables

Tables referenced by the app, the audit specification, or the CMS design that **do not exist** in the migration set. Each needs a migration before its CMS screen can be built.

| Table | Purpose | Suggested columns (minimum) |
|---|---|---|
| `app_settings` | Global key-value config (vision, mission, maintenance, feature flags) | key TEXT PK, value JSONB, value_type TEXT, description TEXT, updated_by UUID, updated_at TIMESTAMPTZ |
| `featured_content` | Home-screen cards (drives the "Featured" carousel) | id, slot TEXT, entity_type TEXT, entity_id UUID, title TEXT, image_url TEXT, weight INT, is_active BOOL, starts_at TIMESTAMPTZ, ends_at TIMESTAMPTZ |
| `explore_config` | Explore-page layout & order | id, section_key TEXT, title TEXT, body TEXT, query_json JSONB, display_order INT, is_active BOOL |
| `church_plants` | Multi-tenant church plant records | id, name, country, city, lead_pastor_id, planted_at, status, address, photo_url |
| `discipleship_pathways` | Curriculum paths (Vessel School) | id, slug, title, description, language, order_idx, cover_url, is_active |
| `lessons` | Lessons within a pathway | id, pathway_id, slug, title, body, order_idx, estimated_minutes, scripture_ref, audio_url |
| `resources` | Curated resource library | id, title, summary, body, image_url, external_url, language, category, status, published_at |
| `attendance` | Service attendance (cross-group) | id, service_schedule_id, profile_id, checked_in_at, checked_out_at |
| `media_categories` | Editorial taxonomy for media | id, slug, label, parent_id NULLABLE |
| `leader_recognition` | Public recognition list | id, profile_id, title, summary, image_url, period_start, period_end, is_published |
| `vessel_school_prospects` | Prospects in discipleship pathway | id, profile_id, pathway_id, stage, started_at, completed_at |
| `challenges` | Standalone challenges (distinct from devotions) | id, slug, title, description, starts_at, ends_at, is_active |
| `challenge_progress` | Per-user challenge state | id, user_id, challenge_id, current_step, completed_steps INT[], completed_at |
| `challenge_groups` | Group-scoped challenges | id, challenge_id, group_id, leader_id, custom_goal |
| `user_roles` | Granular RBAC (see §5.3) | user_id PK, role, granted_by, granted_at, expires_at |

---

## 8. Missing Features (UI / CMS screens)

| # | Screen | Section | Notes |
|---|---|---|---|
| 1 | **Sermon Create / Edit form** | Content → Sermons | Button is a "coming soon" snackbar today. |
| 2 | **Sermon Edit handler** | Content → Sermons | Popup menu `Edit` is a dead item. |
| 3 | **Event Create / Edit form** | Content → Events | Same as sermons. |
| 4 | **Event Edit handler** | Content → Events | Same as sermons. |
| 5 | **Sermon Series CRUD** | Content → Sermon Series | `sermon_series` table exists, no editor. |
| 6 | **Sermon Translations editor** | Content → Sermon Translations | `sermon_translations` table exists. |
| 7 | **Podcast / Episode CRUD** | Content → Podcasts | Tables exist, no UI. |
| 8 | **Resources CRUD** | Content → Resources | Missing table + UI. |
| 9 | **Books CRUD** | Content → Bookstore | `bookstore_*` tables exist, no UI. |
| 10 | **Reading Plans editor** | Content → Reading Plans | `reading_plans`, `reading_plan_days`. |
| 11 | **Discipleship Pathways editor** | Content → Pathways | Missing table + UI. |
| 12 | **Lessons editor** | Content → Lessons | Missing table + UI. |
| 13 | **Devotional Series Edit dialog** | Devotionals | Series can be created and status-toggled but title/author/days aren't editable post-create. |
| 14 | **Devotional Day picker** | Devotionals | Calendar icon always opens `days/1` — need a day grid. |
| 15 | **Translation review queue** | Devotionals | Filter by `translation_status='review'` with bulk approve. |
| 16 | **Announcements CRUD** | Announcements | Table exists, no UI. |
| 17 | **Push composer** | Announcements | No UI to broadcast. |
| 18 | **Home Screen Cards editor** | Announcements | `home_dashboard_state` is per-user; need a master `featured_content` table. |
| 19 | **Explore Screen editor** | Announcements | Missing `explore_config`. |
| 20 | **Vision / Mission editor** | Settings | Use `app_settings` key-value. |
| 21 | **Languages & Countries (read view)** | Settings | Reference data, not currently editable in CMS. |
| 22 | **App Settings (key-value)** | Settings | Missing table + UI. |
| 23 | **Feature flags** | Settings | Missing. |
| 24 | **System Configuration / Maintenance toggle** | Settings | Missing. |
| 25 | **Donations viewer** | Finance | `donations` table admin-readable, no UI. |
| 26 | **Recurring mandates** | Finance | `recurring_mandates` table, no UI. |
| 27 | **Refunds flow** | Finance | No UI. |
| 28 | **Groups list + member roster** | Groups | `groups`, `group_memberships`. |
| 29 | **Group reports review** | Groups | `group_reports` exists. |
| 30 | **Certificates & Badges review / revoke** | Groups | `certificates`, `leader_badges`. |
| 31 | **Covenant signatures viewer** | Groups | `covenant_signatures`. |
| 32 | **Kids check-in monitor** | Groups | `kids`, `kids_checkin`. |
| 33 | **Volunteers / Teams / Assignments** | Groups | `volunteers`, `volunteer_teams`, `volunteer_assignments`. |
| 34 | **Live services scheduler** | Media | `live_services`. |
| 35 | **Live chat moderation** | Media | `live_chat_messages`, `live_chat_reports`. |
| 36 | **Reported content triage** | Moderation | `reported_content`. |
| 37 | **Service schedules editor** | Content → Events | `service_schedules`. |
| 38 | **Daily Verses editor** | Today's Walk | `daily_verses`. |
| 39 | **Daily Journey Tasks editor** | Today's Walk | `daily_journey_tasks`. |
| 40 | **Community Highlights editor** | Announcements | `community_highlights_user`. |
| 41 | **Audit log viewer** | Insights | `admin_audit_logs` is written everywhere, no read UI. |
| 42 | **Devotional progress analytics** | Insights | `devotional_progress_analytics` view exists, not consumed. |
| 43 | **Bulk operations** | (any) | No multi-select delete, no CSV import, no bulk publish. |
| 44 | **Storage browser** | Media | Browse / delete orphan blobs. |
| 45 | **Dashboard day-picker** | Dashboard | Growth chart is hard-coded. |
| 46 | **Global Impact Dashboard** | Insights | Currently hard-coded; tie to `groups`, `group_reports`. |
| 47 | **Leader Recognition** | Groups | Currently placeholder. |
| 48 | **Translation review workflow** | Devotionals | Currently translator has no review queue. |
| 49 | **Bulk translation request** | Devotionals | Need a "request translation for X language" form. |
| 50 | **Role assignment UI** | Settings | Promote/demote granular roles. |
| 51 | **Role-aware navigation** | All sections | Mobile NavigationBar in `admin_shell.dart` shows only 4 of 8 destinations. |

---

## 9. Existing Features Ready for CMS (consolidate first)

These screens are already functional and can be promoted to production with minimal hardening:

| Feature | Status | Hardening needed |
|---|---|---|
| Admin Dashboard (analytics) | ✓ functional | Real growth chart (currently hard-coded). |
| Members screen | ✓ functional | Replace `'MODERATOR'` with new role enum; full-name search; pagination. |
| Sermons list | ✓ functional | Create/Edit forms. |
| Events list | ✓ functional | Create/Edit forms. |
| Prayer Moderation (3-state) | ✓ **fully functional** via RPCs | None — this is the gold standard. |
| Testimonies Moderation | ✓ functional | Bulk actions. |
| Leader Applications review | ✓ functional | Status filters. |
| Devotional Series CRUD | ✓ **mostly functional** | Edit metadata; day picker; translation workflow. |
| Devotional Day editor | ✓ functional | Add day-picker grid. |
| Devotional Translations editor | ✓ functional | Status workflow + review queue. |
| Media Review queue | ✓ functional | Add bulk publish; add delete; fix `.select()` filter to pending only. |
| YouTube sync trigger | ✓ functional | None. |
| Global Impact dashboard | ⚠️ partly hard-coded | Compute from `groups`, `group_reports` instead of synthetic math. |
| Leader Recognition | ✗ **placeholder** | Real data binding. |

---

## 10. RBAC & Workflow Improvement Recommendations

1. **Replace the binary `is_admin()` model with a granular `user_roles` table.** Mirror the role into JWT `app_metadata.role` for performance but keep DB as source of truth.
2. **Define a `permissions` table or JSONB on `user_roles`** for the rare case where a user needs a single fine-grained permission outside their role.
3. **Add an `audit_log` write for every CMS action.** The write side is complete; add a read-side viewer with filters (actor, target, date range, action).
4. **Add a generic content-approval workflow** (`workflow_status` enum: `draft | review | approved | scheduled | published | archived`) and apply it to: announcements, devotional entries, translations, sermons, events, podcasts, resources, books, reading plans, lessons, devotional series.
5. **Add a `scheduled_publish_at` column** to every content table that needs it; add a cron Edge Function `publish-scheduled-content`.
6. **Add a `version` column** (int) and `supersedes` (FK self) for content that should be versioned (devotional entries, sermons, lessons).
7. **Add `archived_at` and `archived_by`** for soft-archive (already present on `devotional_series`, propagate to other content).
8. **Add a `translations` view** `v_devotional_translation_status` that aggregates per (series, language) — used by the translation review queue.
9. **Add a translation_status queue per language** so each translator sees only their language's queue.
10. **Add CSV import/export** to all list screens (members, devotional entries, donations, events).
11. **Add bulk publish** to all list screens with status filters.
12. **Add the audit log viewer** as a top-level read-only screen in Insights.
13. **Backfill `MODERATOR` → `prayer_moderator`** before deploying the new role model.
14. **Add a "primary challenge" calendar view** that shows the user-facing 90-Day Challenge as configured by `devotional_series.is_primary_challenge_series`.

---

## 11. Production Readiness Score

Score is **64 / 100**, broken down as:

| Category | Weight | Score | Note |
|---|---:|---:|---|
| Schema maturity (RLS, migrations, indexes) | 15 | 14 | Strong: 30+ migrations, RLS on every table, idempotent. |
| Admin feature coverage (depth) | 20 | 9 | Prayer mod + devotionals + media are real; sermons/events create-edit missing. |
| Admin feature coverage (breadth) | 15 | 6 | 51 modules require CMS; only ~20 are covered. |
| RBAC / Roles | 10 | 3 | Binary admin; needs granular roles. |
| Workflow support | 10 | 6 | Prayer mod is excellent; everything else is one-step publish or hard delete. |
| Audit logging | 5 | 3 | Writes complete, no read UI. |
| Internationalization (content side) | 5 | 4 | Multilingual schema is strong; translation workflow UI missing. |
| i18n (UI) | 3 | 3 | ARB-based gen-l10n, no issues. |
| Performance / scalability | 5 | 4 | Indexed, RLS-scoped queries, RPCs. |
| Mobile parity (shell exposes 4 of 8) | 3 | 1 | `admin_shell.dart` mobile bar hides most destinations. |
| Code hygiene (TODOs, hard-coded data) | 5 | 3 | Several "coming soon" snackbars, hard-coded leader names, hard-coded growth chart. |
| Documentation | 4 | 4 | This document; existing CLAUDE.md / memory. |
| **Total** | **100** | **64** | |

### Path to 90+

Closing the gap to 90 requires, in priority order:

1. **Granular roles + `user_roles` table** — unlocks 1, 2, 10, 12, 50.
2. **Sermon & Event Create/Edit forms** — closes feature coverage on the two largest content tables.
3. **Audit log viewer** — completes the audit story.
4. **Translation review workflow + day picker** — completes the devotional system.
5. **Mobile parity in `admin_shell.dart`** — surfaces the 4 hidden destinations.
6. **Missing tables migration** (`app_settings`, `featured_content`, `church_plants`, `discipleship_pathways`, `lessons`, `resources`) — enables Settings, Home cards, and Pathways screens.
7. **Announcements + Push composer** — completes Communications.
8. **Donations viewer + refunds flow** — completes Finance.
9. **Replace hard-coded Growth Chart, Global Impact, and Leader Recognition** — kills the last mocks.
10. **Real `view_admin_dashboard_stats` consumer** + **devotional progress analytics consumer**.

---

## 12. Implementation Roadmap (for future planning)

> This is the proposed order, **not** an implementation in this audit.

**Phase 1 — Foundations (1–2 sprints)**
- Migration: `user_roles`, `app_settings`, `featured_content`, `explore_config`, `church_plants`, `discipleship_pathways`, `lessons`, `resources`, `attendance`, `media_categories`, `leader_recognition`, `vessel_school_prospects`, `challenges`, `challenge_progress`, `challenge_groups`.
- RPCs: `admin_set_user_role`, `admin_upsert_app_setting`, `admin_search_audit_log`, `admin_get_dashboard_overview`, `admin_publish_devotional_entry`, `admin_archive_devotional_series`, `admin_set_translation_status`.
- New admin section: Settings (key-value), Languages/Countries viewer, Vision/Mission editor, Feature flags, Role assignment, Audit log viewer.

**Phase 2 — Content (2–3 sprints)**
- Sermon Create/Edit, Sermon Series CRUD, Sermon Translations editor, Event Create/Edit, Podcast CRUD, Reading Plans editor, Resources editor, Bookstore editor, Discipleship Pathways + Lessons editor.
- Announcements CRUD with scheduling.
- Home Screen Cards editor (uses `featured_content`).
- Explore Screen editor (uses `explore_config`).
- Replace Global Impact and Leader Recognition placeholders with real data.

**Phase 3 — Moderation & Communication (1–2 sprints)**
- Reported content triage.
- Live chat moderation.
- Live services scheduler.
- Push notification composer + Edge Function.
- Translation review queue (draft → review → published).

**Phase 4 — Finance & Groups (1–2 sprints)**
- Donations viewer (read + filter + export).
- Recurring mandates viewer.
- Refund RPC + UI.
- Groups list + member roster.
- Group reports review.
- Certificates & Badges review.
- Volunteer / Teams / Assignments CRUD.
- Kids check-in monitor.
- Covenant signatures viewer.

**Phase 5 — Polish & Hardening (1 sprint)**
- Real Growth Chart (date picker + RPC).
- Mobile parity in `admin_shell.dart`.
- Bulk operations across lists.
- CSV import/export.
- Storage browser.
- Real dashboard consumption of `view_admin_dashboard_stats` and `devotional_progress_analytics`.
- Cron Edge Functions: `publish-scheduled-content`, `process-prayer-notifications`, `recalculate-devotional-streaks`, `generate-daily-verse`.

---

## 13. Appendix — Current State Quick Reference

### 13.1 Admin screens today (12)
`admin_dashboard_screen.dart`, `admin_members_screen.dart`, `admin_sermons_screen.dart`, `admin_events_screen.dart`, `admin_moderation_screen.dart`, `admin_prayer_moderation_screen.dart`, `admin_leader_applications_screen.dart`, `admin_global_impact_dashboard_screen.dart`, `admin_leader_recognition_dashboard_screen.dart`, `admin_media_review_screen.dart`, `admin_devotional_series_screen.dart`, `admin_devotional_day_editor_screen.dart`.

### 13.2 Admin repositories (4)
`admin_members_repository.dart`, `admin_content_repository.dart`, `admin_moderation_repository.dart`, `admin_leader_apps_repository.dart`. (Prayer moderation is owned by `lib/features/prayer_requests/.../prayer_repository.dart`; devotional admin is in the devotional feature.)

### 13.3 Edge functions (3)
`initialize-payment` (legacy, unused in app), `payment-webhooks` (gateway-called), `sync-youtube-content` (used by Admin Media Review).

### 13.4 Storage buckets (5)
`avatars`, `testimonies_media`, `sermon_media`, `journal_images`, `live_thumbnails`.

### 13.5 DB functions (admin-relevant)
`is_admin()`, `is_leader()`, `get_auth_role()`, `get_latest_sync_run()`, `approve_prayer_request()`, `reject_prayer_request()`, `set_prayer_request_pending()`, `get_*_prayer_requests_for_admin()`, `log_admin_action()`, `handle_updated_at()`, `initialize_devotional_progress()`, `complete_devotional_day()`, `get_devotional_progress()`, `notify_prayer_decision()`, `prayer_requests_force_pending()`.

### 13.6 Existing views used by Admin
`view_online_users`, `view_dau`, `view_wau`, `view_mau`, `view_donation_analytics`, `view_country_analytics`, `view_language_analytics`, `view_admin_dashboard_stats` (defined, unused), `devotional_progress_analytics` (new, unused), `prayer_requests_approved`.

### 13.7 RLS / Security
- Every production table has RLS enabled.
- `is_admin()` is defined as `get_auth_role() IN ('admin','bishop','pastor')` — JWT-driven.
- `is_leader()` adds `group_leader` and `deacon`.
- Admin write policies are typically `FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin())`.
- `devotional_translations` user-read policy exposes only `translation_status='published' AND entry status='published'`.

### 13.8 Audit pipeline
- Every admin repository calls `_logAction(...)` which inserts into `admin_audit_logs`.
- Triggers on `sermons`, `events`, `devotionals`, `announcements` (legacy `20260612000003`) call `log_admin_action()`.
- No read UI exists.

### 13.9 Known gaps in current code
- `admin_sermons_screen.dart` line ~30: `// TODO(kingdom-heir): Navigate to create sermon form` — "Create Sermon coming soon" snackbar; `Edit` menu item is dead.
- `admin_events_screen.dart` line ~31: same pattern.
- `admin_leader_recognition_dashboard_screen.dart`: entirely static (hard-coded leader names "John Doe", "Sarah Smith", "Samuel O.", "David K.").
- `admin_global_impact_dashboard_screen.dart`: synthetic math (e.g., `countriesActive=1`, `(totalUsers * 0.8).round()`).
- `admin_dashboard_screen.dart` line ~148-159: Growth Trends chart is 6 hard-coded `FlSpot`s.
- `admin_shell.dart` mobile bar: 4 of 8 destinations shown; Prayer Mod, Media, Devotions reachable only on desktop or via deep link.
- The `MODERATOR` dropdown in `admin_members_screen.dart` is incompatible with `is_admin()` and the router admin guard.

### 13.10 Today's Devotional system (end-to-end status)

The 90-Day Devotional system is the **most mature end-to-end feature**:

- Schema: `devotional_series`, `devotional_entries`, `devotional_progress`, `devotional_translations` (in-place upgraded from legacy), `devotional_reflections` (renamed legacy + new canonical), `devotional_progress_analytics` view.
- RPCs: `initialize_devotional_progress`, `complete_devotional_day`, `get_devotional_progress`.
- Multilingual overlay with English fallback at the model layer.
- Admin: list + create series, status toggle, primary toggle, day editor (opens `days/1`), translation editor (6 hard-coded languages: ur, bem, zu, ss, pt, fr).
- RLS: users see only `day_number <= highest_unlocked_day` (server-enforced), admins see all.
- Test coverage: `test/features/devotionals/devotional_series_models_test.dart` covers progress helpers and entry translation overlay.

The remaining gaps are: (a) no day picker, (b) no edit-series dialog, (c) no translation review queue, (d) no analytics consumption, (e) language list is hard-coded — should read from `languages` table.

---

## 14. Closing Notes

The Kingdom Heirs platform's backend is **production-quality**: the Supabase schema is comprehensive, RLS is in place, the recent migration set is idempotent, and the 90-Day Devotional system is the model the rest of the platform should follow. The gap is almost entirely in the Admin CMS surface area and the role model. Closing the gaps identified in §10, in the order proposed in §12, will take the platform from a **64 / 100** production readiness to a confident **90+** in four to eight focused sprints.

This document is the **blueprint only**. No code, schema, RLS policy, Edge Function, or screen has been added or modified as a result of this audit.
