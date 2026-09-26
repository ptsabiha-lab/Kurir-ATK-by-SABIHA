import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../providers/order_events.dart';
import '../../services/api_client.dart';
import '../../services/order_service.dart';
import '../../widgets/info_section.dart';
import '../../widgets/status_chip.dart';
import '../../theme/app_colors.dart';

class DeliveryDetailScreen extends StatefulWidget {
  const DeliveryDetailScreen({super.key, required this.deliveryId});

  final int deliveryId;

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  late Future<Delivery> _deliveryFuture;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _deliveryFuture = OrderService.instance.fetchDelivery(widget.deliveryId);
  }

  void _reload() {
    setState(() => _deliveryFuture = OrderService.instance.fetchDelivery(widget.deliveryId));
  }

  Future<void> _updateStatus(Delivery delivery, String status) async {
    String? notes;

    // Pengiriman gagal wajib diberi alasan agar admin bisa menindaklanjuti.
    if (status == 'failed') {
      notes = await _askFailureReason();
      if (notes == null) return;
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ubah status pengiriman?'),
          content: Text('Status akan diubah menjadi "${DeliveryStatus.label(status)}".'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya')),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final events = context.read<OrderEvents>();

    setState(() => _isUpdating = true);
    try {
      await OrderService.instance.updateDeliveryStatus(delivery.id, status, notes: notes);
      events.changed();
      messenger.showSnackBar(
        SnackBar(content: Text('Status diubah menjadi "${DeliveryStatus.label(status)}".')),
      );
      _reload();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<String?> _askFailureReason() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengiriman gagal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Alasan',
            hintText: 'Mis. penerima tidak ada di tempat',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isNotEmpty) Navigator.pop(context, reason);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengiriman')),
      body: FutureBuilder<Delivery>(
        future: _deliveryFuture,
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

          final delivery = snapshot.data!;
          final order = delivery.order;

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                InfoSection(
                  title: 'Status',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(delivery.trackingNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        StatusChip.delivery(delivery.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _StatusTimeline(current: delivery.status),
                    if (delivery.notes != null)
                      InfoRow(icon: Icons.sticky_note_2_outlined, text: delivery.notes!),
                  ],
                ),
                if (order != null) ...[
                  const SizedBox(height: 16),
                  InfoSection(
                    title: 'Tujuan',
                    children: [
                      InfoRow(icon: Icons.location_on_outlined, text: order.shippingAddress),
                      if (order.notes != null) InfoRow(icon: Icons.notes_outlined, text: order.notes!),
                      InfoRow(icon: Icons.receipt_long_outlined, text: 'Pesanan ${order.orderNumber}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InfoSection(
                    title: 'Barang yang dibawa',
                    children: [
                      for (final item in order.items)
                        InfoRow(
                          icon: Icons.inventory_2_outlined,
                          text: '${item.quantity} ${item.product?.unit ?? 'pcs'} — ${item.productName}',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<Delivery>(
        future: _deliveryFuture,
        builder: (context, snapshot) {
          final delivery = snapshot.data;
          if (delivery == null) return const SizedBox.shrink();

          final options = DeliveryStatus.nextOptions(delivery.status);
          if (options.isEmpty) return const SizedBox.shrink();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _isUpdating
                  ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
                  : Row(
                      children: [
                        for (final status in options) ...[
                          Expanded(
                            flex: status == 'failed' ? 1 : 2,
                            child: status == 'failed'
                                ? OutlinedButton(
                                    onPressed: () => _updateStatus(delivery, status),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.danger,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: const Text('Gagal'),
                                  )
                                : FilledButton(
                                    onPressed: () => _updateStatus(delivery, status),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: Text(_actionLabel(status)),
                                  ),
                          ),
                          if (status != options.last) const SizedBox(width: 12),
                        ],
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  String _actionLabel(String status) => switch (status) {
        'picked_up' => 'Barang Sudah Diambil',
        'in_transit' => 'Mulai Antar',
        'delivered' => 'Sudah Diterima',
        _ => DeliveryStatus.label(status),
      };
}

/// Tahapan pengiriman: Ditugaskan → Diambil → Dalam Perjalanan → Terkirim.
class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.current});

  final String current;

  static const _steps = ['assigned', 'picked_up', 'in_transit', 'delivered'];

  @override
  Widget build(BuildContext context) {
    if (current == 'failed') {
      return const InfoRow(icon: Icons.error_outline, text: 'Pengiriman ditandai gagal.');
    }

    final currentIndex = _steps.indexOf(current);
    final color = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          Row(
            children: [
              Icon(
                i <= currentIndex ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20,
                color: i <= currentIndex ? color : AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  DeliveryStatus.label(_steps[i]),
                  style: TextStyle(
                    fontWeight: i == currentIndex ? FontWeight.bold : FontWeight.normal,
                    color: i <= currentIndex ? null : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
