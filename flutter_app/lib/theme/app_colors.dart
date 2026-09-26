import 'package:flutter/material.dart';

/// Palet warna brand Kurir ATK.
///
/// Biru adalah identitas utama; warna lain dipakai hemat hanya untuk
/// status (sukses, bahaya, peringatan) agar tampilan tetap bersih.
class AppColors {
  AppColors._();

  // Biru brand
  static const Color navy = Color(0xFF0A2463);
  static const Color primaryDark = Color(0xFF0B3FB0);
  static const Color primary = Color(0xFF1560E8);
  static const Color sky = Color(0xFF3D8BFF);
  static const Color primarySoft = Color(0xFFE8F0FF);
  static const Color primarySofter = Color(0xFFF3F7FF);

  // Netral
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE3E8F0);
  static const Color textPrimary = Color(0xFF0F1B33);
  static const Color textSecondary = Color(0xFF5B6B84);
  static const Color textMuted = Color(0xFF94A3B8);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFE7F7EE);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFDECEC);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFFF5E0);

  /// Gradien utama brand: header, splash, tombol penting.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, primaryDark, primary, sky],
    stops: [0.0, 0.35, 0.75, 1.0],
  );

  /// Gradien lembut untuk banner & latar gambar produk.
  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primarySoft, primarySofter],
  );
}
