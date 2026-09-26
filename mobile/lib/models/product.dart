import 'category.dart';

class Product {
  final int id;
  final int categoryId;
  final String name;
  final String sku;
  final String? description;
  final int price;
  final int stock;
  final String unit;
  final String? image;
  final bool isActive;
  final ProductCategory? category;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    required this.unit,
    required this.isActive,
    this.description,
    this.image,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      sku: json['sku'] as String,
      description: json['description'] as String?,
      price: json['price'] as int,
      stock: json['stock'] as int,
      unit: json['unit'] as String? ?? 'pcs',
      image: json['image'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      category: json['category'] != null
          ? ProductCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get inStock => stock > 0;
}

/// Format harga rupiah, mis. 9500 -> "Rp9.500".
String formatRupiah(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    final reverseIndex = digits.length - i;
    buffer.write(digits[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return 'Rp$buffer';
}
