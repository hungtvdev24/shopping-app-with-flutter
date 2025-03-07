import 'package:flutter/material.dart';
import '../../core/api/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  List<dynamic> _products = []; // Danh sách sản phẩm
  bool _isLoading = false; // Trạng thái tải
  String? _errorMessage; // Thông báo lỗi
  bool _hasError = false; // Trạng thái có lỗi

  List<dynamic> get products => _products;
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

  // Làm mới danh sách sản phẩm
  Future<void> refreshProducts() async {
    await loadProducts(); // Gọi lại loadProducts
  }

  // Thêm phương thức để lấy sản phẩm theo ID (nếu cần)
  dynamic getProductById(int id) {
    return _products.firstWhere(
          (product) => product['id_sanPham'] == id,
      orElse: () => null,
    );
  }
}