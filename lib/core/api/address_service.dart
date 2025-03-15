import '../../core/api/api_client.dart';
import '../../core/models/address.dart';

class AddressService {
  // Lấy danh sách địa chỉ
  static Future<List<Address>> getAddresses(String token) async {
    final response = await ApiClient.getData('addresses', token: token);
    // response có thể là List hoặc Map tuỳ API. Ở đây giả sử trả về List
    if (response is List) {
      return response.map((item) => Address.fromJson(item)).toList();
    }
    return [];
  }

  // Tạo mới địa chỉ
  static Future<Address?> createAddress(String token, Address address) async {
    final response = await ApiClient.postData('addresses', address.toJson(), token: token);
    // Nếu thành công, API có thể trả về { "data": { ... } }
    if (response is Map && response['data'] != null) {
      return Address.fromJson(response['data']);
    }
    return null;
  }

  // Xóa địa chỉ

}
