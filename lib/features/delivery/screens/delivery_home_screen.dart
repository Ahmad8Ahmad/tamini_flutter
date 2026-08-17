import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/delivery_socket.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/language_selector.dart';
import '../../home/screens/home_screen.dart';
import 'delivery_detail_screen.dart';
import 'delivery_earnings_screen.dart';

class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({super.key});

  @override
  State<DeliveryHomeScreen> createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends State<DeliveryHomeScreen> {
  int _currentIndex = 0;
  int? _acceptingId;
  int? _completingId;
  DeliverySocketService? _socket;
  bool _live = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DeliveryProvider>().loadAll();
      _connectSocket();
    });
  }

  @override
  void dispose() {
    _socket?.close();
    super.dispose();
  }

  void _connectSocket() {
    final auth = context.read<AuthProvider>();
    _socket = DeliverySocketService(getToken: () => auth.accessToken);
    _socket!.onDeliveryEvent = (_) {
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
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.orange600,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          const LanguageSelector(),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _live ? AppTheme.success : AppTheme.gray300,
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
          return _emptyState(
            icon: Icons.delivery_dining,
            title: loc.noAvailableDeliveries,
            hint: loc.noAvailableDeliveriesHint,
            onRefresh: p.loadAvailable,
            loc: loc,
          );
        }
        return RefreshIndicator(
          color: AppTheme.orange500,
          onRefresh: p.loadAvailable,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            itemCount: p.available.length,
            itemBuilder: (context, i) => _availableCard(p.available[i], loc),
          ),
        );
      },
    );
  }

  Widget _availableCard(Delivery d, AppLocalizations loc) {
    final customer = [
      d.customerName,
      d.customerPhone,
    ].whereType<String>().where((e) => e.isNotEmpty).join(' \u2022 ');
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeliveryDetailScreen(delivery: d),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.restaurantName,
                      style: AppTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${loc.orderNumber}${d.orderId}',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.infoBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  '${d.distance?.toStringAsFixed(1) ?? '\u2014'} ${loc.km}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.info,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _routeRow(
            icon: Icons.location_on_outlined,
            color: AppTheme.orange600,
            label: loc.toLabel,
            value: d.deliveryAddress ?? '\u2014',
          ),
          if (customer.isNotEmpty) ...[
            const SizedBox(height: 6),
            _routeRow(
              icon: Icons.person_outline,
              color: AppTheme.gray500,
              label: loc.customerLabel,
              value: customer,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.orange50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Text(
                  '${_formatPrice(d.calculatedFee ?? 0)} SYP',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.orange600,
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  side: const BorderSide(color: AppTheme.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
                onPressed: () => _reject(d, loc),
                child: Text(
                  loc.reject,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.danger,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
                onPressed:
                    _acceptingId == d.id ? null : () => _accept(d, loc),
                child: _acceptingId == d.id
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(loc.accept),
              ),
            ],
          ),
        ],
      ),
    ),
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
          return _emptyState(
            icon: Icons.local_shipping_outlined,
            title: loc.noMyDeliveries,
            hint: loc.noMyDeliveriesHint,
            onRefresh: p.loadMyDeliveries,
            loc: loc,
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
              _buildActiveMapCard(active, loc),
              if (active.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spaceMd),
                _sectionLabel(loc.inProgress, AppTheme.orange600),
                ...active.map((d) => _myCard(d, loc, isActive: true)),
              ],
              if (done.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spaceMd),
                _sectionLabel(loc.deliveredLabel, AppTheme.success),
                ...done.map((d) => _myCard(d, loc, isActive: false)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveMapCard(List<Delivery> active, AppLocalizations loc) {
    if (active.isEmpty) return const SizedBox.shrink();
    final d = active.first;
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_shipping,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                loc.activeDelivery,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  loc.deliveryStatusText(d.status),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            d.restaurantName,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          _routeRow(
            icon: Icons.location_on_outlined,
            color: Colors.white70,
            label: loc.toLabel,
            value: d.deliveryAddress ?? '\u2014',
            labelColor: Colors.white60,
            valueColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${_formatPrice(d.calculatedFee ?? 0)} SYP',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 38,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: Text(loc.openInMaps),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.orange600,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusFull,
                      ),
                    ),
                  ),
                  onPressed: () => _openInMaps(d),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _myCard(Delivery d, AppLocalizations loc, {required bool isActive}) {
    final customer = [
      d.customerName,
      d.customerPhone,
    ].whereType<String>().where((e) => e.isNotEmpty).join(' \u2022 ');
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeliveryDetailScreen(delivery: d),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.restaurantName,
                      style: AppTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${loc.orderNumber}${d.orderId}',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (isActive ? AppTheme.warningBg : AppTheme.successBg)
                      .withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  loc.deliveryStatusText(d.status),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isActive ? AppTheme.warning : AppTheme.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _routeRow(
            icon: Icons.location_on_outlined,
            color: AppTheme.orange600,
            label: loc.toLabel,
            value: d.deliveryAddress ?? '\u2014',
          ),
          if (customer.isNotEmpty) ...[
            const SizedBox(height: 6),
            _routeRow(
              icon: Icons.person_outline,
              color: AppTheme.gray500,
              label: loc.customerLabel,
              value: customer,
            ),
          ],
          if (isActive) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '${_formatPrice(d.calculatedFee ?? 0)} SYP',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.orange600,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: Text(
                    loc.openInMaps,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.info,
                    side: const BorderSide(color: AppTheme.infoBg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusFull,
                      ),
                    ),
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () => _openInMaps(d),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusFull,
                      ),
                    ),
                  ),
                  onPressed: _completingId == d.id
                      ? null
                      : () => _complete(d, loc),
                  child: _completingId == d.id
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(loc.completeDelivery),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
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

  Widget _routeRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    Color? labelColor,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: AppTheme.labelSmall.copyWith(color: labelColor ?? AppTheme.gray400),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodySmall.copyWith(color: valueColor ?? AppTheme.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppTheme.spaceSm,
        top: AppTheme.spaceXs,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String hint,
    required Future<void> Function() onRefresh,
    AppLocalizations? loc,
  }) {
    final localizations = loc ?? AppLocalizations.of(context);
    return RefreshIndicator(
      color: AppTheme.orange500,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceXl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.orange50,
                      ),
                      child: Icon(
                        icon,
                        size: 46,
                        color: AppTheme.orange300,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hint,
                      textAlign: TextAlign.center,
                      style: AppTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(localizations.refresh),
                      onPressed: onRefresh,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNav(AppLocalizations loc) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.orange600,
      unselectedItemColor: AppTheme.gray400,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
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

  String _formatPrice(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
