# Tamini — Food Delivery App

Flutter client for **Tamini**, an Arabic-first (RTL) food delivery platform for
Syria. One app serves three roles with a shared catalog:

| Role | What they get |
| --- | --- |
| **Customer** (guest → registered) | Browse restaurants and meals, cart with server-side quotes, checkout (cash/card) with a map-picked delivery location, live order tracking with a driver map, support tickets |
| **Restaurant owner / staff** | Incoming orders with status flow, kitchen mode, menu and offers management, live delivery board, sales analytics dashboard, delivery settings |
| **Delivery driver** | Available-deliveries board, active delivery with navigation, completion flow, earnings |

Backend: Django REST at `https://tamini.onrender.com/api` with WebSocket routes
under `/ws` (override per environment with `--dart-define`, see below).
Current version lives in `pubspec.yaml` (`1.2.8+22`).

## Tech stack

- **Flutter** (Dart SDK `^3.12.2`), Material 3, Cairo/Lalezar fonts
- **State:** [`provider`](https://pub.dev/packages/provider) `ChangeNotifier`s,
  one per domain, constructed once in `createTaminiApp()` (`lib/main.dart`)
- **Networking:** hand-rolled `ApiClient` (`lib/core/api/api_client.dart`) on
  `package:http` — bearer tokens, 401→refresh-and-retry, cold-start HTML retry
  for every verb, GET caching, in-flight refresh coalescing
- **Persistence:** `flutter_secure_storage` (session), local cache services
- **Realtime:** `web_socket_channel` (`ReconnectingSocket` base with backoff)
  for order events and driver notifications, plus screen-level polling as the
  fallback (see [Polling](#polling-and-sockets))
- **Maps:** `flutter_map` (OpenStreetMap tiles)
- **Auth:** Firebase Auth (email/password, OTP, Google) with a legacy
  password-API fallback when Firebase is unavailable
- **Push:** Firebase Cloud Messaging; **updates:** in-app updater fed by a
  GitHub Pages `version.json` + Shorebird patches

## Getting started

Prerequisites: Flutter stable, a connected device/emulator, and (optionally)
the Tamini backend running or reachable.

```bash
flutter pub get
flutter run                                  # local dev against the default API
flutter run --dart-define=API_BASE_URL=https://staging.host/api \
            --dart-define=WS_BASE_URL=wss://staging.host/ws
```

| Dart define | Purpose | Default |
| --- | --- | --- |
| `API_BASE_URL` | REST base | `https://tamini.onrender.com/api` |
| `WS_BASE_URL` | WebSocket base | `wss://tamini.onrender.com/ws` |
| `APP_VERSION` | Injected in CI releases so `pubspec.yaml` stays the source of truth | `1.2.8` |

## Architecture

Feature-first UI with a layered core. The dependency direction is always
**screens → providers → repositories → `ApiClient`**:

```
lib/
├── main.dart                  # createTaminiApp(): wires every provider once
├── core/
│   ├── api/                   # ApiClient: auth, refresh, retry, caching
│   ├── config/                # AppConfig: dart-define URLs, update feed
│   ├── models/                # JSON models (Order, Delivery, MenuItem, …)
│   ├── providers/             # ChangeNotifiers (Auth, Cart, Order, Owner, …)
│   ├── repositories/          # abstract interface + Api* implementation
│   ├── services/              # push, sockets, update checker, caches
│   ├── theme/                 # AppTheme + hand-rolled AppLocalizations (ar/en)
│   ├── utils/                 # formatters, maps/dialer launchers, json
│   └── widgets/               # shared widgets (nav, buttons, route_map, …)
└── features/                  # auth, cart, checkout, delivery, home, orders,
                               # owner, profile, restaurant(s), settings, support
```

Conventions worth knowing:

- **Repositories are interfaces** (`AuthRepository`) with `Api*` implementations
  (`ApiAuthRepository`) taking an `ApiClient`, so tests inject fakes via
  `mocktail`. Screens never call HTTP directly.
- **Session lifecycle:** `authProvider.onSessionEnded` resets every other
  provider, so a dead account's cart/orders never leak to the next user.
- **`ApiClient` is injectable** (`client`, `storage`) for tests.
- **Map/URL helpers are shared:** `core/widgets/route_map.dart` (route and
  live tracking maps) and `core/utils/maps_launcher.dart` (Google Maps /
  dialer) — do not re-inline them in screens.

### Polling and sockets

Sockets push order and driver events; polling is the deliberate fallback:

| Screen | Cadence | Notes |
| --- | --- | --- |
| Customer order tracking | 10s while a driver is moving, 30s otherwise | stops entirely on a terminal status; paused in background |
| Owner live delivery | 10s driver position | stops on terminal status; paused in background |
| Driver board | 20s | documented in `delivery_home_screen.dart`; socket refreshes immediately when it fires |
| Owner orders | 30s | socket-driven; poll is the safety net |
| Email verification | 5s | intentionally keeps running while backgrounded — that's when the user clicks the link |

## Localization and theming

- `AppLocalizations` is a hand-rolled key map (`app_localizations_data.dart`)
  with full `ar` and `en` tables and English fallback (`_t`). Arabic is the
  default and the UI is RTL. Add strings to **both** maps.
- Screens must use `AppLocalizations.of(context)` — no hard-coded labels.
- `AppTheme` provides light/dark `ThemeData` plus design tokens
  (spacing, radii, status colors). A **guardrail test**
  (`test/theme_guardrail_test.dart`) scans the codebase and fails on raw white
  surfaces or light-only color tokens outside the theme.

## Testing and CI

```bash
flutter analyze --no-fatal-infos   # must stay clean; CI runs plain flutter analyze
flutter test                       # 50 tests
dart fix --apply                   # autofixes enabled lints (e.g. directives_ordering)
```

- `analysis_options.yaml` extends `flutter_lints` with extra rules
  (`unawaited_futures`, `prefer_final_locals`, `directives_ordering`, …).
- Tests cover the `ApiClient` auth/retry paths, repositories' providers,
  cart/catalog logic, polling behavior, localization, the theme guardrail, and
  a widget boot smoke test (`createTaminiApp()` is `@visibleForTesting` for it).
- CI (`.github/workflows/ci.yml`) runs `flutter pub get`, `flutter analyze`,
  and `flutter test` on every push/PR to `master`.

## Releases and updates

- `release.yml` builds the versioned APK (`tamini-v<version>.apk`) and
  publishes `version.json` to GitHub Pages, which the in-app updater polls
  (cache-busted) to prompt users.
- `patch.yml` ships Shorebird code patches; `deploy-pages.yml` publishes the
  public Arabic download page.
- Icons are generated from `assets/images/launcher_icon.png` via
  `flutter_launcher_icons`.
