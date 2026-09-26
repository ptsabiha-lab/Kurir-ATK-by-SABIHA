import '../models/category.dart';
import '../models/product.dart';
import 'api_client.dart';

class ProductPage {
  final List<Product> items;
  final int currentPage;
  final int lastPage;

  ProductPage({required this.items, required this.currentPage, required this.lastPage});

  bool get hasMore => currentPage < lastPage;
}

class CatalogService {
  CatalogService._();

  static final CatalogService instance = CatalogService._();

  final _dio = ApiClient.instance.dio;

  Future<List<ProductCategory>> fetchCategories() async {
    final response = await _dio.get('/categories');
    final data = response.data as List;
    return data
        .map((json) => ProductCategory.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ProductPage> fetchProducts({
    int page = 1,
    int? categoryId,
    String? search,
  }) async {
    final response = await _dio.get('/products', queryParameters: {
      'page': page,
      'category_id': ?categoryId,
      if (search != null && search.isNotEmpty) 'search': search,
    });

    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] as List)
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();

    return ProductPage(
      items: items,
      currentPage: data['current_page'] as int,
      lastPage: data['last_page'] as int,
    );
  }

  Future<Product> fetchProduct(int id) async {
    final response = await _dio.get('/products/$id');
    return Product.fromJson(response.data as Map<String, dynamic>);
  }
}
