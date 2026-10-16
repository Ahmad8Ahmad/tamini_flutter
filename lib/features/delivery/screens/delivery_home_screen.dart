import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/delivery_socket.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/screens/home_screen.dart';
import 'delivery_earnings_screen.dart';
import '../widgets/active_delivery_map_card.dart';
import '../widgets/available_delivery_card.dart';
import '../widgets/delivery_empty_state.dart';
import '../widgets/delivery_section_label.dart';
import '../widgets/my_delivery_card.dart';

class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({super.key});

  @override
  State<DeliveryHomeScreen> createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends State<DeliveryHomeScreen>
    with WidgetsBindingObserver {
  /// How often to re-ask the available-deliveries board while foregrounded.
  ///
  /// The driver board is derived server-side: `GET /deliveries/available/`
  /// creates the searchable `Delivery` rows on demand from orders that have
  /// reached an out-for-delivery status. No client ever creates them, and the
  /// only push for that transition lives in the website's `mark_as_out` view,
  /// so on the app there is no event to react to and a driver would see a new
  /// job only by pulling to refresh. This poll is what makes jobs appear
  /// without a backend deploy; it becomes redundant once the server announces
  /// the transition, because the socket event already refreshes immediately.
  static const _pollInterval = Duration(seconds: 20);

  int _currentIndex = 0;
  int? _acceptingId;
  int? _completingId;
  DeliverySocketService? _socket;
  bool _live = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DeliveryProvider>().loadAll();
      _connectSocket();
    });
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _socket?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A driver's phone spends most of its time locked in a pocket, and the
    // backend is a free tier that is meant to be allowed to sleep. Polling
    // while backgrounded keeps it awake for nobody.
    if (state == AppLifecycleState.resumed) {
      _startPolling();
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (!mounted) return;
      context.read<DeliveryProvider>().loadAvailable();
    });
  }

  void _connectSocket() {
    final auth = context.read<AuthProvider>();
    _socket = DeliverySocketService(getToken: () => auth.accessToken);
    _socket!.onEvent = (_) {
      if (!mounted) return;
      context.read<DeliveryProvider>().loadAll();
    };
    _socket!.onConnectionChanged = (connected) {
      if (!mounted) return;
      setState(() => _live = connected);
    };
    _socket!.connect();
  }

  Future<void> _accept(Delivery d, AppLocalizations loc) async {
    setState(() => _acceptingId = d.id);
    final ok = await context.read<DeliveryProvider>().acceptDelivery(d.id);
    if (!mounted) return;
    setState(() => _acceptingId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? loc.acceptedSuccess : loc.errorOccurred),
        backgroundColor: ok ? AppTheme.success : AppTheme.danger,
      ),
    );
  }

  Future<void> _reject(Delivery d, AppLocalizations loc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.cancel),
        content: Text(loc.cancelDeliveryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              loc.reject,
              style: const TextStyle(
                color: AppTheme.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await context.read<DeliveryProvider>().rejectDelivery(d.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? loc.rejectedSuccess : loc.errorOccurred),
        backgroundColor: ok ? AppTheme.gray600 : AppTheme.danger,
      ),
    );
  }

  Future<void> _complete(Delivery d, AppLocalizations loc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.completeDelivery),
        content: Text(loc.completeDeliveryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              loc.confirm,
              style: const TextStyle(
                color: AppTheme.success,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _completingId = d.id);
    final ok = await context.read<DeliveryProvider>().completeDelivery(d.id);
    if (!mounted) return;
    setState(() => _completingId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? loc.completedSuccess : loc.errorOccurred),
        backgroundColor: ok ? AppTheme.success : AppTheme.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.appName,
          style: const TextStyle(
            fontFamily: 'Lalezar',
            fontSize: 22,
            color: AppTheme.orange600,
          ),
        ),
        foregroundColor: AppTheme.orange600,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _live ? AppTheme.success : context.colors.textMuted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            tooltip: loc.backToHome,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildAvailableTab(loc),
          _buildMyDeliveriesTab(loc),
          DeliveryEarningsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(loc),
    );
  }

  // ── Available Tab ──────────────────────────────────────────

  Widget _buildAvailableTab(AppLocalizations loc) {
    return Consumer<DeliveryProvider>(
      builder: (context, p, _) {
        if (p.loadingAvailable && p.available.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.orange500),
          );
        }
        if (p.available.isEmpty) {
          return DeliveryEmptyState(
            icon: Icons.delivery_dining,
            title: loc.noAvailableDeliveries,
            hint: loc.noAvailableDeliveriesHint,
            onRefresh: p.loadAvailable,
          );
        }
        return RefreshIndicator(
          color: AppTheme.orange500,
          onRefresh: p.loadAvailable,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            itemCount: p.available.length,
            itemBuilder: (context, i) {
              final d = p.available[i];
              return AvailableDeliveryCard(
                delivery: d,
                isAccepting: _acceptingId == d.id,
                onAccept: () => _accept(d, loc),
                onReject: () => _reject(d, loc),
              );
            },
          ),
        );
      },
    );
  }

  // ── My Deliveries Tab ──────────────────────────────────────

  Widget _buildMyDeliveriesTab(AppLocalizations loc) {
    return Consumer<DeliveryProvider>(
      builder: (context, p, _) {
        final all = p.myDeliveries;
        if (p.loadingMyDeliveries && all.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.orange500),
          );
        }
        if (all.isEmpty) {
          return DeliveryEmptyState(
            icon: Icons.local_shipping_outlined,
            title: loc.noMyDeliveries,
            hint: loc.noMyDeliveriesHint,
            onRefresh: p.loadMyDeliveries,
          );
        }
        final active = p.activeDeliveries;
        final done = p.completedDeliveries;
        return RefreshIndicator(
          color: AppTheme.orange500,
          onRefresh: p.loadMyDeliveries,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            children: [
              if (active.isNotEmpty)
                ActiveDeliveryMapCard(
                  delivery: active.first,
                  onOpenMaps: () => _openInMaps(active.first),
                ),
              if (active.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spaceMd),
                DeliverySectionLabel(
                  text: loc.inProgress,
                  color: AppTheme.orange600,
                ),
                ...active.map(
                  (d) => MyDeliveryCard(
                    delivery: d,
                    isActive: true,
                    isCompleting: _completingId == d.id,
                    onOpenMaps: () => _openInMaps(d),
                    onComplete: () => _complete(d, loc),
                  ),
                ),
              ],
              if (done.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spaceMd),
                DeliverySectionLabel(
                  text: loc.deliveredLabel,
                  color: AppTheme.success,
                ),
                ...done.map(
                  (d) => MyDeliveryCard(
                    delivery: d,
                    isActive: false,
                    isCompleting: _completingId == d.id,
                    onOpenMaps: () => _openInMaps(d),
                    onComplete: () => _complete(d, loc),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── Shared Helpers ─────────────────────────────────────────

  Future<void> _openInMaps(Delivery d) async {
    final addr = d.deliveryAddress;
    final Uri uri = addr != null && addr.isNotEmpty
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(addr)}',
          )
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(d.restaurantName)}',
          );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  BottomNavigationBar _buildBottomNav(AppLocalizations loc) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.delivery_dining_outlined, size: 22),
          activeIcon: const Icon(Icons.delivery_dining, size: 22),
          label: loc.availableDeliveries,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.local_shipping_outlined, size: 22),
          activeIcon: const Icon(Icons.local_shipping, size: 22),
          label: loc.myDeliveries,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_balance_wallet_outlined, size: 22),
          activeIcon: const Icon(Icons.account_balance_wallet, size: 22),
          label: loc.earnings,
        ),
      ],
    );
  }
}
