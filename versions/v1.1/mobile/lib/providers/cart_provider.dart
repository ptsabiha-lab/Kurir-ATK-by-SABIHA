import 'package:flutter/foundation.dart';

import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  int get subtotal => product.price * quantity;
}

/// Keranjang belanja (disimpan di memori selama aplikasi terbuka).
class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  bool get isEmpty => _items.isEmpty;

  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => _items.values.fold(0, (sum, item) => sum + item.subtotal);

  int quantityOf(int productId) => _items[productId]?.quantity ?? 0;

  /// Menambah produk ke keranjang, dibatasi sesuai stok.
  /// Mengembalikan jumlah yang benar-benar ditambahkan.
  int add(Product product, {int quantity = 1}) {
    final current = quantityOf(product.id);
    final newQuantity = (current + quantity).clamp(0, product.stock);
    final added = newQuantity - current;

    if (added <= 0) return 0;

    _items[product.id] = CartItem(product: product, quantity: newQuantity);
    notifyListeners();
    return added;
  }

  void updateQuantity(int productId, int quantity) {
    final item = _items[productId];
    if (item == null) return;

    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      item.quantity = quantity.clamp(1, item.product.stock);
    }
    notifyListeners();
  }

  void remove(int productId) {
    if (_items.remove(productId) != null) notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }

  /// Format item untuk body request `POST /orders`.
  List<Map<String, int>> toOrderItems() => _items.values
      .map((item) => {'product_id': item.product.id, 'quantity': item.quantity})
      .toList();
}
