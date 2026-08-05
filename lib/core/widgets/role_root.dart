import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/screens/pending_approval_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../providers/providers.dart';

class RoleRoot extends StatefulWidget {
  const RoleRoot({super.key});

  @override
  State<RoleRoot> createState() => _RoleRootState();
}

class _RoleRootState extends State<RoleRoot> {
  bool _booted = false;
  String? _lastDestinationKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final loggedIn = await auth.tryAutoLogin();
    if (loggedIn) await cart.loadCart();
    if (!mounted) return;
    setState(() => _booted = true);
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
