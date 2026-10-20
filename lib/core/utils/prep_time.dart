/// Preparation-time countdown helpers shared by the owner and customer sides.
///
/// The estimate is stored as an absolute UTC instant (`estimated_ready_at`).
/// Device clocks can disagree with the server, so the tracking payload carries
/// a `server_time` sample; the caller captures its offset once per fetch and
/// passes it in to correct "now".
library;

/// Offset that must be added to the device clock to approximate the server
/// clock. Capture it right after a tracking fetch (when [serverTime] is fresh)
/// and reuse it between polls; zero when the backend does not send the sample.
Duration serverClockOffset({required DateTime? serverTime, DateTime? deviceNow}) =>
    serverTime?.difference(deviceNow ?? DateTime.now()) ?? Duration.zero;

/// Device-clock "now" shifted by a previously captured [offset].
DateTime effectiveNow({DateTime? deviceNow, Duration offset = Duration.zero}) =>
    (deviceNow ?? DateTime.now()).add(offset);

/// Remaining time until [estimatedReadyAt], corrected by [offset]. Negative
/// when the estimate has already passed — callers decide how to word that.
Duration? prepRemaining({
  required DateTime? estimatedReadyAt,
  Duration offset = Duration.zero,
  DateTime? deviceNow,
}) => estimatedReadyAt?.difference(
  effectiveNow(deviceNow: deviceNow, offset: offset),
);

/// Local wall-clock time an instant falls at, formatted `H:mm` (e.g. `"8:05"`).
String formatReadyByTime(DateTime utcInstant) {
  final local = utcInstant.toLocal();
  return '${local.hour}:${local.minute.toString().padLeft(2, '0')}';
}
