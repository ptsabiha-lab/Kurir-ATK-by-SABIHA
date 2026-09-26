import '../models/order.dart';
import '../models/user.dart';
import 'api_client.dart';

class Paginated<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;

  Paginated({required this.items, required this.currentPage, required this.lastPage});

  bool get hasMore => currentPage < lastPage;

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return Paginated(
      items: (json['data'] as List).map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
    );
  }
}

/// Endpoint pesanan, pengiriman, dan kurir.
class OrderService {
  OrderService._();

  static final OrderService instance = OrderService._();

  final _dio = ApiClient.instance.dio;

  // ---- Pesanan ----

  Future<Paginated<Order>> fetchOrders({int page = 1, String? status}) async {
    final response = await _dio.get('/orders', queryParameters: {
      'page': page,
      'status': ?status,
    });
    return Paginated.fromJson(response.data as Map<String, dynamic>, Order.fromJson);
  }

  Future<Order> fetchOrder(int id) async {
    final response = await _dio.get('/orders/$id');
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Order> createOrder({
    required String shippingAddress,
    required List<Map<String, int>> items,
    String? notes,
  }) async {
    final response = await _dio.post('/orders', data: {
      'shipping_address': shippingAddress,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'items': items,
    });
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> cancelOrder(int id) => _dio.delete('/orders/$id');

  /// Khusus admin.
  Future<Order> updateOrderStatus(int id, String status) async {
    final response = await _dio.put('/orders/$id', data: {'status': status});
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  // ---- Pengiriman ----

  Future<Paginated<Delivery>> fetchDeliveries({int page = 1}) async {
    final response = await _dio.get('/deliveries', queryParameters: {'page': page});
    return Paginated.fromJson(response.data as Map<String, dynamic>, Delivery.fromJson);
  }

  Future<Delivery> fetchDelivery(int id) async {
    final response = await _dio.get('/deliveries/$id');
    return Delivery.fromJson(response.data as Map<String, dynamic>);
  }

  /// Khusus admin: tugaskan kurir untuk sebuah pesanan.
  Future<Delivery> assignCourier({required int orderId, required int kurirId, String? notes}) async {
    final response = await _dio.post('/deliveries', data: {
      'order_id': orderId,
      'kurir_id': kurirId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return Delivery.fromJson(response.data as Map<String, dynamic>);
  }

  /// Admin atau kurir yang ditugaskan.
  Future<Delivery> updateDeliveryStatus(int id, String status, {String? notes}) async {
    final response = await _dio.put('/deliveries/$id', data: {
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return Delivery.fromJson(response.data as Map<String, dynamic>);
  }

  /// Khusus admin.
  Future<List<AppUser>> fetchCouriers() async {
    final response = await _dio.get('/couriers');
    return (response.data as List)
        .map((json) => AppUser.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
