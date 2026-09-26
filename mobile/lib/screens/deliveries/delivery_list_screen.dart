import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../providers/order_events.dart';
import '../../services/order_service.dart';
import '../../widgets/paginated_list.dart';
import '../../widgets/status_chip.dart';
import 'delivery_detail_screen.dart';

/// Daftar tugas pengiriman milik kurir yang sedang login.
class DeliveryListScreen extends StatelessWidget {
  const DeliveryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tugas Pengiriman')),
      body: PaginatedList<Delivery>(
        refreshListenable: context.read<OrderEvents>(),
        loader: (page) => OrderService.instance.fetchDeliveries(page: page),
        emptyIcon: Icons.delivery_dining_outlined,
        emptyMessage: 'Belum ada tugas pengiriman.\nTarik ke bawah untuk memuat ulang.',
        itemBuilder: (context, delivery) => _DeliveryCard(delivery: delivery),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.delivery});

  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final order = delivery.order;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DeliveryDetailScreen(deliveryId: delivery.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(delivery.trackingNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  StatusChip.delivery(delivery.status),
                ],
              ),
              if (order != null) ...[
                const SizedBox(height: 4),
                Text('Pesanan ${order.orderNumber} • ${order.totalQuantity} item',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const Divider(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(order.shippingAddress, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Text('Ditugaskan ${formatDateTime(delivery.createdAt)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
