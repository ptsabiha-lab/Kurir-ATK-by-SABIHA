import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus status = AuthStatus.unknown;
  AppUser? user;
  String? errorMessage;
  bool isLoading = false;

  final _authService = AuthService.instance;

  Future<void> checkAuthStatus() async {
    final currentUser = await _authService.fetchCurrentUser();
    user = currentUser;
    status = currentUser != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    return _runAuthAction(() => _authService.login(email: email, password: password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    return _runAuthAction(() => _authService.register(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
          phone: phone,
        ));
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    await _authService.logout();

    user = null;
    status = AuthStatus.unauthenticated;
    isLoading = false;
    notifyListeners();
  }

  Future<bool> _runAuthAction(Future<AppUser> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await action();
      user = result;
      status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      errorMessage = apiErrorMessage(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
