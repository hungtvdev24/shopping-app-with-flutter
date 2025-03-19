import 'package:flutter/material.dart';
import '../../core/api/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  List<dynamic> _products = []; // Danh sách sản phẩm
  List<dynamic> _suggestedProducts = []; // Danh sách sản phẩm gợi ý
  bool _isLoading = false; // Trạng thái tải
  String? _errorMessage; // Thông báo lỗi
  bool _hasError = false; // Trạng thái có lỗi

  List<dynamic> get products => _products;
  List<dynamic> get suggestedProducts => _suggestedProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;

  ProductProvider() {
    loadProducts();
  }

  // Tải danh sách sản phẩm
  Future<void> loadProducts() async {
    if (_isLoading) return; // Ngăn chặn gọi lặp khi đang tải

    _isLoading = true;
    _errorMessage = null;
    _hasError = false;
    notifyListeners();

    try {
      final fetchedProducts = await _productService.fetchProducts();
      _products = fetchedProducts; // Cập nhật danh sách sản phẩm
      if (_products.isEmpty) {
        _errorMessage = "Không có sản phẩm nào được tìm thấy.";
      }
      print('Fetched products in ProductProvider: $_products');
    } catch (e) {
      _errorMessage = "Lỗi khi tải sản phẩm: $e";
      _hasError = true;
      _products = []; // Reset danh sách nếu lỗi
      print(_errorMessage);
    }

    _isLoading = false;
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
    await loadProducts(); // Gọi lại loadProducts
  }

  // Thêm phương thức để lấy sản phẩm theo ID
  dynamic getProductById(int id) {
    return _products.firstWhere(
          (product) => product['id_sanPham'] == id,
      orElse: () => null,
    );
  }
}