import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/catalog_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_style.dart';
import '../../widgets/product_card.dart';
import '../../widgets/state_view.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, this.searchFocusNode});

  /// Dipakai HomeScreen untuk langsung memfokuskan kolom pencarian
  /// saat pengguna mengetuk kotak cari di Beranda.
  final FocusNode? searchFocusNode;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadInitial();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CatalogProvider>().loadMore();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<CatalogProvider>().search('');
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Produk')),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: _SearchField(
                    controller: _searchController,
                    focusNode: widget.searchFocusNode,
                    onSubmitted: (value) => context.read<CatalogProvider>().search(value),
                    onClear: _clearSearch,
                  ),
                ),
                _CategoryChips(catalog: catalog),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<CatalogProvider>().loadInitial(),
              child: _ProductGrid(
                catalog: catalog,
                scrollController: _scrollController,
                onResetFilter: () {
                  _searchController.clear();
                  catalog.resetFilters();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final noBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      borderSide: BorderSide.none,
    );

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: 'Cari produk ATK...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'Hapus pencarian',
                  onPressed: onClear,
                ),
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: noBorder,
          enabledBorder: noBorder,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.catalog});

  final CatalogProvider catalog;

  @override
  Widget build(BuildContext context) {
    if (catalog.isLoadingCategories && catalog.categories.isEmpty) {
      return const SizedBox(
        height: 38,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _CategoryChip(
            label: 'Semua',
            icon: CategoryStyle.all.icon,
            selected: catalog.selectedCategoryId == null,
            onSelected: () => catalog.selectCategory(null),
          ),
          for (final category in catalog.categories) ...[
            const SizedBox(width: 8),
            _CategoryChip(
              label: category.name,
              icon: CategoryStyle.of(category.slug).icon,
              selected: catalog.selectedCategoryId == category.id,
              onSelected: () => catalog.selectCategory(category.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColors.textSecondary;

    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: selected ? Colors.white : AppColors.primary),
      label: Text(label),
      labelStyle: TextStyle(
        color: foreground,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        fontSize: 13,
      ),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      onSelected: (_) => onSelected(),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.catalog,
    required this.scrollController,
    required this.onResetFilter,
  });

  final CatalogProvider catalog;
  final ScrollController scrollController;
  final VoidCallback onResetFilter;

  @override
  Widget build(BuildContext context) {
    final Widget content;

    if (catalog.isLoadingProducts && catalog.products.isEmpty) {
      content = SliverGrid.builder(
        gridDelegate: productGridDelegate,
        itemCount: 6,
        itemBuilder: (_, _) => const ProductCardSkeleton(),
      );
    } else if (catalog.errorMessage != null && catalog.products.isEmpty) {
      content = SliverFillRemaining(
        hasScrollBody: false,
        child: StateView(
          isError: true,
          icon: Icons.wifi_off_rounded,
          title: 'Gagal memuat produk',
          message: catalog.errorMessage,
          actionLabel: 'Coba Lagi',
          onAction: () => catalog.loadInitial(),
        ),
      );
    } else if (catalog.products.isEmpty) {
      final hasFilter = catalog.searchQuery.isNotEmpty || catalog.selectedCategoryId != null;
      content = SliverFillRemaining(
        hasScrollBody: false,
        child: StateView(
          icon: Icons.search_off_rounded,
          title: 'Produk tidak ditemukan',
          message: hasFilter
              ? 'Coba kata kunci lain atau pilih kategori berbeda.'
              : 'Belum ada produk yang tersedia saat ini.',
          actionLabel: hasFilter ? 'Reset Filter' : null,
          onAction: hasFilter ? onResetFilter : null,
        ),
      );
    } else {
      content = SliverGrid.builder(
        gridDelegate: productGridDelegate,
        itemCount: catalog.products.length,
        itemBuilder: (_, index) => ProductCard(product: catalog.products[index]),
      );
    }

    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(padding: const EdgeInsets.all(16), sliver: content),
        if (catalog.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
