# Kingdom Heirs Church App

A modern, production-grade Flutter application built for the Kingdom Heirs Church. Designed to cultivate a digital sanctuary, this app delivers seamless access to sermons, live streams, devotionals, bible reading, community groups, and giving—all backed by a scalable, serverless backend.

## Overview
The Kingdom Heirs Church App bridges the gap between Sunday worship and daily spiritual growth. Engineered with performance and offline-first capabilities in mind, it provides the congregation with a reliable, elegant, and secure platform to engage with ministry content globally.

## Features
- **Sermons & Media:** Audio and video playback with offline downloads and background listening.
- **Automated Live Streaming:** Real-time detection and broadcasting of YouTube Live events directly to the app.
- **Bible Reader:** Fast, offline-capable scripture reader with dynamic font scaling and multi-version support.
- **Community Groups:** Discover, join, and interact with church small groups and ministries.
- **Prayer Wall:** Submit, moderate, and engage with community prayer requests.
- **Giving:** Secure integration for tithes, offerings, and campaign tracking.
- **Testimonies:** Share and read stories of faith from the congregation.
- **Push Notifications:** Stay updated on events, live streams, and ministry announcements.

## Architecture
The application strictly adheres to a **Feature-First Modular Architecture**:
- **Presentation:** UI and state management separated flawlessly using `Riverpod`.
- **Domain:** Pure business logic and entity modeling agnostic of external dependencies.
- **Data:** Repository implementations interfacing with local caching (`SharedPreferences`) and remote data (`Supabase`).
- **Routing:** Handled systematically via `GoRouter` for deep-linking and dynamic navigation.

## Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter / Dart** | Cross-platform client framework. |
| **Riverpod** | Reactive, compile-safe state management and dependency injection. |
| **GoRouter** | Declarative routing and deep linking. |
| **Supabase** | PostgreSQL Database, Authentication, and Edge Functions. |
| **pg_cron & pg_net** | Automated database scheduling and secure internal webhooks. |
| **Firebase** | Analytics, Crashlytics, and Cloud Messaging (FCM). |
| **Sentry** | Advanced error tracking and performance monitoring. |
| **YouTube Data API** | Automated media catalog and live stream synchronization. |

## Project Structure
```text
lib/
├── bootstrap.dart       # App initialization, config, and dependency injection
├── core/                # System-wide utilities, theme, and networking
├── features/            # Feature modules (sermons, live, groups, bible, etc.)
│   └── [feature]/
│       ├── data/        # Repositories, DTOs, and API services
│       ├── domain/      # Entities and abstract interfaces
│       └── presentation/# Providers, Screens, and Widgets
└── main.dart            # Application entry point
```

## Backend Architecture
The backend is entirely serverless, powered by **Supabase**.
- **PostgreSQL:** Highly relational data modeling with strict Row Level Security (RLS).
- **Authentication:** JWT-based sessions mapped securely to PostgreSQL roles.
- **Edge Functions:** Deno-based microservices managing third-party synchronization (YouTube).
- **Storage:** Managed asset and media hosting.

## Media Architecture
Video and audio content is automatically aggregated from the Kingdom Heirs YouTube channel. The `sync-youtube-content` Edge Function routinely imports new uploads, stores the metadata in the `media_content` table, and serves it to the Flutter application seamlessly, minimizing manual content entry.

## Live Streaming Architecture
Live services require zero manual configuration. The `sync-youtube-live` Edge Function, triggered every 10 minutes by a secure `pg_cron` job, utilizes the YouTube Data API to detect active broadcasts and updates the database. The Flutter client consumes this in real-time.

## Local Development Setup

### Requirements
- Flutter SDK (latest stable)
- Supabase CLI
- Firebase CLI (for `flutterfire`)

### Environment Setup
Create a `.env` file in the project root:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Running The Application
```bash
# Fetch dependencies
flutter pub get

# Run the app
flutter run
```

## Building Production
```bash
flutter build appbundle --release
```

## Database Setup
To deploy the database schema locally or to a new environment:
```bash
supabase start
supabase db push
```

## Environment Variables
Edge Functions require the following secrets in your Supabase Vault or Deno environment:
- `YOUTUBE_API_KEY`: API key for YouTube Data API v3.
- `YOUTUBE_CHANNEL_ID`: The target YouTube channel ID.
- `SYNC_INTERNAL_SECRET`: A secure passphrase for cron authentication.
- `SUPABASE_SERVICE_ROLE_KEY`: Service role key for RLS bypass.

## Deployment Process
1. Push all database migrations via `supabase db push`.
2. Deploy Edge Functions via `supabase functions deploy`.
3. Build the Flutter app bundle.
4. Deploy to Google Play Console and Apple App Store Connect.

## Monitoring
Production health is monitored comprehensively:
- **Firebase Analytics:** User engagement and retention.
- **Firebase Crashlytics:** Fatal native and Dart crash reporting.
- **Sentry:** Real-time performance profiling and non-fatal error tracking.

## Contribution Guidelines
1. Fork and branch from `main`.
2. Ensure `flutter analyze` runs without errors.
3. Keep logic contained within its respective feature folder.

## License
Proprietary software. All rights reserved. Kingdom Heirs Church.
