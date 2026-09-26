import 'package:flutter_test/flutter_test.dart';
import 'package:kurir_atk/models/order.dart';
import 'package:kurir_atk/models/product.dart';

void main() {
  test('Order.fromJson membaca respons API Laravel', () {
    final order = Order.fromJson({
      'id': 7,
      'order_number': 'ATK-20260926-ABC123',
      'user_id': 3,
      'status': 'processing',
      'total_price': '165000', // MySQL kadang mengirim angka sebagai string
      'shipping_address': 'Jl. Merdeka No. 1',
      'notes': null,
      'created_at': '2026-09-26T07:00:00.000000Z',
      'items': [
        {'id': 1, 'product_id': 2, 'quantity': 3, 'price': 55000, 'subtotal': 165000},
      ],
      'delivery': {
        'id': 4,
        'order_id': 7,
        'kurir_id': 2,
        'status': 'in_transit',
        'tracking_number': 'TRK-20260926-XYZ',
        'kurir': {'id': 2, 'name': 'Kurir Satu', 'email': 'kurir@kuriratk.test', 'role': 'kurir'},
      },
    });

    expect(order.totalPrice, 165000);
    expect(order.totalQuantity, 3);
    expect(order.items.single.productName, 'Produk #2');
    expect(order.delivery!.kurir!.isKurir, isTrue);
    expect(order.canBeCancelledByCustomer, isFalse);
  });

  test('status kurir hanya bisa maju ke tahap berikutnya', () {
    expect(DeliveryStatus.nextOptions('assigned'), ['picked_up', 'failed']);
    expect(DeliveryStatus.nextOptions('in_transit'), ['delivered', 'failed']);
    expect(DeliveryStatus.nextOptions('delivered'), isEmpty);
  });

  test('formatRupiah memberi pemisah ribuan', () {
    expect(formatRupiah(165000), 'Rp165.000');
    expect(formatRupiah(1250000), 'Rp1.250.000');
  });
}
