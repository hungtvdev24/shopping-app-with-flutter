import 'package:flutter/material.dart';
import '../core/api/api_client.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  Map<String, dynamic>? _userData; // Biến để lưu thông tin người dùng

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData; // Getter cho userData

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Thử đăng nhập: email=$email, password=$password');
      final response = await ApiClient.postData('login', {
        'email': email,
        'password': password,
      });

      print('Phản hồi đăng nhập: $response');
      if (response.containsKey('token')) {
        _token = response['token'] as String;
        _errorMessage = null;
        print('Đăng nhập thành công, Token: $_token');
        // Gọi API để lấy thông tin người dùng sau khi đăng nhập thành công
        await fetchUserData(); // Sửa _fetchUserData thành fetchUserData
      } else if (response.containsKey('error')) {
        _errorMessage = response['error'] as String;
        print('Đăng nhập thất bại: $_errorMessage');
      } else {
        _errorMessage = 'Đăng nhập thất bại. Vui lòng kiểm tra lại.';
        print('Đăng nhập thất bại: Phản hồi không mong đợi - $response');
      }
      _isLoading = false;
      notifyListeners();
      return _token != null;
    } catch (e) {
      _errorMessage = "Lỗi khi đăng nhập: $e";
      _isLoading = false;
      print('Lỗi đăng nhập: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Thử đăng ký: name=$name, email=$email, phone=$phone, password=$password');
      final response = await ApiClient.postData('register', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });

      print('Phản hồi đăng ký: $response');
      if (response.containsKey('message') && response['message'] == 'Đăng ký thành công') {
        _errorMessage = null;
        print('Đăng ký thành công');
      } else if (response.containsKey('error')) {
        _errorMessage = response['error'] as String;
        print('Đăng ký thất bại: $_errorMessage');
      } else {
        _errorMessage = 'Đăng ký thất bại. Vui lòng kiểm tra lại.';
        print('Đăng ký thất bại: Phản hồi không mong đợi - $response');
      }
      _isLoading = false;
      notifyListeners();
      return _errorMessage == null;
    } catch (e) {
      _errorMessage = "Lỗi khi đăng ký: $e";
      _isLoading = false;
      print('Lỗi đăng ký: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  // Phương thức để lấy thông tin người dùng
  Future<void> fetchUserData() async {
    if (_token == null) {
      _errorMessage = "Không có token để lấy thông tin người dùng.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.getData('user', token: _token);
      print('Phản hồi lấy dữ liệu người dùng: $response');
      if (response.containsKey('id')) {
        _userData = response; // Lưu thông tin người dùng
        _errorMessage = null;
        print('Lấy dữ liệu người dùng thành công: $_userData');
      } else {
        _errorMessage = 'Không thể lấy thông tin người dùng.';
        print('Lấy dữ liệu người dùng thất bại: $response');
      }
    } catch (e) {
      _errorMessage = "Lỗi khi lấy thông tin người dùng: $e";
      print('Lỗi lấy dữ liệu người dùng: $_errorMessage');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Phương thức đăng xuất
  void logout(BuildContext context) {
    _token = null;
    _userData = null;
    _errorMessage = null;
    notifyListeners();
    Navigator.pushReplacementNamed(context, '/login');
  }
}