import 'package:flutter/material.dart';
import '../../core/api/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<dynamic> _products = []; // Danh sách sản phẩm phổ biến
  List<dynamic> _suggestedProducts = []; // Danh sách sản phẩm gợi ý
  List<dynamic> _searchResults = []; // Danh sách kết quả tìm kiếm
  bool _isLoading = false; // Trạng thái tải
  bool _isSearching = false; // Trạng thái đang tìm kiếm
  String? _errorMessage; // Thông báo lỗi
  String? _searchErrorMessage; // Thông báo lỗi tìm kiếm
  bool _hasError = false; // Trạng thái có lỗi
  bool _hasSearchError = false; // Trạng thái có lỗi tìm kiếm

  List<dynamic> get products => _products;
  List<dynamic> get suggestedProducts => _suggestedProducts;
  List<dynamic> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String? get searchErrorMessage => _searchErrorMessage;
  bool get hasError => _hasError;
  bool get hasSearchError => _hasSearchError;

  ProductProvider() {
    loadProducts();
  }

  // Tải danh sách sản phẩm phổ biến
  Future<void> loadProducts() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _hasError = false;
    notifyListeners();

    try {
      final fetchedProducts = await _productService.fetchProducts();
      _products = fetchedProducts;
      if (_products.isEmpty) {
        _errorMessage = "Không có sản phẩm nào được tìm thấy.";
      }
      print('Fetched products in ProductProvider: $_products');
    } catch (e) {
      _errorMessage = "Lỗi khi tải sản phẩm: $e";
      _hasError = true;
      _products = [];
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Tìm kiếm sản phẩm
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchErrorMessage = null;
      _hasSearchError = false;
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchErrorMessage = null;
    _hasSearchError = false;
    notifyListeners();

    try {
      final results = await _productService.searchProducts(query);
      _searchResults = results;
      if (_searchResults.isEmpty) {
        _searchErrorMessage = "Không tìm thấy sản phẩm nào.";
      }
      print('Search results in ProductProvider: $_searchResults');
    } catch (e) {
      _searchErrorMessage = "Lỗi khi tìm kiếm sản phẩm: $e";
      _hasSearchError = true;
      _searchResults = [];
      print(_searchErrorMessage);
    }

    _isSearching = false;
    notifyListeners();
  }

  // Lấy sản phẩm gợi ý dựa trên danh mục
  Future<void> loadSuggestedProducts(int categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final allProducts = await _productService.fetchProducts();
      _suggestedProducts = allProducts.where((prod) => prod['id_danhMuc'] == categoryId).toList();
      if (_suggestedProducts.isEmpty) {
        _errorMessage = "Không có sản phẩm gợi ý nào.";
      }
    } catch (e) {
      _errorMessage = "Lỗi khi tải sản phẩm gợi ý: $e";
      _suggestedProducts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Làm mới danh sách sản phẩm
  Future<void> refreshProducts() async {
    await loadProducts();
  }

  // Thêm phương thức để lấy sản phẩm theo ID
  dynamic getProductById(int id) {
    return _products.firstWhere(
          (product) => product['id_sanPham'] == id,
      orElse: () => null,
    );
  }

  // Xóa kết quả tìm kiếm
  void clearSearch() {
    _searchResults = [];
    _searchErrorMessage = null;
    _hasSearchError = false;
    _isSearching = false;
    notifyListeners();
  }
}