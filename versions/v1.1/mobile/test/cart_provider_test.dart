import 'package:flutter_test/flutter_test.dart';
import 'package:kurir_atk/models/product.dart';
import 'package:kurir_atk/providers/cart_provider.dart';

Product _product({int id = 1, int price = 5000, int stock = 10}) => Product(
      id: id,
      categoryId: 1,
      name: 'Pulpen $id',
      sku: 'SKU-$id',
      price: price,
      stock: stock,
      unit: 'pcs',
      isActive: true,
    );

void main() {
  group('CartProvider', () {
    test('menambah produk dan menghitung total', () {
      final cart = CartProvider();
      cart.add(_product(id: 1, price: 5000), quantity: 2);
      cart.add(_product(id: 2, price: 12000));

      expect(cart.totalQuantity, 3);
      expect(cart.totalPrice, 22000);
      expect(cart.toOrderItems(), [
        {'product_id': 1, 'quantity': 2},
        {'product_id': 2, 'quantity': 1},
      ]);
    });

    test('jumlah tidak bisa melebihi stok', () {
      final cart = CartProvider();
      final product = _product(stock: 3);

      expect(cart.add(product, quantity: 2), 2);
      expect(cart.add(product, quantity: 5), 1);
      expect(cart.add(product), 0);
      expect(cart.quantityOf(product.id), 3);

      cart.updateQuantity(product.id, 99);
      expect(cart.quantityOf(product.id), 3);
    });

    test('jumlah 0 menghapus produk dari keranjang', () {
      final cart = CartProvider();
      cart.add(_product());
      cart.updateQuantity(1, 0);

      expect(cart.isEmpty, isTrue);
    });
  });
}
