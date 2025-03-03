import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;

  UserProvider() {
    _loadToken();
  }

  // Tải token từ SharedPreferences
  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      fetchUserData();
    }
    notifyListeners();
  }

  // Lưu token sau khi đăng nhập
  Future<void> setToken(String token) async {
    _token = token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    fetchUserData();
    notifyListeners();
  }

  Future<void> fetchUserData() async {
    if (_token == null) {
      _errorMessage = "Chưa đăng nhập. Vui lòng đăng nhập.";
      _userData = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.getData('user', token: _token);
      print('User Data Response: $response');

      if (response is Map<String, dynamic> && response.containsKey('error')) {
        _errorMessage = response['error'];
        _userData = null;
      } else {
        _userData = response['user']; // Lấy dữ liệu từ key 'user'
      }
    } catch (e) {
      _errorMessage = "Lỗi khi tải thông tin người dùng: $e";
      _userData = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _userData = null;
    _token = null;
    notifyListeners();
    Navigator.pushReplacementNamed(context, '/login');
  }
}