import 'product.dart';
import 'user.dart';

/// Laravel bisa mengirim angka sebagai int atau string tergantung driver database.
int parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime? parseDate(dynamic value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

/// Format tanggal, mis. "26/09/2026 14:05".
String formatDateTime(DateTime? date) {
  if (date == null) return '-';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
}

class OrderStatus {
  static const all = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];

  static const _labels = {
    'pending': 'Menunggu Konfirmasi',
    'confirmed': 'Dikonfirmasi',
    'processing': 'Diproses',
    'shipped': 'Dikirim',
    'delivered': 'Diterima',
    'cancelled': 'Dibatalkan',
  };

  static String label(String status) => _labels[status] ?? status;
}

class DeliveryStatus {
  static const all = ['assigned', 'picked_up', 'in_transit', 'delivered', 'failed'];

  static const _labels = {
    'assigned': 'Ditugaskan',
    'picked_up': 'Diambil Kurir',
    'in_transit': 'Dalam Perjalanan',
    'delivered': 'Terkirim',
    'failed': 'Gagal',
  };

  static String label(String status) => _labels[status] ?? status;

  /// Status berikutnya yang boleh dipilih kurir dari status saat ini.
  static List<String> nextOptions(String status) {
    switch (status) {
      case 'assigned':
        return ['picked_up', 'failed'];
      case 'picked_up':
        return ['in_transit', 'failed'];
      case 'in_transit':
        return ['delivered', 'failed'];
      default:
        return [];
    }
  }
}

class OrderItem {
  final int id;
  final int productId;
  final int quantity;
  final int price;
  final int subtotal;
  final Product? product;

  OrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: parseInt(json['id']),
      productId: parseInt(json['product_id']),
      quantity: parseInt(json['quantity']),
      price: parseInt(json['price']),
      subtotal: parseInt(json['subtotal']),
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  String get productName => product?.name ?? 'Produk #$productId';
}

class Delivery {
  final int id;
  final int orderId;
  final int? kurirId;
  final String status;
  final String trackingNumber;
  final String? notes;
  final DateTime? deliveredAt;
  final DateTime? createdAt;
  final AppUser? kurir;
  final Order? order;

  Delivery({
    required this.id,
    required this.orderId,
    required this.status,
    required this.trackingNumber,
    this.kurirId,
    this.notes,
    this.deliveredAt,
    this.createdAt,
    this.kurir,
    this.order,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: parseInt(json['id']),
      orderId: parseInt(json['order_id']),
      kurirId: json['kurir_id'] != null ? parseInt(json['kurir_id']) : null,
      status: json['status'] as String? ?? 'assigned',
      trackingNumber: json['tracking_number'] as String? ?? '-',
      notes: json['notes'] as String?,
      deliveredAt: parseDate(json['delivered_at']),
      createdAt: parseDate(json['created_at']),
      kurir: json['kurir'] != null
          ? AppUser.fromJson(json['kurir'] as Map<String, dynamic>)
          : null,
      order: json['order'] != null
          ? Order.fromJson(json['order'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isFinished => status == 'delivered' || status == 'failed';
}

class Order {
  final int id;
  final String orderNumber;
  final int userId;
  final String status;
  final int totalPrice;
  final String shippingAddress;
  final String? notes;
  final DateTime? createdAt;
  final List<OrderItem> items;
  final AppUser? user;
  final Delivery? delivery;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.status,
    required this.totalPrice,
    required this.shippingAddress,
    required this.items,
    this.notes,
    this.createdAt,
    this.user,
    this.delivery,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: parseInt(json['id']),
      orderNumber: json['order_number'] as String? ?? '-',
      userId: parseInt(json['user_id']),
      status: json['status'] as String? ?? 'pending',
      totalPrice: parseInt(json['total_price']),
      shippingAddress: json['shipping_address'] as String? ?? '-',
      notes: json['notes'] as String?,
      createdAt: parseDate(json['created_at']),
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      user: json['user'] != null
          ? AppUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      delivery: json['delivery'] != null
          ? Delivery.fromJson(json['delivery'] as Map<String, dynamic>)
          : null,
    );
  }

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  bool get canBeCancelledByCustomer => status == 'pending';
}
