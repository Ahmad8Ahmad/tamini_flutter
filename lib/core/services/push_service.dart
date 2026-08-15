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
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await _refreshToken();
      messaging.onTokenRefresh.listen((token) {
        _token = token;
      });
    } catch (e) {
      debugPrint('PushService.init skipped: $e');
    }
  }

  static Future<void> _refreshToken() async {
    try {
      _token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('PushService.getToken skipped: $e');
    }
  }
}
