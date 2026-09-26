import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Ikon & warna aksen untuk setiap kategori, berdasarkan slug-nya.
/// Kategori baru yang belum dipetakan otomatis memakai gaya default.
class CategoryStyle {
  const CategoryStyle(this.icon, this.color);

  final IconData icon;
  final Color color;

  Color get softColor => color.withValues(alpha: 0.1);

  static const CategoryStyle all = CategoryStyle(Icons.grid_view_rounded, AppColors.primary);

  static const Map<String, CategoryStyle> _bySlug = {
    'alat-tulis': CategoryStyle(Icons.edit_rounded, Color(0xFF1560E8)),
    'kertas': CategoryStyle(Icons.description_rounded, Color(0xFF0891B2)),
    'peralatan-kantor': CategoryStyle(Icons.work_rounded, Color(0xFF4F46E5)),
  };

  static CategoryStyle of(String? slug) =>
      _bySlug[slug] ?? const CategoryStyle(Icons.inventory_2_rounded, AppColors.primary);
}
