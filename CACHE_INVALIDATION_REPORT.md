# Cache Invalidation & Data Persistence Report

This report analyzes the root cause of the "stale content" bug observed in production release builds of the Kingdom Heirs Church application.

## Core Audit Questions

**1. Where does the first frame come from?**
The first frame is rendered by Riverpod's `AsyncLoading` state (loading spinners/skeletons). The repositories enforce a strict **network-first** strategy via wrappers like `_guardData()`. Data is only served from the `SharedPreferences` cache if the initial network request fails or throws an exception.

**2. Is cached data rendered before network fetch?**
No. The application does not use an eager "cache-first" strategy. Repositories `await` the network fetch first. The cache is used exclusively as an *Offline Fallback* when the try-block fails. 

**3. Can stale SharedPreferences survive upgrades?**
**Yes.** `SharedPreferences` data is stored persistently on the device's file system (`xml` on Android, `NSUserDefaults` on iOS). It survives app upgrades, hot restarts, and `flutter build` installations. `flutter clean` **does not** clear this cache; it only clears the local developer build artifacts.

**4. Is there any JSON asset being loaded?**
No. A full codebase scan reveals no `rootBundle.loadString` usage injecting static seed data. All data originates from Supabase or the `SharedPreferences` cache.

**5. Is there any mock fallback?**
No strict "mock" JSON files are used. However, there are *Empty State Fallbacks* (e.g., `const ScriptureCard(...)` in `HomeDashboardRepository`) that render hardcoded default objects when both the network and cache fail.

**6. Can deleted production records remain visible?**
**Yes. This is the primary cause of the bug.**
*   **Sermons:** In `SermonsRepositoryImpl`, the code checks `if (response.isNotEmpty)` before caching. If all sermons are deleted on the server, `response` is an empty list, the `if` block is skipped, the cache is **not** overwritten, and the method silently catches nothing and returns the stale cache containing the deleted sermons.
*   **Groups/Dashboard:** If a record is deleted and the resulting Supabase query throws a `PostgrestException` (e.g., calling `.single()` on 0 rows), the exception triggers the `catch` block, which loads the stale cache instead of clearing it.

**7. Can release mode bypass refresh?**
**Yes.** If R8/ProGuard shrinks or obfuscates model classes used in `parseJson`, the JSON deserialization throws a runtime exception exclusively in release mode. The `_guardData` wrapper catches this parsing exception and silently falls back to the `SharedPreferences` cache. Consequently, the release app will infinitely display stale cached data because every fresh network fetch results in a silent parsing failure.

---

## Conclusion & Next Steps

The application suffers from improper cache invalidation:
1.  **Empty List Neglect:** The caching logic fails to overwrite the local cache when the server returns an empty state.
2.  **Exception Overload:** `_guardData()` treats all exceptions (Network, DB, Parsing) identically. Deserialization errors in release mode trigger the offline cache rather than surfacing the error, masking the root cause and displaying stale data.

To resolve this without refactoring the UI, the `_guardData` and `SermonsRepositoryImpl` caching mechanisms must be patched to clear `SharedPreferences` when valid empty states are returned, and to distinguish between offline network errors and runtime parsing exceptions.
