import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = "http://10.0.3.2:8001/api"; // Địa chỉ cho Genymotion

  // Phương thức POST
  static Future<Map<String, dynamic>> postData(String url, Map<String, dynamic> data, {String? token}) async {
    try {
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http.post(
        Uri.parse("$baseUrl/$url"),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      print('POST Request URL: $baseUrl/$url');
      print('Request data: $data');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        return {"error": "Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại."};
      } else if (response.statusCode == 400) {
        return {"error": jsonDecode(response.body)["message"] ?? "Yêu cầu không hợp lệ."};
      } else {
        return {
          "error": "Lỗi không xác định: ${response.statusCode} - ${jsonDecode(response.body)["message"] ?? response.body}",
        };
      }
    } on TimeoutException {
      return {"error": "Kết nối đến server quá lâu. Vui lòng thử lại."};
    } on FormatException {
      return {"error": "Dữ liệu từ server không đúng định dạng."};
    } on http.ClientException {
      return {"error": "Không thể kết nối đến server. Kiểm tra API hoặc mạng."};
    } catch (e) {
      return {"error": "Đã xảy ra lỗi không xác định: $e"};
    }
  }

  // Phương thức GET
  static Future<dynamic> getData(String url, {String? token}) async {
    try {
      final headers = {
        "Accept": "application/json",
      };
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http.get(
        Uri.parse("$baseUrl/$url"),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('GET Request URL: $baseUrl/$url');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception("Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.");
      } else if (response.statusCode == 404) {
        throw Exception("Không tìm thấy dữ liệu: ${response.statusCode}");
      } else {
        throw Exception('Failed to load data: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      throw Exception("Kết nối đến server quá lâu. Vui lòng thử lại.");
    } on FormatException {
      throw Exception("Dữ liệu từ server không đúng định dạng.");
    } on http.ClientException {
      throw Exception("Không thể kết nối đến server. Kiểm tra API hoặc mạng.");
    } catch (e) {
      throw Exception("Đã xảy ra lỗi không xác định: $e");
    }
  }

  // Phương thức PUT
  static Future<Map<String, dynamic>> putData(String url, Map<String, dynamic> data, {String? token}) async {
    try {
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http.put(
        Uri.parse("$baseUrl/$url"),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      print('PUT Request URL: $baseUrl/$url');
      print('Request data: $data');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        return {"error": "Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại."};
      } else if (response.statusCode == 400) {
        return {"error": jsonDecode(response.body)["message"] ?? "Yêu cầu không hợp lệ."};
      } else {
        return {
          "error": "Lỗi không xác định: ${response.statusCode} - ${jsonDecode(response.body)["message"] ?? response.body}",
        };
      }
    } on TimeoutException {
      return {"error": "Kết nối đến server quá lâu. Vui lòng thử lại."};
    } on FormatException {
      return {"error": "Dữ liệu từ server không đúng định dạng."};
    } on http.ClientException {
      return {"error": "Không thể kết nối đến server. Kiểm tra API hoặc mạng."};
    } catch (e) {
      return {"error": "Đã xảy ra lỗi không xác định: $e"};
    }
  }

  // Phương thức DELETE
  static Future<Map<String, dynamic>> deleteData(String url, {String? token}) async {
    try {
      final headers = {
        "Accept": "application/json",
      };
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http.delete(
        Uri.parse("$baseUrl/$url"),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('DELETE Request URL: $baseUrl/$url');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return {"message": "Xóa thành công"};
      } else if (response.statusCode == 401) {
        return {"error": "Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại."};
      } else if (response.statusCode == 404) {
        return {"error": "Không tìm thấy dữ liệu để xóa: ${response.statusCode}"};
      } else {
        return {
          "error": "Lỗi không xác định: ${response.statusCode} - ${jsonDecode(response.body)["message"] ?? response.body}",
        };
      }
    } on TimeoutException {
      return {"error": "Kết nối đến server quá lâu. Vui lòng thử lại."};
    } on FormatException {
      return {"error": "Dữ liệu từ server không đúng định dạng."};
    } on http.ClientException {
      return {"error": "Không thể kết nối đến server. Kiểm tra API hoặc mạng."};
    } catch (e) {
      return {"error": "Đã xảy ra lỗi không xác định: $e"};
    }
  }
}