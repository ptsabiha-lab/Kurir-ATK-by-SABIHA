import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../theme/app_colors.dart';
import '../cart/cart_screen.dart';
import '../catalog/product_list_screen.dart';
import '../deliveries/delivery_list_screen.dart';
import '../orders/order_list_screen.dart';
import 'beranda_tab.dart';
import 'profile_tab.dart';

enum _Tab { beranda, katalog, keranjang, pesanan, pengiriman, akun }

/// Halaman utama dengan menu bawah yang menyesuaikan role pengguna:
/// - Pelanggan : Beranda, Katalog, Keranjang, Pesanan, Akun
/// - Kurir     : Pengiriman, Akun
/// - Admin     : Pesanan (kelola), Katalog, Akun
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _catalogSearchFocus = FocusNode();

  @override
  void dispose() {
    _catalogSearchFocus.dispose();
    super.dispose();
  }

  List<_Tab> _tabsFor(AuthProvider auth) {
    final user = auth.user;
    if (user?.isKurir ?? false) return const [_Tab.pengiriman, _Tab.akun];
    if (user?.isAdmin ?? false) return const [_Tab.pesanan, _Tab.katalog, _Tab.akun];
    return const [_Tab.beranda, _Tab.katalog, _Tab.keranjang, _Tab.pesanan, _Tab.akun];
  }

  void _goTo(_Tab tab) {
    final index = _tabsFor(context.read<AuthProvider>()).indexOf(tab);
    if (index >= 0) setState(() => _currentIndex = index);
  }

  void _openCatalog() => _goTo(_Tab.katalog);

  void _openCatalogWithCategory(int? categoryId) {
    context.read<CatalogProvider>().selectCategory(categoryId);
    _openCatalog();
  }

  void _openCatalogSearch() {
    _openCatalog();
    WidgetsBinding.instance.addPostFrameCallback((_) => _catalogSearchFocus.requestFocus());
  }

  Widget _screenFor(_Tab tab) => switch (tab) {
    _Tab.beranda => BerandaTab(
      onSearchTap: _openCatalogSearch,
      onOpenCatalog: _openCatalog,
      onSelectCategory: _openCatalogWithCategory,
    ),
    _Tab.katalog => ProductListScreen(searchFocusNode: _catalogSearchFocus),
    _Tab.keranjang => const CartScreen(),
    _Tab.pesanan => const OrderListScreen(),
    _Tab.pengiriman => const DeliveryListScreen(),
    _Tab.akun => const ProfileTab(),
  };

  NavigationDestination _destinationFor(_Tab tab, int cartCount) {
    final (icon, selectedIcon, label) = switch (tab) {
      _Tab.beranda => (Icons.home_outlined, Icons.home_rounded, 'Beranda'),
      _Tab.katalog => (Icons.grid_view_outlined, Icons.grid_view_rounded, 'Katalog'),
      _Tab.keranjang => (Icons.shopping_cart_outlined, Icons.shopping_cart_rounded, 'Keranjang'),
      _Tab.pesanan => (Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Pesanan'),
      _Tab.pengiriman => (Icons.delivery_dining_outlined, Icons.delivery_dining, 'Pengiriman'),
      _Tab.akun => (Icons.person_outline_rounded, Icons.person_rounded, 'Akun'),
    };

    Widget withBadge(IconData data) {
      final iconWidget = Icon(data);
      if (tab != _Tab.keranjang || cartCount == 0) return iconWidget;
      return Badge(label: Text('$cartCount'), child: iconWidget);
    }

    return NavigationDestination(icon: withBadge(icon), selectedIcon: withBadge(selectedIcon), label: label);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabsFor(context.watch<AuthProvider>());
    final cartCount = context.watch<CartProvider>().totalQuantity;
    final index = _currentIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      body: IndexedStack(index: index, children: [for (final tab in tabs) _screenFor(tab)]),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: [for (final tab in tabs) _destinationFor(tab, cartCount)],
        ),
      ),
    );
  }
}
