import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiClient.postData('login', {"email": email, "password": password});
    if (response.containsKey('token')) {
      // Lưu token sau khi đăng nhập thành công
      await saveToken(response['token']);
    }
    return response;
  }

  Future<Map<String, dynamic>> register(String name, String email, String phone, String password) async {
    final response = await ApiClient.postData('register', {
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
    });
    if (response.containsKey('token')) {
      // Lưu token sau khi đăng ký thành công (nếu API trả về token)
      await saveToken(response['token']);
    }
    return response;
  }

  // Lưu token vào shared_preferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Lấy token từ shared_preferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Xóa token (khi đăng xuất)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Lấy thông tin người dùng hiện tại
  Future<Map<String, dynamic>> getUser() async {
    try {
      return await ApiClient.getUser();
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin người dùng: $e');
    }
  }
}