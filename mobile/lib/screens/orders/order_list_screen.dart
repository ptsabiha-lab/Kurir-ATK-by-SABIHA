import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_events.dart';
import '../../services/order_service.dart';
import '../../widgets/paginated_list.dart';
import '../../widgets/status_chip.dart';
import 'order_detail_screen.dart';
import '../../theme/app_colors.dart';

/// Pelanggan melihat pesanannya sendiri; admin melihat semua pesanan
/// dan bisa memfilter berdasarkan status.
class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(isAdmin ? 'Kelola Pesanan' : 'Pesanan Saya')),
      body: Column(
        children: [
          if (isAdmin)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                children: [
                  for (final status in [null, ...OrderStatus.all])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status == null ? 'Semua' : OrderStatus.label(status)),
                        selected: _statusFilter == status,
                        onSelected: (_) => setState(() => _statusFilter = status),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: PaginatedList<Order>(
              // Key berubah saat filter berubah agar daftar dimuat ulang dari halaman 1.
              key: ValueKey(_statusFilter),
              refreshListenable: context.read<OrderEvents>(),
              loader: (page) => OrderService.instance.fetchOrders(page: page, status: _statusFilter),
              emptyIcon: Icons.receipt_long_outlined,
              emptyMessage: isAdmin ? 'Belum ada pesanan.' : 'Anda belum memiliki pesanan.',
              itemBuilder: (context, order) => OrderCard(order: order, showCustomer: isAdmin),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, this.showCustomer = false});

  final Order order;
  final bool showCustomer;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  StatusChip.order(order.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(formatDateTime(order.createdAt), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              if (showCustomer && order.user != null) ...[
                const SizedBox(height: 4),
                Text('Pemesan: ${order.user!.name}', style: const TextStyle(fontSize: 13)),
              ],
              const Divider(height: 20),
              Text(
                order.items.map((item) => '${item.quantity}x ${item.productName}').join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('${order.totalQuantity} item', style: const TextStyle(color: AppColors.textSecondary)),
                  const Spacer(),
                  Text(
                    formatRupiah(order.totalPrice),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
