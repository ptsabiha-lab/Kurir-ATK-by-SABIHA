import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'token_storage.dart';

/// Klien HTTP tunggal untuk seluruh aplikasi, otomatis menyisipkan
/// token Bearer dari secure storage ke setiap request.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Alamat server bisa diganti pengguna saat aplikasi berjalan.
          options.baseUrl = ApiConfig.baseUrl;
          final token = await TokenStorage.instance.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await TokenStorage.instance.clearToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio _dio;

  Dio get dio => _dio;
}

/// Mengubah error Dio menjadi pesan yang ramah ditampilkan ke pengguna.
String apiErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    }
  }
  return 'Terjadi kesalahan. Silakan coba lagi.';
}
