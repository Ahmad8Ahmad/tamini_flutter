class AppConfig {
  AppConfig._();

  /// Current app version. Must stay in sync with `version:` in pubspec.yaml.
  static const String appVersion = '1.1.7';

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
