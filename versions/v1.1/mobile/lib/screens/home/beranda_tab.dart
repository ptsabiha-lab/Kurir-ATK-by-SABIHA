import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../services/api_client.dart';
import '../../services/catalog_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/category_style.dart';
import '../../widgets/product_card.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_view.dart';

/// Halaman depan ala marketplace: sapaan, pencarian, banner,
/// kategori, dan produk terbaru.
class BerandaTab extends StatefulWidget {
  const BerandaTab({
    super.key,
    required this.onSearchTap,
    required this.onOpenCatalog,
    required this.onSelectCategory,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onOpenCatalog;
  final ValueChanged<int?> onSelectCategory;

  @override
  State<BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  static const _maxFeatured = 6;

  late Future<ProductPage> _featuredFuture = _fetchFeatured();

  Future<ProductPage> _fetchFeatured() => CatalogService.instance.fetchProducts();

  Future<void> _refresh() async {
    final future = _fetchFeatured();
    setState(() => _featuredFuture = future);
    await Future.wait([
      future.then((_) {}, onError: (_) {}),
      context.read<CatalogProvider>().loadCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _Header(onSearchTap: widget.onSearchTap)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverList.list(
                children: [
                  _PromoBanner(onShopNow: widget.onOpenCatalog),
                  const SizedBox(height: 16),
                  const _BenefitStrip(),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'Kategori',
                    actionLabel: 'Lihat semua',
                    onAction: widget.onOpenCatalog,
                  ),
                  const SizedBox(height: 8),
                  _CategoryGrid(onSelectCategory: widget.onSelectCategory),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: 'Produk Terbaru',
                    actionLabel: 'Lihat semua',
                    onAction: widget.onOpenCatalog,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            _FeaturedProducts(
              future: _featuredFuture,
              maxItems: _maxFeatured,
              onRetry: _refresh,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearchTap});

  final VoidCallback onSearchTap;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final firstName = (user?.name.trim().split(' ').first) ?? '';

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BrandMark(size: 36, onDark: true),
                  const SizedBox(width: 10),
                  const BrandWordmark(fontSize: 19, onDark: true),
                  const Spacer(),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    child: Text(
                      firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                firstName.isNotEmpty ? '$_greeting, $firstName' : _greeting,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mau belanja kebutuhan ATK apa hari ini?',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 18),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: InkWell(
                  onTap: onSearchTap,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppColors.primary),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cari pulpen, kertas, map...',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onShopNow});

  final VoidCallback onShopNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.navy, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -24,
            child: Icon(
              Icons.local_shipping_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'KURIR ATK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Belanja ATK tanpa ribet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const SizedBox(
                  width: 240,
                  child: Text(
                    'Pesan dari aplikasi, kurir kami antar langsung ke kantor atau sekolah Anda.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onShopNow,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Belanja Sekarang'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitStrip extends StatelessWidget {
  const _BenefitStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.local_shipping_outlined, 'Diantar Kurir'),
      (Icons.inventory_2_outlined, 'Stok Terkini'),
      (Icons.touch_app_outlined, 'Pesan Mudah'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                const SizedBox(
                  height: 28,
                  child: VerticalDivider(width: 1, color: AppColors.border),
                ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(items[i].$1, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        items[i].$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.onSelectCategory});

  final ValueChanged<int?> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();

    if (catalog.isLoadingCategories && catalog.categories.isEmpty) {
      return Row(
        children: List.generate(
          4,
          (_) => const Expanded(
            child: Column(
              children: [
                SkeletonBox(width: 56, height: 56, radius: 16),
                SizedBox(height: 8),
                SkeletonBox(width: 48, height: 10),
              ],
            ),
          ),
        ),
      );
    }

    final tiles = <Widget>[
      _CategoryTile(
        label: 'Semua',
        style: CategoryStyle.all,
        onTap: () => onSelectCategory(null),
      ),
      for (final ProductCategory category in catalog.categories)
        _CategoryTile(
          label: category.name,
          style: CategoryStyle.of(category.slug),
          onTap: () => onSelectCategory(category.id),
        ),
    ];

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 96,
        mainAxisExtent: 100,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      children: tiles,
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.label, required this.style, required this.onTap});

  final String label;
  final CategoryStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: style.softColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(style.icon, color: style.color, size: 22),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedProducts extends StatelessWidget {
  const _FeaturedProducts({required this.future, required this.maxItems, required this.onRetry});

  final Future<ProductPage> future;
  final int maxItems;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductPage>(
      future: future,
      builder: (context, snapshot) {
        Widget sliver;

        if (snapshot.connectionState != ConnectionState.done) {
          sliver = SliverGrid.builder(
            gridDelegate: productGridDelegate,
            itemCount: 4,
            itemBuilder: (_, _) => const ProductCardSkeleton(),
          );
        } else if (snapshot.hasError) {
          sliver = SliverToBoxAdapter(
            child: StateView(
              isError: true,
              icon: Icons.wifi_off_rounded,
              title: 'Gagal memuat produk',
              message: apiErrorMessage(snapshot.error!),
              actionLabel: 'Coba Lagi',
              onAction: onRetry,
            ),
          );
        } else {
          final products = snapshot.data!.items.take(maxItems).toList();
          sliver = products.isEmpty
              ? const SliverToBoxAdapter(
                  child: StateView(
                    icon: Icons.inventory_2_outlined,
                    title: 'Belum ada produk',
                    message: 'Produk akan tampil di sini setelah ditambahkan.',
                  ),
                )
              : SliverGrid.builder(
                  gridDelegate: productGridDelegate,
                  itemCount: products.length,
                  itemBuilder: (_, index) => ProductCard(product: products[index]),
                );
        }

        return SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16), sliver: sliver);
      },
    );
  }
}
