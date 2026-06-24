# Kingdom Heir Church App

A production-ready Flutter church management application built with Clean Architecture, Riverpod, and Supabase.

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.x (stable)
- Dart 3.x
- Supabase project (create at [supabase.com](https://supabase.com))
- Stripe account (for giving features)

### 1. Clone & Setup

```bash
git clone <your-repo>
cd "Kingdom Heir church app"
flutter pub get
```

### 2. Configure Environment

Copy the templates and fill in your credentials:

```bash
# dart_defines/ are gitignored — add your values directly
```

Edit `dart_defines/dev.json`:
```json
{
  "SUPABASE_URL": "https://YOUR_PROJECT.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR_ANON_KEY",
  ...
}
```

> ⚠️ **Never commit** `dart_defines/*.json` — they are gitignored.

### 3. Run (Development)

```bash
flutter run --dart-define-from-file=dart_defines/dev.json -t lib/main_dev.dart
```

Or use the Makefile shortcut:
```bash
make run-dev
```

---

## 📁 Architecture

- **Clean Architecture** — Domain / Data / Presentation layers per feature
- **Feature-first folders** — Each feature is self-contained
- **Riverpod** — Compile-safe state management with `AsyncValue` for all async states
- **GoRouter** — Declarative navigation with auth/onboarding/role guards

See the full architecture in [`implementation_plan.md`](./implementation_plan.md).

---

## 🏗️ Build Flavors

| Flavor | Command |
|---|---|
| Dev | `make run-dev` |
| Staging | `make run-staging` |
| Production APK | `make build-android-prod` |
| Production IPA | `make build-ios-prod` |

---

## ⚡ Code Generation

After adding new Freezed models or Riverpod generators:

```bash
make generate
```

---

## 🧪 Testing

```bash
make test          # all tests with coverage
make test-unit     # unit tests only
make test-widget   # widget tests only
make analyze       # static analysis
```

---

## 🔒 Security

- Supabase RLS enforced on every table
- Stripe handles all payment processing (PCI DSS compliant)
- Tokens stored in OS Keychain/Keystore via `flutter_secure_storage`
- Production builds obfuscated (`--obfuscate --split-debug-info`)

---

## 📦 Key Packages

| Package | Purpose |
|---|---|
| `supabase_flutter` | Backend (Auth, DB, Realtime, Storage) |
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `freezed` | Immutable data models |
| `fpdart` | Functional error handling (`Either`) |
| `flutter_animate` | Micro-animations |
| `just_audio` + `audio_service` | Podcast player |
| `flutter_stripe` | Payments |
| `sentry_flutter` | Crash reporting |

---

## 📱 Supported Platforms

- Android (API 21+)
- iOS 12+

---

## 🎨 Design System

- **Brand Colors**: Royal Purple (`#6B35A3`) + Warm Gold (`#D4AF37`)
- **Typography**: Inter (Google Fonts)
- **Spacing**: 8pt grid
- **Theme**: Full Material 3 with light + dark mode

---

*Built with ❤️ for Kingdom Heir Church*
