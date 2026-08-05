import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../home/screens/home_screen.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});
  @override
  State<DeliveryDashboardScreen> createState() => _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  int? _acceptingId;
  int? _completingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  Future<void> _load() async {
    final p = context.read<DeliveryProvider>();
    await Future.wait([p.loadAvailable(), p.loadMyDeliveries()]);
  }

  Future<void> _accept(Delivery d, AppLocalizations loc) async {
    setState(() => _acceptingId = d.id);
    final ok = await context.read<DeliveryProvider>().acceptDelivery(d.id);
    if (!mounted) return;
    setState(() => _acceptingId = null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? loc.acceptedSuccess : loc.errorOccurred),
      backgroundColor: ok ? AppTheme.success : AppTheme.danger,
    ));
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
            child: Text(loc.confirm, style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _completingId = d.id);
    final ok = await context.read<DeliveryProvider>().completeDelivery(d.id);
    if (!mounted) return;
    setState(() => _completingId = null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? loc.completedSuccess : loc.errorOccurred),
      backgroundColor: ok ? AppTheme.success : AppTheme.danger,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.deliveryDashboard, style: const TextStyle(fontFamily: 'Lalezar', fontSize: 22)),
          backgroundColor: AppTheme.orange500,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
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
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800),
            unselectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'متاح للتوصيل'),
              Tab(text: 'توصيلاتي'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAvailableTab(loc),
            _buildMyDeliveriesTab(loc),
          ],
        ),
      ),
    );
  }

  // ── Available tab ───────────────────────────────────────────

  Widget _buildAvailableTab(AppLocalizations loc) {
    return Consumer<DeliveryProvider>(
      builder: (context, p, _) {
        if (p.loading && p.available.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.orange500));
        }
        if (p.available.isEmpty) {
          return _emptyState(
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
            itemBuilder: (context, i) => _availableCard(p.available[i], loc),
          ),
        );
      },
    );
  }

  Widget _availableCard(Delivery d, AppLocalizations loc) {
    final customer = [d.customerName, d.customerPhone].whereType<String>().where((e) => e.isNotEmpty).join(' • ');
    return Container(
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
                decoration: const BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
                child: const Icon(Icons.restaurant, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.restaurantName, style: AppTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${loc.orderNumber}${d.orderId}', style: AppTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.infoBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  '${d.distance?.toStringAsFixed(1) ?? '—'} ${loc.km}',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.info),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _routeRow(icon: Icons.location_on_outlined, color: AppTheme.orange600, label: loc.toLabel, value: d.deliveryAddress ?? '—'),
          if (customer.isNotEmpty) ...[
            const SizedBox(height: 6),
            _routeRow(icon: Icons.person_outline, color: AppTheme.gray500, label: loc.customerLabel, value: customer),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.orange50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Text(
                  '${_formatPrice(d.calculatedFee ?? 0)} SYP',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.orange600),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                ),
                onPressed: _acceptingId == d.id ? null : () => _accept(d, loc),
                child: _acceptingId == d.id
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(loc.accept),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── My deliveries tab ───────────────────────────────────────

  Widget _buildMyDeliveriesTab(AppLocalizations loc) {
    return Consumer<DeliveryProvider>(
      builder: (context, p, _) {
        final all = p.myDeliveries;
        if (p.loading && all.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.orange500));
        }
        if (all.isEmpty) {
          return _emptyState(
            icon: Icons.local_shipping_outlined,
            title: loc.noMyDeliveries,
            hint: loc.noMyDeliveriesHint,
            onRefresh: p.loadMyDeliveries,
          );
        }
        final active = all.where((d) => d.isActive).toList();
        final done = all.where((d) => d.status == 'delivered').toList();
        return RefreshIndicator(
          color: AppTheme.orange500,
          onRefresh: p.loadMyDeliveries,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            children: [
              _statsRow(done, loc),
              const SizedBox(height: AppTheme.spaceMd),
              if (active.isNotEmpty) ...[
                _sectionLabel(loc.inProgress, AppTheme.orange600),
                ...active.map((d) => _myCard(d, loc, isActive: true)),
              ],
              if (done.isNotEmpty) ...[
                _sectionLabel(loc.deliveredLabel, AppTheme.success),
                ...done.map((d) => _myCard(d, loc, isActive: false)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _statsRow(List<Delivery> done, AppLocalizations loc) {
    final totalFee = done.fold<int>(0, (sum, d) => sum + (d.calculatedFee ?? 0));
    return Row(
      children: [
        _statCard(label: loc.completedCount, value: '${done.length}', icon: Icons.done_all, color: AppTheme.success),
        const SizedBox(width: AppTheme.spaceMd),
        _statCard(label: loc.totalEarnings, value: '${_formatPrice(totalFee)} SYP', icon: Icons.payments_outlined, color: AppTheme.orange600),
      ],
    );
  }

  Widget _statCard({required String label, required String value, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w900, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(label, style: AppTheme.labelSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSm, top: AppTheme.spaceXs),
      child: Row(
        children: [
          Container(width: 4, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _myCard(Delivery d, AppLocalizations loc, {required bool isActive}) {
    final customer = [d.customerName, d.customerPhone].whereType<String>().where((e) => e.isNotEmpty).join(' • ');
    return Container(
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
                    Text(d.restaurantName, style: AppTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${loc.orderNumber}${d.orderId}', style: AppTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (isActive ? AppTheme.warningBg : AppTheme.successBg).withValues(alpha: 0.7),
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
          _routeRow(icon: Icons.location_on_outlined, color: AppTheme.orange600, label: loc.toLabel, value: d.deliveryAddress ?? '—'),
          if (customer.isNotEmpty) ...[
            const SizedBox(height: 6),
            _routeRow(icon: Icons.person_outline, color: AppTheme.gray500, label: loc.customerLabel, value: customer),
          ],
          if (isActive) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '${_formatPrice(d.calculatedFee ?? 0)} SYP',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.orange600),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                  ),
                  onPressed: _completingId == d.id ? null : () => _complete(d, loc),
                  child: _completingId == d.id
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(loc.completeDelivery),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Shared helpers ──────────────────────────────────────────

  Widget _routeRow({required IconData icon, required Color color, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text('$label: ', style: AppTheme.labelSmall),
        Expanded(child: Text(value, style: AppTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _emptyState({required IconData icon, required String title, required String hint, required Future<void> Function() onRefresh}) {
    return RefreshIndicator(
      color: AppTheme.orange500,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceXl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.orange50),
                    child: Icon(icon, size: 46, color: AppTheme.orange300),
                  ),
                  const SizedBox(height: 20),
                  Text(title, textAlign: TextAlign.center, style: AppTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(hint, textAlign: TextAlign.center, style: AppTheme.bodySmall),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('تحديث'),
                    onPressed: onRefresh,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
