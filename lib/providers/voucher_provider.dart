import 'package:flutter/material.dart';
import '../../core/api/voucher_service.dart';
import '../../core/models/voucher.dart';

class VoucherProvider extends ChangeNotifier {
  List<Voucher> _vouchers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Voucher> get vouchers => _vouchers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchVouchers(String token) async {
    _isLoading = true;
    _errorMessage = null;
    print('Fetching vouchers with token: $token'); // Log token
    notifyListeners();

    try {
      final data = await VoucherService.getVouchers(token);
      _vouchers = data;
      print('Fetched vouchers in VoucherProvider: $_vouchers'); // Log danh sách voucher
    } catch (e) {
      _errorMessage = "Không thể tải danh sách voucher: $e";
      print('Error in VoucherProvider: $_errorMessage'); // Log lỗi
      _vouchers = []; // Đảm bảo danh sách rỗng nếu có lỗi
    }

    _isLoading = false;
    print('Loading state: $_isLoading'); // Log trạng thái loading
    notifyListeners();
  }
}