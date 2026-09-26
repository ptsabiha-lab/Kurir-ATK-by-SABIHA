import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';

/// Dialog untuk mengganti alamat server backend tanpa build ulang APK.
/// Berguna saat aplikasi di-install di HP fisik yang terhubung ke Wi-Fi
/// yang sama dengan komputer tempat Laravel berjalan.
Future<void> showServerSettingsDialog(BuildContext context) {
  return showDialog(context: context, builder: (_) => const _ServerSettingsDialog());
}

class _ServerSettingsDialog extends StatefulWidget {
  const _ServerSettingsDialog();

  @override
  State<_ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<_ServerSettingsDialog> {
  late final _controller = TextEditingController(text: ApiConfig.baseUrl);
  bool _isTesting = false;
  String? _result;
  bool _success = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final url = ApiConfig.normalize(_controller.text);
    if (url.isEmpty) return;

    setState(() {
      _isTesting = true;
      _result = null;
    });

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {'Accept': 'application/json'},
      ));
      final response = await dio.get('$url/categories');
      final count = (response.data as List).length;
      _success = true;
      _result = 'Terhubung! ($count kategori ditemukan)';
    } catch (_) {
      _success = false;
      _result = 'Gagal terhubung. Pastikan HP & komputer satu Wi-Fi dan '
          'backend dijalankan dengan: php artisan serve --host=0.0.0.0';
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  Future<void> _save() async {
    final url = ApiConfig.normalize(_controller.text);
    if (url.isEmpty) return;
    await ApiConfig.save(url);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _reset() async {
    await ApiConfig.reset();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alamat Server'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Isi dengan IP komputer yang menjalankan backend, contoh:\n192.168.1.10:8000',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'URL API',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() => _result = null),
            ),
            const SizedBox(height: 4),
            Text(
              'Default: ${ApiConfig.defaultUrl}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isTesting ? null : _testConnection,
              icon: _isTesting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.wifi_find),
              label: const Text('Tes Koneksi'),
            ),
            if (_result != null) ...[
              const SizedBox(height: 8),
              Text(
                _result!,
                style: TextStyle(fontSize: 13, color: _success ? Colors.green : Colors.red),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (ApiConfig.isCustom) TextButton(onPressed: _reset, child: const Text('Reset')),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }
}
