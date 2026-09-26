import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Ikon logo Kurir ATK: kotak membulat bergradien biru dengan ikon truk.
///
/// Gunakan [onDark] saat logo diletakkan di atas latar biru/gelap.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: onDark ? null : AppColors.brandGradient,
        color: onDark ? Colors.white : null,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: (onDark ? Colors.black : AppColors.primary).withValues(alpha: 0.18),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Icon(
        Icons.local_shipping_rounded,
        size: size * 0.52,
        color: onDark ? AppColors.primary : Colors.white,
      ),
    );
  }
}

/// Tulisan "Kurir ATK" dengan aksen warna pada kata "ATK".
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 22, this.onDark = false});

  final double fontSize;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      height: 1.1,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Kurir ',
            style: base.copyWith(color: onDark ? Colors.white : AppColors.navy),
          ),
          TextSpan(
            text: 'ATK',
            style: base.copyWith(color: onDark ? const Color(0xFFBFD7FF) : AppColors.primary),
          ),
        ],
      ),
      semanticsLabel: 'Kurir ATK',
    );
  }
}
