import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/language_selector.dart';
import '../../home/screens/home_screen.dart';
import 'my_restaurant_screen.dart';
import 'restaurant_orders_screen.dart';
import 'restaurant_edit_screen.dart';
import 'delivery_settings_screen.dart';
import 'sales_dashboard_screen.dart';
import 'staff_management_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int _currentIndex = 0;
  Restaurant? _selectedRestaurant;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OwnerProvider>().loadMyRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = AppLocalizations.of(context);
    final user = auth.user;
    final hasSelected = _selectedRestaurant != null;

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
      body: _buildBody(loc, user),
      bottomNavigationBar: hasSelected
          ? _buildBottomNav(loc)
          : null,
    );
  }

  Widget _buildBody(AppLocalizations loc, User? user) {
    if (_selectedRestaurant == null) {
      return _buildRestaurantSelector(loc, user);
    }

    return IndexedStack(
      index: _currentIndex,
      children: [
        _buildRestaurantOverview(loc),
        RestaurantOrdersScreen(),
        _buildMenuPlaceholder(loc),
        SalesDashboardScreen(),
        _buildSettingsPlaceholder(loc),
      ],
    );
  }

  Widget _buildRestaurantSelector(AppLocalizations loc, User? user) {
    final owner = context.watch<OwnerProvider>();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(loc, user)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceLg,
              AppTheme.spaceLg,
              AppTheme.spaceLg,
              AppTheme.spaceSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.myRestaurants,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.orange600,
                  ),
                ),
                if (owner.myRestaurants.isNotEmpty)
                  Text(
                    '${owner.myRestaurants.length}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.orange500,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (owner.myRestaurantsLoading && owner.myRestaurants.isEmpty)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppTheme.orange500),
              ),
            ),
          )
        else if (owner.myRestaurantsError != null && owner.myRestaurants.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.danger,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.errorOccurred,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    owner.myRestaurantsError!,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppTheme.gray400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => owner.loadMyRestaurants(forceRefresh: true),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(
                      loc.retry,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orange500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.roundedLg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (owner.myRestaurants.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.store_outlined,
                    size: 64,
                    color: AppTheme.gray300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.noRestaurants,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.noRestaurantLinked,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppTheme.gray400,
                    ),
                  ),
                  if (owner.myRestaurantsRawResponse != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.gray100,
                        borderRadius: AppTheme.roundedLg,
                      ),
                      child: Text(
                        'API response: ${owner.myRestaurantsRawResponse}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: AppTheme.gray500,
                        ),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => owner.loadMyRestaurants(forceRefresh: true),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(
                      loc.retry,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orange500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.roundedLg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildRestaurantCard(
                owner.myRestaurants[i],
                loc,
                owner,
              ),
              childCount: owner.myRestaurants.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations loc, User? user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceLg,
        AppTheme.spaceMd,
        AppTheme.spaceLg,
        AppTheme.spaceLg,
      ),
      color: AppTheme.gray100,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppTheme.orange50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant,
              color: AppTheme.orange500,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.welcomeBackHello,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.username ?? user?.email ?? '',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.orange50,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              loc.restaurantOwner,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.orange600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(
    Restaurant r,
    AppLocalizations loc,
    OwnerProvider owner,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceLg,
        vertical: AppTheme.spaceMd,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowMd,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _selectedRestaurant = r;
                  _currentIndex = 0;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 140,
                    child: r.coverImage != null
                        ? CachedNetworkImage(
                            imageUrl: r.coverImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => const _CoverFallback(),
                            errorWidget: (_, _, _) => const _CoverFallback(),
                          )
                        : const _CoverFallback(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spaceMd,
                      0,
                      AppTheme.spaceMd,
                      AppTheme.spaceSm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -28),
                              child: Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.orange50,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: r.logo != null
                                    ? CachedNetworkImage(
                                        imageUrl: r.logo!,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, _, _) => const Icon(
                                          Icons.restaurant,
                                          color: AppTheme.orange300,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.restaurant,
                                        color: AppTheme.orange300,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.name,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: AppTheme.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (r.address != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: AppTheme.orange400,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                r.address!,
                                                style: const TextStyle(
                                                  fontFamily: 'Cairo',
                                                  color:
                                                      AppTheme.textSecondary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _chip(
                              r.isApproved
                                  ? loc.approved
                                  : loc.restaurantNotApproved,
                              icon: r.isApproved
                                  ? Icons.verified
                                  : Icons.hourglass_top,
                              bg: r.isApproved
                                  ? AppTheme.successBg
                                  : AppTheme.warningBg,
                              fg: r.isApproved
                                  ? AppTheme.success
                                  : AppTheme.warning,
                            ),
                            if (r.isTrendy) ...[
                              const SizedBox(width: 8),
                              _chip(
                                loc.trendy,
                                icon: Icons.local_fire_department,
                                bg: AppTheme.orange50,
                                fg: AppTheme.orange600,
                              ),
                            ],
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    loc.manage,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Directionality.of(context) ==
                                            TextDirection.rtl
                                        ? Icons.arrow_back
                                        : Icons.arrow_forward,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              indent: AppTheme.spaceMd,
              endIndent: AppTheme.spaceMd,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceMd,
                AppTheme.spaceXs,
                AppTheme.spaceMd,
                AppTheme.spaceSm,
              ),
              child: Row(
                children: [
                  Icon(
                    r.isActive ? Icons.storefront : Icons.storefront_outlined,
                    size: 16,
                    color: r.isActive ? AppTheme.success : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    r.isActive ? loc.open : loc.closed,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color:
                          r.isActive ? AppTheme.success : AppTheme.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: r.isActive,
                    activeTrackColor: AppTheme.orange400,
                    onChanged: (_) => _toggleActive(r, loc),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleActive(Restaurant r, AppLocalizations loc) async {
    final target = !r.isActive;
    final provider = context.read<OwnerProvider>();
    final result = await provider.setRestaurantActive(
      id: r.id,
      isActive: target,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result != null ? loc.savedSuccessfully : loc.errorOccurred,
        ),
        backgroundColor: result != null ? AppTheme.success : AppTheme.danger,
      ),
    );
  }

  Widget _buildRestaurantOverview(AppLocalizations loc) {
    final r = _selectedRestaurant!;
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildOverviewHeader(r, loc),
          const SizedBox(height: AppTheme.spaceMd),
          _buildQuickActions(r, loc),
          const SizedBox(height: AppTheme.spaceMd),
        ],
      ),
    );
  }

  Widget _buildOverviewHeader(Restaurant r, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppTheme.roundedLg,
            ),
            child: ClipRRect(
              borderRadius: AppTheme.roundedLg,
              child: r.logo != null
                  ? CachedNetworkImage(
                      imageUrl: r.logo!,
                      fit: BoxFit.cover,
                      width: 64,
                      height: 64,
                    )
                  : const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (r.address != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      r.address!,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Restaurant r, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.manage,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              Expanded(
                child: _actionCard(
                  icon: Icons.receipt_long_outlined,
                  label: loc.orders,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: _actionCard(
                  icon: Icons.restaurant_menu,
                  label: loc.menuItems,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyRestaurantScreen(restaurant: r),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              Expanded(
                child: _actionCard(
                  icon: Icons.insights_outlined,
                  label: loc.salesDashboard,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: _actionCard(
                  icon: Icons.edit_outlined,
                  label: loc.editRestaurant,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RestaurantEditScreen(restaurant: r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              Expanded(
                child: _actionCard(
                  icon: Icons.delivery_dining_outlined,
                  label: loc.deliverySettings,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DeliverySettingsScreen(restaurant: r),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: _actionCard(
                  icon: Icons.people_outline,
                  label: loc.staffManagement,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StaffManagementScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.roundedLg,
        boxShadow: AppTheme.shadowSm,
      ),
      child: InkWell(
        borderRadius: AppTheme.roundedLg,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMd,
            vertical: AppTheme.spaceLg,
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.orange50,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.orange600, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuPlaceholder(AppLocalizations loc) {
    final r = _selectedRestaurant!;
    return MyRestaurantScreen(restaurant: r);
  }

  Widget _buildSettingsPlaceholder(AppLocalizations loc) {
    final r = _selectedRestaurant!;
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      children: [
        _settingsTile(
          icon: Icons.edit_outlined,
          title: loc.editRestaurant,
          subtitle: loc.restaurantDescription,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantEditScreen(restaurant: r),
            ),
          ),
        ),
        _settingsTile(
          icon: Icons.delivery_dining_outlined,
          title: loc.deliverySettings,
          subtitle: loc.deliverySettingsHint,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeliverySettingsScreen(restaurant: r),
            ),
          ),
        ),
        _settingsTile(
          icon: Icons.people_outline,
          title: loc.staffManagement,
          subtitle: '',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StaffManagementScreen(),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceLg),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _selectedRestaurant = null;
              _currentIndex = 0;
            });
          },
          icon: const Icon(Icons.storefront_outlined, color: AppTheme.orange600),
          label: Text(
            loc.myRestaurants,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w800,
              color: AppTheme.orange600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.orange300),
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.roundedLg,
            ),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.roundedLg,
        boxShadow: AppTheme.shadowSm,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppTheme.orange50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.orange600, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppTheme.gray400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppTheme.gray400,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
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
          icon: const Icon(Icons.home_outlined, size: 22),
          activeIcon: const Icon(Icons.home, size: 22),
          label: loc.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long_outlined, size: 22),
          activeIcon: const Icon(Icons.receipt_long, size: 22),
          label: loc.orders,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.restaurant_menu, size: 22),
          activeIcon: const Icon(Icons.restaurant_menu, size: 22),
          label: loc.menu,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.insights_outlined, size: 22),
          activeIcon: const Icon(Icons.insights, size: 22),
          label: loc.salesDashboard,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined, size: 22),
          activeIcon: const Icon(Icons.settings, size: 22),
          label: loc.deliverySettings,
        ),
      ],
    );
  }

  Widget _chip(
    String text, {
    required IconData icon,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: const Center(
        child: Icon(Icons.restaurant, color: Colors.white54, size: 48),
      ),
    );
  }
}
