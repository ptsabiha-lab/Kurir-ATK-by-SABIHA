import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_logo.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

/// Ditampilkan saat aplikasi baru dibuka, sambil mengecek apakah
/// ada token tersimpan yang masih valid.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => authProvider.status == AuthStatus.authenticated
            ? const HomeScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: const SafeArea(
            child: Column(
              children: [
                Spacer(flex: 3),
                BrandMark(size: 92, onDark: true),
                SizedBox(height: 24),
                BrandWordmark(fontSize: 34, onDark: true),
                SizedBox(height: 10),
                Text(
                  'Belanja ATK, diantar sampai tujuan',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                Spacer(flex: 3),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                ),
                SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
