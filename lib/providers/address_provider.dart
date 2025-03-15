import 'package:flutter/material.dart';
import '../../core/api/address_service.dart';
import '../../core/models/address.dart';

class AddressProvider extends ChangeNotifier {
  List<Address> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Lấy danh sách địa chỉ
  Future<void> fetchAddresses(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await AddressService.getAddresses(token);
      _addresses = data;
    } catch (e) {
      _errorMessage = "Không thể tải địa chỉ: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Thêm địa chỉ
  Future<void> addAddress(String token, Address address) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newAddr = await AddressService.createAddress(token, address);
      if (newAddr != null) {
        _addresses.add(newAddr);
      } else {
        _errorMessage = "Không thể tạo địa chỉ";
      }
    } catch (e) {
      _errorMessage = "Lỗi khi tạo địa chỉ: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Xóa địa chỉ
}
