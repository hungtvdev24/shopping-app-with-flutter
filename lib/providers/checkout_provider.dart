import 'package:flutter/material.dart';
import '../core/api/checkout_service.dart';

class CheckoutProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? orderData;

  /// Gọi API checkout để đặt hàng, truyền danh sách sản phẩm đã chọn
  Future<void> placeOrder({
    required String token,
    required int idDiaChi,
    required String phuongThucThanhToan,
    required List<Map<String, dynamic>> selectedItems,
  }) async {
    isLoading = true;
    errorMessage = null;
    orderData = null;
    notifyListeners();

    try {
      final response = await CheckoutService.placeOrder(
        token: token,
        idDiaChi: idDiaChi,
        phuongThucThanhToan: phuongThucThanhToan,
        selectedItems: selectedItems,
      );

      if (response.containsKey('error')) {
        errorMessage = response['error'];
      } else {
        orderData = response;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
