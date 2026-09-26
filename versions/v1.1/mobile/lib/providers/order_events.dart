import 'package:flutter/foundation.dart';

/// Sinyal sederhana agar daftar pesanan/pengiriman memuat ulang datanya
/// setelah ada perubahan (checkout, pembatalan, update status).
class OrderEvents extends ChangeNotifier {
  void changed() => notifyListeners();
}
