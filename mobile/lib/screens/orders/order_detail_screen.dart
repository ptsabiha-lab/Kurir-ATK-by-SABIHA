import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../models/product.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/order_events.dart';
import '../../services/api_client.dart';
import '../../services/order_service.dart';
import '../../widgets/info_section.dart';
import '../../widgets/status_chip.dart';
import '../../theme/app_colors.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<Order> _orderFuture;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _orderFuture = OrderService.instance.fetchOrder(widget.orderId);
  }

  void _reload() {
    setState(() => _orderFuture = OrderService.instance.fetchOrder(widget.orderId));
  }

  /// Menjalankan aksi ke server, lalu memuat ulang detail & daftar pesanan.
  Future<void> _runAction(Future<void> Function() action, String successMessage) async {
    final messenger = ScaffoldMessenger.of(context);
    final events = context.read<OrderEvents>();

    setState(() => _isBusy = true);
    try {
      await action();
      events.changed();
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
      _reload();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _cancelOrder(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan pesanan?'),
        content: Text('Pesanan ${order.orderNumber} akan dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final catalog = context.read<CatalogProvider>();
    await _runAction(() async {
      await OrderService.instance.cancelOrder(order.id);
      // Stok dikembalikan oleh server.
      catalog.loadProducts(reset: true);
    }, 'Pesanan berhasil dibatalkan.');
  }

  Future<void> _changeStatus(Order order) async {
    final status = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('Ubah status pesanan', style: TextStyle(fontWeight: FontWeight.bold))),
            for (final status in OrderStatus.all)
              ListTile(
                leading: Icon(
                  status == order.status ? Icons.radio_button_checked : Icons.radio_button_off,
                ),
                title: Text(OrderStatus.label(status)),
                enabled: status != order.status,
                onTap: () => Navigator.pop(context, status),
              ),
          ],
        ),
      ),
    );

    if (status == null || !mounted) return;

    await _runAction(
      () => OrderService.instance.updateOrderStatus(order.id, status),
      'Status diubah menjadi "${OrderStatus.label(status)}".',
    );
  }

  Future<void> _assignCourier(Order order) async {
    final messenger = ScaffoldMessenger.of(context);

    List<AppUser> couriers;
    try {
      couriers = await OrderService.instance.fetchCouriers();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
      return;
    }

    if (!mounted) return;

    if (couriers.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Belum ada akun kurir terdaftar.')));
      return;
    }

    final kurir = await showModalBottomSheet<AppUser>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Pilih kurir', style: TextStyle(fontWeight: FontWeight.bold))),
            for (final courier in couriers)
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.delivery_dining)),
                title: Text(courier.name),
                subtitle: Text(courier.phone ?? courier.email),
                onTap: () => Navigator.pop(context, courier),
              ),
          ],
        ),
      ),
    );

    if (kurir == null || !mounted) return;

    await _runAction(
      () => OrderService.instance.assignCourier(orderId: order.id, kurirId: kurir.id),
      'Pengiriman ditugaskan ke ${kurir.name}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: FutureBuilder<Order>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(apiErrorMessage(snapshot.error!), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _reload, child: const Text('Coba Lagi')),
                ],
              ),
            );
          }

          final order = snapshot.data!;
          final isOwner = order.userId == user?.id;

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _OrderHeader(order: order),
                const SizedBox(height: 16),
                InfoSection(
                  title: 'Pengiriman',
                  children: [
                    InfoRow(icon: Icons.location_on_outlined, text: order.shippingAddress),
                    if (order.notes != null)
                      InfoRow(icon: Icons.notes_outlined, text: order.notes!),
                    if (order.delivery != null) ...[
                      const Divider(),
                      _DeliveryInfo(delivery: order.delivery!),
                    ] else if (order.status != 'cancelled')
                      const InfoRow(
                        icon: Icons.hourglass_empty,
                        text: 'Kurir belum ditugaskan.',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                InfoSection(
                  title: 'Produk',
                  children: [
                    for (final item in order.items)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(item.productName),
                        subtitle: Text('${item.quantity} x ${formatRupiah(item.price)}'),
                        trailing: Text(formatRupiah(item.subtotal)),
                      ),
                    const Divider(),
                    Row(
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(
                          formatRupiah(order.totalPrice),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isAdmin && order.user != null) ...[
                  const SizedBox(height: 16),
                  InfoSection(
                    title: 'Pemesan',
                    children: [
                      InfoRow(icon: Icons.person_outline, text: order.user!.name),
                      InfoRow(icon: Icons.email_outlined, text: order.user!.email),
                      if (order.user!.phone != null)
                        InfoRow(icon: Icons.phone_outlined, text: order.user!.phone!),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                ..._buildActions(order, isAdmin: isAdmin, isOwner: isOwner),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildActions(Order order, {required bool isAdmin, required bool isOwner}) {
    if (_isBusy) {
      return const [Center(child: CircularProgressIndicator())];
    }

    final actions = <Widget>[];

    if (isAdmin && order.status != 'cancelled') {
      actions.add(OutlinedButton.icon(
        onPressed: () => _changeStatus(order),
        icon: const Icon(Icons.edit_note),
        label: const Text('Ubah Status Pesanan'),
      ));

      if (order.delivery == null) {
        actions.add(FilledButton.icon(
          onPressed: () => _assignCourier(order),
          icon: const Icon(Icons.delivery_dining),
          label: const Text('Tugaskan Kurir'),
        ));
      }
    }

    if (isOwner && order.canBeCancelledByCustomer) {
      actions.add(OutlinedButton.icon(
        onPressed: () => _cancelOrder(order),
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Batalkan Pesanan'),
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
      ));
    }

    return [
      for (final action in actions) ...[action, const SizedBox(height: 8)],
    ];
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                StatusChip.order(order.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Dipesan ${formatDateTime(order.createdAt)}', style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _DeliveryInfo extends StatelessWidget {
  const _DeliveryInfo({required this.delivery});

  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_shipping_outlined, size: 20, color: AppColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(delivery.trackingNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            StatusChip.delivery(delivery.status),
          ],
        ),
        if (delivery.kurir != null)
          InfoRow(icon: Icons.delivery_dining, text: 'Kurir: ${delivery.kurir!.name}'),
        if (delivery.deliveredAt != null)
          InfoRow(icon: Icons.check_circle_outline, text: 'Diterima ${formatDateTime(delivery.deliveredAt)}'),
        if (delivery.notes != null)
          InfoRow(icon: Icons.sticky_note_2_outlined, text: delivery.notes!),
      ],
    );
  }
}
