import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://a0ad-42-116-174-245.ngrok-free.app/api_app/public/api"; // Cập nhật URL ngrok

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _postData('login', {"email": email, "password": password});
  }

  Future<Map<String, dynamic>> register(String name, String email, String phone, String password) async {
    return await _postData('register', {
      "name": name,
      "email": email,
      "phone": phone,
      "password": password
    });
  }

  Future<Map<String, dynamic>> _postData(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true", // Thêm header để bỏ qua cảnh báo ngrok
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);
      print('POST $endpoint Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        return {"error": responseData["message"] ?? "Lỗi không xác định"};
      }
    } catch (e) {
      return {"error": "Không thể kết nối đến server. Kiểm tra mạng hoặc API: $e"};
    }
  }
}