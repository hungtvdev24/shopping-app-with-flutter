import '../api/api_client.dart';

class CheckoutService {
  /// Gửi yêu cầu "đặt hàng" (checkout) lên server.
  ///
  /// [token] là Bearer token của người dùng.
  /// [idDiaChi] là ID địa chỉ nhận hàng.
  /// [phuongThucThanhToan] là "COD" hoặc "VN_PAY".
  /// [selectedItems] là danh sách sản phẩm đã chọn.
  ///
  /// Trả về Map JSON, ví dụ:
  ///   - {"message":"Đặt hàng thành công","donHang":{...}}
  ///   - hoặc {"error":"..."}
  static Future<Map<String, dynamic>> placeOrder({
    required String token,
    required int idDiaChi,
    required String phuongThucThanhToan,
    required List<Map<String, dynamic>> selectedItems,
  }) async {
    try {
      // Chuẩn bị data JSON gửi lên server
      final data = {
        'id_diaChi': idDiaChi,
        'phuongThucThanhToan': phuongThucThanhToan,
        'items': selectedItems.map((item) {
          return {
            'id_mucGioHang': item['id_mucGioHang'],
            'id_sanPham': item['id_sanPham'],
            'soLuong': item['soLuong'],
          };
        }).toList(),
      };

      // Gọi POST đến endpoint "checkout"
      final response = await ApiClient.postData(
        'checkout',
        data,
        token: token,
      );

      // Nếu API trả về {"error": "..."} thì ném Exception
      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }

      // Ngược lại, trả về kết quả JSON (thường có "message", "donHang", ...)
      return response;
    } catch (e) {
      throw Exception('Lỗi khi đặt hàng (checkout): $e');
    }
  }
}
