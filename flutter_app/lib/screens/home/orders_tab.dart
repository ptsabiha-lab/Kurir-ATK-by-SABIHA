import 'package:flutter/material.dart';

import '../../widgets/state_view.dart';

/// Tab riwayat pesanan. Backend pemesanan belum tersedia, jadi untuk
/// sementara menampilkan keadaan kosong yang mengarahkan ke katalog.
class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key, required this.onBrowseCatalog});

  final VoidCallback onBrowseCatalog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: StateView(
        icon: Icons.receipt_long_rounded,
        title: 'Belum ada pesanan',
        message: 'Fitur pemesanan sedang kami siapkan. '
            'Sementara itu, lihat dulu produk ATK yang tersedia.',
        actionLabel: 'Jelajahi Katalog',
        onAction: onBrowseCatalog,
      ),
    );
  }
}
