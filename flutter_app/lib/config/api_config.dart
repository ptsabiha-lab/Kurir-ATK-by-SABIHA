/// Konfigurasi alamat API backend Laravel.
///
/// Ganti [baseUrl] sesuai environment:
/// - Android emulator  -> http://10.0.2.2:8000/api
/// - iOS simulator     -> http://127.0.0.1:8000/api
/// - Web (Chrome)      -> http://127.0.0.1:8000/api
/// - HP fisik / server production -> ganti dengan domain/IP publik backend.
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );
}
