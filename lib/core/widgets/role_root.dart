import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/screens/pending_approval_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../providers/providers.dart';
import '../services/update_service.dart';
import 'update_dialog.dart';

class RoleRoot extends StatefulWidget {
  const RoleRoot({super.key});

  @override
  State<RoleRoot> createState() => _RoleRootState();
}

class _RoleRootState extends State<RoleRoot> {
  bool _booted = false;
  String? _lastDestinationKey;
  Timer? _keepAliveTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
    // The backend sleeps after ~15 min idle on free-tier hosting, causing
    // multi-second cold starts on the next request. Ping it while the app is
    // open so sessions stay warm.
    _keepAliveTimer = Timer.periodic(const Duration(minutes: 4), (_) {
      if (mounted) context.read<SupportProvider>().fetchSiteSettings();
    });
  }

  @override
  void dispose() {
    _keepAliveTimer?.cancel();
    super.dispose();
  }

  Future<void> _boot() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final loggedIn = await auth.tryAutoLogin();
    if (loggedIn) await cart.loadCart();
    if (!mounted) return;
    setState(() => _booted = true);
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final update = await UpdateService.checkForUpdate();
    if (update == null || !mounted) return;
    showUpdateDialog(context, update);
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
