import 'package:flutter/foundation.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../services/api_client.dart';
import '../services/catalog_service.dart';

class CatalogProvider extends ChangeNotifier {
  final _service = CatalogService.instance;

  List<ProductCategory> categories = [];
  List<Product> products = [];

  int? selectedCategoryId;
  String searchQuery = '';

  bool isLoadingCategories = false;
  bool isLoadingProducts = false;
  bool isLoadingMore = false;
  String? errorMessage;

  int _currentPage = 1;
  bool _hasMore = true;

  Future<void> loadInitial() async {
    await Future.wait([loadCategories(), loadProducts(reset: true)]);
  }

  Future<void> loadCategories() async {
    isLoadingCategories = true;
    notifyListeners();

    try {
      categories = await _service.fetchCategories();
    } catch (_) {
      // Kategori gagal dimuat tidak menghalangi katalog produk tetap tampil.
    } finally {
      isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      products = [];
    }

    isLoadingProducts = true;
    errorMessage = null;
    notifyListeners();

    try {
      final page = await _service.fetchProducts(
        page: _currentPage,
        categoryId: selectedCategoryId,
        search: searchQuery,
      );
      products = page.items;
      _hasMore = page.hasMore;
    } catch (e) {
      errorMessage = apiErrorMessage(e);
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore || isLoadingProducts) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = await _service.fetchProducts(
        page: _currentPage + 1,
        categoryId: selectedCategoryId,
        search: searchQuery,
      );
      _currentPage = nextPage.currentPage;
      _hasMore = nextPage.hasMore;
      products = [...products, ...nextPage.items];
    } catch (_) {
      // Biarkan pengguna coba scroll lagi; tidak perlu mengganggu daftar yang sudah tampil.
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void selectCategory(int? categoryId) {
    if (selectedCategoryId == categoryId) return;
    selectedCategoryId = categoryId;
    loadProducts(reset: true);
  }

  void search(String query) {
    searchQuery = query;
    loadProducts(reset: true);
  }

  void resetFilters() {
    selectedCategoryId = null;
    searchQuery = '';
    loadProducts(reset: true);
  }
}
