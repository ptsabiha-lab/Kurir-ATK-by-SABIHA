import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_colors.dart';
import 'category_style.dart';

/// Gambar produk. Jika produk belum punya foto (atau gagal dimuat),
/// tampilkan ilustrasi ikon kategori di atas latar biru lembut.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.product, this.iconSize = 44});

  final Product product;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final image = product.image;
    final placeholder = _Placeholder(product: product, iconSize: iconSize);

    if (image == null || !image.startsWith('http')) return placeholder;

    return Image.network(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
      loadingBuilder: (context, child, progress) => progress == null ? child : placeholder,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.product, required this.iconSize});

  final Product product;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final style = CategoryStyle.of(product.category?.slug);

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.softGradient),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(iconSize * 0.4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: style.color.withValues(alpha: 0.12),
                blurRadius: iconSize * 0.6,
                offset: Offset(0, iconSize * 0.15),
              ),
            ],
          ),
          child: Icon(style.icon, size: iconSize, color: style.color),
        ),
      ),
    );
  }
}
