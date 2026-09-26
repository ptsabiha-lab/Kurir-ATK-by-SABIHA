import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../cart/cart_screen.dart';
import '../catalog/product_list_screen.dart';
import '../deliveries/delivery_list_screen.dart';
import '../orders/order_list_screen.dart';
import 'profile_tab.dart';

class _Tab {
  const _Tab({required this.screen, required this.icon, required this.selectedIcon, required this.label});

  final Widget screen;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Halaman utama dengan menu bawah yang menyesuaikan role pengguna:
/// - Pelanggan : Katalog, Keranjang, Pesanan, Profil
/// - Kurir     : Pengiriman, Profil
/// - Admin     : Pesanan (kelola), Katalog, Profil
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _catalog = _Tab(
    screen: ProductListScreen(),
    icon: Icons.storefront_outlined,
    selectedIcon: Icons.storefront,
    label: 'Katalog',
  );
  static const _cart = _Tab(
    screen: CartScreen(),
    icon: Icons.shopping_cart_outlined,
    selectedIcon: Icons.shopping_cart,
    label: 'Keranjang',
  );
  static const _orders = _Tab(
    screen: OrderListScreen(),
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
    label: 'Pesanan',
  );
  static const _deliveries = _Tab(
    screen: DeliveryListScreen(),
    icon: Icons.delivery_dining_outlined,
    selectedIcon: Icons.delivery_dining,
    label: 'Pengiriman',
  );
  static const _profile = _Tab(
    screen: ProfileTab(),
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    label: 'Profil',
  );

  List<_Tab> _tabsFor(AuthProvider auth) {
    final user = auth.user;
    if (user?.isKurir ?? false) return const [_deliveries, _profile];
    if (user?.isAdmin ?? false) return const [_orders, _catalog, _profile];
    return const [_catalog, _cart, _orders, _profile];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabsFor(context.watch<AuthProvider>());
    final cartCount = context.watch<CartProvider>().totalQuantity;
    final index = _currentIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      body: IndexedStack(index: index, children: [for (final tab in tabs) tab.screen]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: _withCartBadge(tab, Icon(tab.icon), cartCount),
              selectedIcon: _withCartBadge(tab, Icon(tab.selectedIcon), cartCount),
              label: tab.label,
            ),
        ],
      ),
    );
  }

  Widget _withCartBadge(_Tab tab, Widget icon, int count) {
    if (!identical(tab, _cart) || count == 0) return icon;
    return Badge(label: Text('$count'), child: icon);
  }
}
