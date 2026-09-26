import '../models/user.dart';
import 'api_client.dart';
import 'token_storage.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final _dio = ApiClient.instance.dio;

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    final response = await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });

    final token = response.data['token'] as String;
    await TokenStorage.instance.saveToken(token);

    return AppUser.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<AppUser> login({required String email, required String password}) async {
    final response = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });

    final token = response.data['token'] as String;
    await TokenStorage.instance.saveToken(token);

    return AppUser.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<AppUser?> fetchCurrentUser() async {
    final token = await TokenStorage.instance.readToken();
    if (token == null) return null;

    try {
      final response = await _dio.get('/me');
      return AppUser.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      await TokenStorage.instance.clearToken();
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {
      // Tetap hapus token lokal walau request logout gagal (mis. offline).
    } finally {
      await TokenStorage.instance.clearToken();
    }
  }
}
