import 'session_store_io.dart'
    if (dart.library.js_interop) 'session_store_web.dart' as platform;

/// Browser session-scoped flags.
///
/// Uses [sessionStorage] on the web so values live only for the current tab
/// session and reappear once the browser/tab is reopened.
class SessionStore {
  SessionStore._();

  static const String _installPromptDismissedKey =
      'tamini.install_prompt.dismissed';

  /// Whether the install prompt was dismissed earlier in this session.
  static bool get isInstallPromptDismissed =>
      platform.getFlag(_installPromptDismissedKey);

  /// Marks the install prompt as dismissed for the rest of this session.
  static void dismissInstallPrompt() =>
      platform.setFlag(_installPromptDismissedKey);
}
