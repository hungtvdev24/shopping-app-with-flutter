import 'dart:convert';
import 'package:flutter/foundation.dart'; // Để kiểm tra kDebugMode
import '../api/api_client.dart'; // Import ApiClient

class CartService {
  static const String baseUrl = 'http://10.0.3.2:8001/api';

  static Future<Map<String, dynamic>> getCart(String token) async {
    try {
      // Sử dụng ApiClient.getData thay vì gọi trực tiếp http.get
      final response = await ApiClient.getData('cart', token: token);
      return response as Map<String, dynamic>;
    } catch (e) {
      // Xử lý lỗi chi tiết hơn
      if (e.toString().contains('401')) {
        throw Exception('Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.');
      } else if (e.toString().contains('404')) {
        throw Exception('Không tìm thấy giỏ hàng.');
      } else {
        throw Exception('Lỗi khi tải giỏ hàng: $e');
      }
    }
  }

  // Phương thức cập nhật số lượng sản phẩm trong giỏ hàng
  static Future<Map<String, dynamic>> updateCartItemQuantity(
      String token, int idMucGioHang, int soLuong) async {
    try {
      final response = await ApiClient.postData(
        'cart/update/$idMucGioHang',
        {"soLuong": soLuong},
        token: token,
      );

      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }

      return response;
    } catch (e) {
      throw Exception('Lỗi khi cập nhật số lượng: $e');
    }
  }

  // Phương thức xóa mục khỏi giỏ hàng
  static Future<Map<String, dynamic>> removeCartItem(String token, int idMucGioHang) async {
    try {
      final response = await ApiClient.postData(
        'cart/remove/$idMucGioHang',
        {},
        token: token,
      );

      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }

      return response;
    } catch (e) {
      throw Exception('Lỗi khi xóa mục giỏ hàng: $e');
    }
  }
}