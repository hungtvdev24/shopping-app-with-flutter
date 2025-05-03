import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = "https://89c3-42-114-39-2.ngrok-free.app/api";

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<Map<String, dynamic>> postData(String url, Map<String, dynamic> data, {String? token}) async {
    try {
      token ??= await getToken();
      if (token == null) {
        throw Exception("Không tìm thấy token. Vui lòng đăng nhập lại.");
      }
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "ngrok-skip-browser-warning": "true",
        "Authorization": "Bearer $token",
      };

      final fullUrl = url.startsWith('http') ? url : "$baseUrl/$url";

      final response = await http.post(
        Uri.parse(fullUrl),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      print('POST Request URL: $fullUrl');
      print('Request data: $data');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody["message"] ?? "Lỗi: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print('Error in postData: $e');
      rethrow;
    }
  }

  static Future<dynamic> getData(String url, {String? token}) async {
    try {
      token ??= await getToken();
      if (token == null) {
        throw Exception("Không tìm thấy token. Vui lòng đăng nhập lại.");
      }
      final headers = {
        "Accept": "application/json",
        "ngrok-skip-browser-warning": "true",
        "Authorization": "Bearer $token",
      };

      final fullUrl = url.startsWith('http') ? url : "$baseUrl/$url";

      final response = await http.get(
        Uri.parse(fullUrl),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('GET Request URL: $fullUrl');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody["message"] ?? "Lỗi: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print('Error in getData: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> putData(String url, Map<String, dynamic> data, {String? token}) async {
    try {
      token ??= await getToken();
      if (token == null) {
        throw Exception("Không tìm thấy token. Vui lòng đăng nhập lại.");
      }
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "ngrok-skip-browser-warning": "true",
        "Authorization": "Bearer $token",
      };

      final fullUrl = url.startsWith('http') ? url : "$baseUrl/$url";

      final response = await http.put(
        Uri.parse(fullUrl),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      print('PUT Request URL: $fullUrl');
      print('Request data: $data');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody["message"] ?? "Lỗi: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print('Error in putData: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteData(String url, {String? token}) async {
    try {
      token ??= await getToken();
      if (token == null) {
        throw Exception("Không tìm thấy token. Vui lòng đăng nhập lại.");
      }
      final headers = {
        "Accept": "application/json",
        "ngrok-skip-browser-warning": "true",
        "Authorization": "Bearer $token",
      };

      final fullUrl = url.startsWith('http') ? url : "$baseUrl/$url";

      final response = await http.delete(
        Uri.parse(fullUrl),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('DELETE Request URL: $fullUrl');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return {"message": "Xóa thành công"};
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody["message"] ?? "Lỗi: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print('Error in deleteData: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> sendMessage(
      int receiverId,
      String content, {
        String receiverType = 'App\\Models\\User',
      }) async {
    return await postData('messages', {
      'receiver_id': receiverId,
      'receiver_type': receiverType,
      'content': content,
    });
  }

  static Future<List<dynamic>> getMessages(
      int receiverId, {
        String receiverType = 'App\\Models\\User',
      }) async {
    final uri = Uri.parse("$baseUrl/messages/$receiverId")
        .replace(queryParameters: {'receiver_type': receiverType});
    final response = await getData(uri.toString());
    return response['data'];
  }

  static Future<Map<String, dynamic>> markMessageAsRead(int messageId) async {
    return await postData('messages/$messageId/read', {});
  }

  static Future<List<dynamic>> getUsers() async {
    final response = await getData('users');
    return response['users'];
  }

  static Future<Map<String, dynamic>> getUser() async {
    final response = await getData('user');
    return response['user'];
  }

  static Future<List<dynamic>> getAdmins() async {
    final response = await getData('admins');
    return response['admins'];
  }
}