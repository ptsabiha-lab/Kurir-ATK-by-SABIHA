import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/order_events.dart';
import '../../services/api_client.dart';
import '../../services/order_service.dart';
import '../../theme/app_colors.dart';
import '../orders/order_detail_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSubmitting = true);

    try {
      final order = await OrderService.instance.createOrder(
        shippingAddress: _addressController.text.trim(),
        notes: _notesController.text.trim(),
        items: cart.toOrderItems(),
      );

      if (!mounted) return;

      cart.clear();
      context.read<OrderEvents>().changed();
      // Stok berubah setelah pesanan dibuat.
      context.read<CatalogProvider>().loadProducts(reset: true);

      messenger.showSnackBar(
        SnackBar(content: Text('Pesanan ${order.orderNumber} berhasil dibuat.')),
      );
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Ringkasan Pesanan', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final item in cart.items)
                    ListTile(
                      dense: true,
                      title: Text(item.product.name),
                      subtitle: Text('${item.quantity} x ${formatRupiah(item.product.price)}'),
                      trailing: Text(formatRupiah(item.subtotal)),
                    ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      formatRupiah(cart.totalPrice),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Pengiriman', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Alamat Pengiriman',
                hintText: 'Nama instansi, jalan, nomor, kelurahan, kota',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) => (value == null || value.trim().length < 10)
                  ? 'Alamat pengiriman wajib diisi lengkap'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Mis. antar ke bagian TU, jam kerja 08.00–15.00',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _isSubmitting || cart.isEmpty ? null : _submit,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : Text('Buat Pesanan • ${formatRupiah(cart.totalPrice)}'),
          ),
        ),
      ),
    );
  }
}
