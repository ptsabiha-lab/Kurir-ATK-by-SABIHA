class ProductCategory {
  final int id;
  final String name;
  final String slug;
  final int? productsCount;

  ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.productsCount,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      productsCount: json['products_count'] as int?,
    );
  }
}
