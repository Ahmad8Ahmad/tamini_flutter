import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('PushService.backgroundHandler skipped: $e');
  }
}

/// Thin wrapper around Firebase Cloud Messaging. Every entry point is
/// failure-tolerant: if Firebase isn't configured on this device/web build
/// (missing google-services.json / firebase options), the service silently
/// becomes a no-op so the rest of the app keeps working.
class PushService {
  static bool _initialized = false;
  static String? _token;

  static String? get token => _token;

  /// Called with the new token whenever FCM rotates it. The account's device
  /// token must be re-sent to the server on rotation; otherwise the backend
  /// keeps pushing to the old (now dead) token and notifications stop arriving.
  static Future<void> Function(String token)? onTokenRefresh;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint(
        'PushService: notification permission ${settings.authorizationStatus}',
      );
      await refreshToken();
      messaging.onTokenRefresh.listen((token) {
        _token = token;
        onTokenRefresh?.call(token);
      });
    } catch (e) {
      debugPrint('PushService.init skipped: $e');
      // Don't latch into the no-op state: allow a later init attempt (e.g.
      // after a transient Firebase failure).
      _initialized = false;
    }
  }

  /// Fetches the current FCM token, retrying a few times. On iOS the token is
  /// not always ready immediately after launch (APNs registration is async),
  /// which used to leave the app with no token to register at all.
  static Future<String?> refreshToken() async {
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          _token = token;
          return token;
        }
      } catch (e) {
        debugPrint('PushService.refreshToken attempt $attempt skipped: $e');
      }
      if (attempt < 3) await Future.delayed(const Duration(seconds: 2));
    }
    return _token;
  }
}
