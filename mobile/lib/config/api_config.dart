import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Alamat API backend Laravel.
///
/// Urutan prioritas:
/// 1. Alamat yang diatur pengguna di aplikasi (ikon ⚙ di halaman login) —
///    dipakai untuk HP fisik, mis. http://192.168.1.10:8000/api
/// 2. `--dart-define=API_BASE_URL=...` saat build
/// 3. Default: Android emulator -> http://10.0.2.2:8000/api,
///    platform lain -> http://127.0.0.1:8000/api
class ApiConfig {
  static const String _buildOverride = String.fromEnvironment('API_BASE_URL');
  static const _storageKey = 'api_base_url';
  static const _storage = FlutterSecureStorage();

  static String? _savedUrl;

  static String get defaultUrl {
    if (_buildOverride.isNotEmpty) return _buildOverride;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  static String get baseUrl => _savedUrl ?? defaultUrl;

  static bool get isCustom => _savedUrl != null;

  /// Dipanggil sekali saat aplikasi mulai.
  static Future<void> load() async {
    try {
      // Batas waktu agar aplikasi tidak tertahan di splash jika storage bermasalah.
      _savedUrl = await _storage.read(key: _storageKey).timeout(const Duration(seconds: 3));
    } catch (_) {
      _savedUrl = null;
    }
  }

  static Future<void> save(String url) async {
    _savedUrl = url;
    await _storage.write(key: _storageKey, value: url);
  }

  static Future<void> reset() async {
    _savedUrl = null;
    await _storage.delete(key: _storageKey);
  }

  /// Melengkapi input pengguna, mis. "192.168.1.10:8000" -> "http://192.168.1.10:8000/api".
  static String normalize(String input) {
    var url = input.trim();
    if (url.isEmpty) return url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (!url.endsWith('/api')) url = '$url/api';
    return url;
  }
}
