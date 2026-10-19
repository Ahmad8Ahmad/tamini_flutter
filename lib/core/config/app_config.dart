class AppConfig {
  AppConfig._();

  /// Current app version. In release builds this is injected from the pubspec
  /// version via `--dart-define=APP_VERSION=<version>` (see release.yml), so
  /// pubspec.yaml stays the single source of truth. The default only covers
  /// local `flutter run`, where no dart-define is passed.
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.2.8',
  );

  /// Base URL of the backend REST API. Override per flavor/environment with
  /// `--dart-define=API_BASE_URL=https://staging.host/api`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://tamini.onrender.com/api',
  );

  /// Base URL of the backend WebSocket routes (no trailing slash). Override
  /// with `--dart-define=WS_BASE_URL=wss://staging.host/ws`.
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'wss://tamini.onrender.com/ws',
  );

  /// Base URL where version.json and APK files are published.
  /// Set to your own host (Cloudflare Pages, your server, etc.) if not using
  /// GitHub Releases.
  static const String releaseBaseUrl =
      'https://github.com/Ahmad8Ahmad/tamini_flutter/releases/latest/download';

  /// Update feed hosted on GitHub Pages (alongside the PWA). Served by the
  /// deploy-pages workflow with a fresh version.json on every release, and
  /// more reliably reachable from the target network than the release CDN.
  static const String updateFeedUrl =
      'https://Ahmad8Ahmad.github.io/tamini_flutter/version.json';

  /// Cache-busting keeps stale HTTP/CDN copies of version.json from
  /// suppressing the update prompt.
  static String get updateCheckUrl =>
      '$updateFeedUrl?cb=${DateTime.now().millisecondsSinceEpoch}';

  /// Public Arabic RTL download landing page (hosted alongside the PWA).
  static const String downloadPageUrl =
      'https://Ahmad8Ahmad.github.io/tamini_flutter/download.html';

  static String fallbackApkUrl(String version) =>
      '$releaseBaseUrl/tamini-v$version.apk';
}
