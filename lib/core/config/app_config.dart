class AppConfig {
  AppConfig._();

  /// Current app version. Must stay in sync with `version:` in pubspec.yaml.
  static const String appVersion = '1.0.0';

  /// Base URL where version.json and APK files are published.
  /// Set to your own host (Cloudflare Pages, your server, etc.) if not using
  /// GitHub Releases.
  static const String releaseBaseUrl =
      'https://github.com/Ahmad8Ahmad/tamini_flutter/releases/latest/download';

  static String get updateCheckUrl => '$releaseBaseUrl/version.json';

  static String fallbackApkUrl(String version) =>
      '$releaseBaseUrl/tamini-v$version.apk';
}
