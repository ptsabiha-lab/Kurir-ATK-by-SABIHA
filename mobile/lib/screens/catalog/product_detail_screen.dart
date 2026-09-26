import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_client.dart';
import '../../services/catalog_service.dart';
import '../cart/cart_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(apiErrorMessage(snapshot.error!), textAlign: TextAlign.center),
              ),
            );
          }

          final product = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 72,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.category != null)
                        Chip(
                          label: Text(product.category!.name),
                          visualDensity: VisualDensity.compact,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatRupiah(product.price),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'per ${product.unit} • SKU: ${product.sku}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            product.inStock ? Icons.check_circle : Icons.cancel,
                            size: 18,
                            color: product.inStock ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            product.inStock
                                ? 'Stok tersedia: ${product.stock} ${product.unit}'
                                : 'Stok habis',
                          ),
                        ],
                      ),
                      if (product.description != null) ...[
                        const SizedBox(height: 20),
                        const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(product.description!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          final product = snapshot.data;
          // Hanya pelanggan yang memesan; admin & kurir cukup melihat katalog.
          final user = context.watch<AuthProvider>().user;
          final canOrder = !(user?.isAdmin ?? false) && !(user?.isKurir ?? false);
          if (product == null || !canOrder) return const SizedBox.shrink();

          final inCart = context.watch<CartProvider>().quantityOf(product.id);
          final available = product.stock - inCart;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (inCart > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('Sudah ada $inCart ${product.unit} di keranjang',
                          style: const TextStyle(color: Colors.grey)),
                    ),
                  Row(
                    children: [
                      QuantityStepper(
                        value: available > 0 ? _quantity.clamp(1, available) : 0,
                        min: available > 0 ? 1 : 0,
                        max: available,
                        onChanged: (value) => setState(() => _quantity = value),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: available > 0 ? () => _addToCart(product, available) : null,
                          icon: const Icon(Icons.add_shopping_cart),
                          label: Text(product.inStock ? 'Tambah ke Keranjang' : 'Stok Habis'),
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _addToCart(Product product, int available) {
    final added = context.read<CartProvider>().add(product, quantity: _quantity.clamp(1, available));
    setState(() => _quantity = 1);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('$added ${product.unit} ${product.name} ditambahkan ke keranjang.'),
        action: SnackBarAction(
          label: 'LIHAT',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
        ),
      ));
  }
}
