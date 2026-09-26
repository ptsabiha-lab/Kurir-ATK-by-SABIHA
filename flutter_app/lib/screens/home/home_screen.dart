import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/catalog_provider.dart';
import '../../theme/app_colors.dart';
import '../catalog/product_list_screen.dart';
import 'beranda_tab.dart';
import 'orders_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _berandaIndex = 0;
  static const _catalogIndex = 1;

  int _currentIndex = _berandaIndex;
  final _catalogSearchFocus = FocusNode();

  @override
  void dispose() {
    _catalogSearchFocus.dispose();
    super.dispose();
  }

  void _goTo(int index) => setState(() => _currentIndex = index);

  void _openCatalog() => _goTo(_catalogIndex);

  void _openCatalogWithCategory(int? categoryId) {
    context.read<CatalogProvider>().selectCategory(categoryId);
    _openCatalog();
  }

  void _openCatalogSearch() {
    _openCatalog();
    WidgetsBinding.instance.addPostFrameCallback((_) => _catalogSearchFocus.requestFocus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BerandaTab(
            onSearchTap: _openCatalogSearch,
            onOpenCatalog: _openCatalog,
            onSelectCategory: _openCatalogWithCategory,
          ),
          ProductListScreen(searchFocusNode: _catalogSearchFocus),
          OrdersTab(onBrowseCatalog: _openCatalog),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _goTo,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Katalog',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Pesanan',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}
