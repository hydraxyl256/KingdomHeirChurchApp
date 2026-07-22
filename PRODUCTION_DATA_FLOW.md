# Production Data Flow Trace

This document maps the exact execution path and data sources for the major features of the Kingdom Heirs Church application.

## 1. Home Dashboard
**Data Flow:**
UI (`DashboardScreen`) → Riverpod (`homeDashboardProvider`, `greetingProvider`, etc.) → `HomeDashboardRepository` → Supabase RPCs (`get_dashboard_greeting`, `get_dashboard_scripture`, etc.)
**Caching Strategy:**
Network-first via `_guardData()`. Supabase RPC is awaited. If successful, it overwrites `SharedPreferences` (e.g., `dashboard_cache_fetchGreeting`). If the RPC fails or throws, it falls back to parsing the JSON string from `SharedPreferences`.
**Fallback:** 
If cache is empty, returns hardcoded fallback objects (e.g., `DashboardGreeting(firstName: 'Friend')`).

## 2. Splash Screen
**Data Flow:**
UI (`SplashScreen`) → `SharedPreferences` (checked in `bootstrap.dart` for `is_first_launch`) → `AppConfig` / `Env`
**Caching Strategy:**
No remote data fetched. Uses purely local assets (`assets/images/app_icon.png`). The `is_first_launch` boolean is stored in `SharedPreferences` and checked during Riverpod container initialization.

## 3. Sermons
**Data Flow:**
UI (`SermonHomeScreen`) → Riverpod (`sermonHomeDataProvider`) → `SermonsRepositoryImpl` → Supabase (`media_content` table)
**Caching Strategy:**
Network-first. Fetches published sermons via Supabase `select()`. 
**Critical Flaw:** The repository checks `if (response.isNotEmpty)` before overwriting the cache (`sermons_cache_v2`). If the server returns an empty list (all records deleted), it skips the cache update and returns the stale `SharedPreferences` string.

## 4. Bible
**Data Flow:**
UI (`BibleReaderScreen`) → Riverpod (`bibleProvider`) → `BibleApiService` → YouVersion Platform API
**Caching Strategy:**
Network-first with aggressive persistent caching. Chapters and books are cached to `SharedPreferences` via `BibleLocalCache` (`bible_content_v2_*`). Local cache is served on network failure.

## 5. Groups
**Data Flow:**
UI (`GroupsScreen`) → Riverpod (`groupsProvider`) → `GroupsSupabaseService` → Supabase (`groups` and `group_members` tables)
**Caching Strategy:**
Network-first via `_guardData()`. Results are serialized to `SharedPreferences` (`groups_cache_getGroups`). Exceptions during Supabase fetches (or JSON parsing) trigger the offline cache fallback.

## 6. Live Services
**Data Flow:**
UI (`LiveServiceScreen`) → Riverpod (`liveServiceStateProvider`, `liveChatMessagesProvider`) → `LiveServiceRepository` → Supabase (`live_services` RPC & Realtime Subscriptions)
**Caching Strategy:**
Primarily stream-based. Live chat utilizes a `chat_offline_queue` in `SharedPreferences` to locally queue messages when offline, attempting to push them upon reconnection.
