import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/screens/pending_approval_screen.dart';
import '../providers/providers.dart';
import '../theme/app_localizations.dart';
import '../theme/app_theme.dart';

class DashboardButton extends StatelessWidget {
  const DashboardButton({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.user?.role;
    if (role != 'restaurant' && role != 'delivery') return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.dashboard_outlined, color: AppTheme.orange500),
      tooltip: AppLocalizations.of(context).myDashboard,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => buildRoleDestination(auth.user)),
      ),
    );
  }
}
