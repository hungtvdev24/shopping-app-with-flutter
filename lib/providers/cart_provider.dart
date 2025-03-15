import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api/cart_service.dart';
import '../providers/product_provider.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setCartItems(List<Map<String, dynamic>> items) {
    _cartItems = items;
    print('Cart items updated: $_cartItems');
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    print('Loading state updated: $_isLoading');
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    print('Error message updated: $_errorMessage');
    notifyListeners();
  }

  Future<void> loadCart(String token, BuildContext context) async {
    if (token.isEmpty) {
      setLoading(false);
      setErrorMessage('Vui lòng đăng nhập để xem giỏ hàng.');
      setCartItems([]);
      return;
    }

    setLoading(true);
    setErrorMessage(null);

    try {
      final response = await CartService.getCart(token);
      print('Cart API response: $response');

      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      if (response['cart'] != null && response['cart']['muc_gio_hangs'] != null) {
        final cartItems = List<Map<String, dynamic>>.from(
          response['cart']['muc_gio_hangs'].map((item) {
            print('Processing cart item: $item');
            final product = productProvider.getProductById(item['id_sanPham']);
            print('Product from ProductProvider: $product');
            return {
              'id_mucGioHang': item['id_mucGioHang'],
              'id_sanPham': item['id_sanPham'],
              'soLuong': item['soLuong'],
              'gia': double.tryParse(item['gia'].toString()) ?? 0.0,
              'name': item['product']?['tenSanPham'] ?? product?['tenSanPham'] ?? 'Không có tên',
              'thuongHieu': item['product']?['thuongHieu'] ?? product?['thuongHieu'] ?? 'Không có thương hiệu',
              'image': product?['urlHinhAnh'] ?? 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=150',
              'selected': false,
            };
          }),
        );
        setCartItems(cartItems);
      } else {
        print('Cart response is empty or invalid: $response');
        setCartItems([]);
        setErrorMessage('Giỏ hàng trống hoặc không có dữ liệu.');
      }
    } catch (e) {
      print('Error in loadCart: $e');
      setErrorMessage('Lỗi khi tải giỏ hàng: $e');
      setCartItems([]);
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateCartItemQuantity(String token, int idMucGioHang, int quantity, BuildContext context) async {
    try {
      await CartService.updateCartItemQuantity(token, idMucGioHang, quantity);
      await loadCart(token, context);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật số lượng: $e');
    }
  }

  Future<void> removeCartItem(String token, int idMucGioHang, BuildContext context) async {
    try {
      await CartService.removeCartItem(token, idMucGioHang);
      await loadCart(token, context);
    } catch (e) {
      throw Exception('Lỗi khi xóa mục: $e');
    }
  }

  Future<void> addToCart(String token, int productId, int quantity, BuildContext context) async {
    try {
      setLoading(true);
      await CartService.addToCart(token, productId, quantity);
      await loadCart(token, context);
    } catch (e) {
      setErrorMessage('Lỗi khi thêm sản phẩm vào giỏ hàng: $e');
    } finally {
      setLoading(false);
    }
  }
}