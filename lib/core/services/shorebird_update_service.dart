import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Thin wrapper around the Shorebird code-push updater.
///
/// Shorebird lets us ship Dart-only patches over the air without a store
/// release or a full-APK download. On devices that were NOT built with the
/// Shorebird engine, [ShorebirdUpdater.isAvailable] is false and every method
/// here becomes a no-op, so the rest of the app keeps working normally.
class ShorebirdUpdateService {
  ShorebirdUpdateService._();

  static final ShorebirdUpdater _updater = ShorebirdUpdater();

  static bool get isAvailable => _updater.isAvailable;

  /// Fetches and applies any available patch. Runs completely in the
  /// background so it never blocks startup or the UI. The patch is applied
  /// automatically on the next cold start, exactly like the default Shorebird
  /// update flow.
  static Future<void> checkAndApply() async {
    if (!isAvailable) return;
    try {
      final status = await _updater.checkForUpdate();
      if (status == UpdateStatus.outdated) {
        await _updater.update();
        if (kDebugMode) debugPrint('[Shorebird] patch downloaded & installed');
      }
    } catch (e) {
      debugPrint('[Shorebird] update failed: $e');
    }
  }
}
