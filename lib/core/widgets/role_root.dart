import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/screens/pending_approval_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../providers/providers.dart';
import '../services/session_store.dart';
import '../services/update_service.dart';
import '../services/update_store.dart';
import 'install_prompt_dialog.dart';
import 'update_dialog.dart';

class RoleRoot extends StatefulWidget {
  const RoleRoot({super.key});

  @override
  State<RoleRoot> createState() => _RoleRootState();
}

class _RoleRootState extends State<RoleRoot> with WidgetsBindingObserver {
  bool _booted = false;
  String? _lastDestinationKey;
  Timer? _keepAliveTimer;
  Timer? _updateTimer;
  bool _updateCheckRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
    // The backend sleeps after ~15 min idle on free-tier hosting, causing
    // multi-second cold starts on the next request. Ping it while the app is
    // open so sessions stay warm.
    _keepAliveTimer = Timer.periodic(const Duration(minutes: 4), (_) {
      if (mounted) context.read<SupportProvider>().fetchSiteSettings();
    });
    // Re-check for app updates while the app stays open for a long time.
    _updateTimer = Timer.periodic(const Duration(hours: 6), (_) => _checkForUpdate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _keepAliveTimer?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkForUpdate();
  }

  Future<void> _boot() async {
    try {
      await _restoreSession().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('RoleRoot._boot: session restore failed: $e');
    }
    if (!mounted) return;
    setState(() => _booted = true);
    _checkForUpdate();
    _showInstallPromptIfNeeded();
  }

  /// Restores the logged-in session and cart. Runs inside a timeout so a slow
  /// or hanging storage/network call can never leave the app stuck on the
  /// splash screen.
  Future<void> _restoreSession() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final loggedIn = await auth.tryAutoLogin();
    if (loggedIn) await cart.loadCart();
  }

  void _showInstallPromptIfNeeded() {
    if (!kIsWeb) return;
    if (SessionStore.isInstallPromptDismissed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showInstallPromptDialog(context);
    });
  }

  Future<void> _checkForUpdate() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android) return;
    if (_updateCheckRunning || !mounted) return;
    _updateCheckRunning = true;
    try {
      final update = await UpdateService.checkForUpdate();
      if (update == null || !mounted) return;
      // Ask only once per release, so "Later" doesn't nag until a newer
      // version is published.
      if (await UpdateStore.lastPromptedVersion == update.version) return;
      if (mounted) {
        await showUpdateDialog(context, update);
        if (mounted) await UpdateStore.setLastPromptedVersion(update.version);
      }
    } finally {
      _updateCheckRunning = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!_booted) return const SplashScreen();

    final user = auth.user;
    final key = user == null ? 'guest' : '${user.role}:${user.isApproved}';
    if (key != _lastDestinationKey) {
      _lastDestinationKey = key;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
    return buildRoleDestination(user);
  }
}
