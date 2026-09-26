import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/api_client.dart';
import '../../services/catalog_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_style.dart';
import '../../widgets/product_image.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_view.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> _productFuture;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _productFuture = CatalogService.instance.fetchProduct(widget.productId);
  }

  void _retry() {
    setState(() {
      _productFuture = CatalogService.instance.fetchProduct(widget.productId);
    });
  }

  void _addToCart(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$_quantity ${product.unit} ${product.name} siap dipesan. '
          'Fitur keranjang segera hadir.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _DetailSkeleton();
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Produk')),
            body: StateView(
              isError: true,
              icon: Icons.wifi_off_rounded,
              title: 'Gagal memuat produk',
              message: apiErrorMessage(snapshot.error!),
              actionLabel: 'Coba Lagi',
              onAction: _retry,
            ),
          );
        }

        final product = snapshot.data!;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 320,
                backgroundColor: AppColors.surface,
                leading: const _CircleBackButton(),
                title: const Text('Detail Produk'),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: ProductImage(product: product, iconSize: 84),
                ),
              ),
              SliverToBoxAdapter(child: _SummarySection(product: product)),
              SliverToBoxAdapter(child: _InfoSection(product: product)),
              if (product.description != null && product.description!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _Section(
                    title: 'Deskripsi Produk',
                    child: Text(
                      product.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.5),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: _DeliverySection()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
          bottomNavigationBar: _BottomActionBar(
            product: product,
            quantity: _quantity,
            onQuantityChanged: (value) => setState(() => _quantity = value),
            onAddToCart: () => _addToCart(product),
          ),
        );
      },
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).maybePop(),
          child: const Tooltip(
            message: 'Kembali',
            child: Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Blok putih dengan judul, dipisah jarak abu-abu antar blok.
class _Section extends StatelessWidget {
  const _Section({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatRupiah(product.price),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'per ${product.unit}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20, height: 1.3),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (product.category != null)
                _Pill(
                  icon: CategoryStyle.of(product.category!.slug).icon,
                  label: product.category!.name,
                  color: AppColors.primary,
                  background: AppColors.primarySoft,
                ),
              product.inStock
                  ? _Pill(
                      icon: Icons.check_circle_rounded,
                      label: 'Stok tersedia',
                      color: AppColors.success,
                      background: AppColors.successSoft,
                    )
                  : const _Pill(
                      icon: Icons.cancel_rounded,
                      label: 'Stok habis',
                      color: AppColors.danger,
                      background: AppColors.dangerSoft,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Kategori', product.category?.name ?? '-'),
      ('SKU', product.sku),
      ('Satuan', product.unit),
      ('Stok', product.inStock ? '${product.stock} ${product.unit}' : 'Habis'),
    ];

    return _Section(
      title: 'Informasi Produk',
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    rows[i].$1,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
                Expanded(
                  child: Text(
                    rows[i].$2,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliverySection extends StatelessWidget {
  const _DeliverySection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Pengiriman',
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm + 2),
            ),
            child: const Icon(Icons.local_shipping_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diantar oleh Kurir ATK',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                SizedBox(height: 2),
                Text(
                  'Pesanan diantar langsung ke alamat kantor atau sekolah Anda.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              if (product.inStock) ...[
                _QuantityStepper(
                  value: quantity,
                  max: product.stock,
                  onChanged: onQuantityChanged,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton.icon(
                  onPressed: product.inStock ? onAddToCart : null,
                  icon: Icon(
                    product.inStock ? Icons.add_shopping_cart_rounded : Icons.block_rounded,
                    size: 20,
                  ),
                  label: Text(
                    product.inStock
                        ? 'Tambah • ${formatRupiah(product.price * quantity)}'
                        : 'Stok Habis',
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

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.value, required this.max, required this.onChanged});

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded, size: 20),
            color: AppColors.primary,
            tooltip: 'Kurangi',
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded, size: 20),
            color: AppColors.primary,
            tooltip: 'Tambah',
          ),
        ],
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          SkeletonBox(height: 280, radius: 0),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 140, height: 26),
                SizedBox(height: 16),
                SkeletonBox(height: 18),
                SizedBox(height: 8),
                SkeletonBox(width: 200, height: 18),
                SizedBox(height: 20),
                Row(
                  children: [
                    SkeletonBox(width: 100, height: 28, radius: 20),
                    SizedBox(width: 8),
                    SkeletonBox(width: 110, height: 28, radius: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
