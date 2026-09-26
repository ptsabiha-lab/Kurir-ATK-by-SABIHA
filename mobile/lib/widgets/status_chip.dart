import 'package:flutter/material.dart';

import '../models/order.dart';

/// Label status berwarna untuk pesanan maupun pengiriman.
class StatusChip extends StatelessWidget {
  const StatusChip._({required this.label, required this.color});

  factory StatusChip.order(String status) =>
      StatusChip._(label: OrderStatus.label(status), color: _orderColor(status));

  factory StatusChip.delivery(String status) =>
      StatusChip._(label: DeliveryStatus.label(status), color: _deliveryColor(status));

  final String label;
  final Color color;

  static Color _orderColor(String status) => switch (status) {
        'pending' => Colors.orange,
        'confirmed' => Colors.blue,
        'processing' => Colors.indigo,
        'shipped' => Colors.purple,
        'delivered' => Colors.green,
        'cancelled' => Colors.red,
        _ => Colors.grey,
      };

  static Color _deliveryColor(String status) => switch (status) {
        'assigned' => Colors.orange,
        'picked_up' => Colors.blue,
        'in_transit' => Colors.purple,
        'delivered' => Colors.green,
        'failed' => Colors.red,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
