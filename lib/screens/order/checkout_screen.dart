import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/user_provider.dart';

class CheckoutScreen extends StatefulWidget {
  /// Danh sách sản phẩm đã chọn từ CartScreen
  final List<Map<String, dynamic>> selectedItems;

  /// Tổng tiền (sau giảm giá, phí ship, v.v.) từ CartScreen
  final double totalPrice;

  const CheckoutScreen({
    Key? key,
    required this.selectedItems,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int selectedAddressId = 0; // Lấy danh sách địa chỉ từ AddressProvider hoặc từ dữ liệu khác
  String paymentMethod = 'COD'; // Hoặc 'VN_PAY'

  @override
  Widget build(BuildContext context) {
    final checkoutProvider = Provider.of<CheckoutProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh Toán'),
      ),
      body: checkoutProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Hiển thị danh sách địa chỉ (ví dụ đơn giản)
            _buildAddressSection(),
            const SizedBox(height: 20),
            // Chọn phương thức thanh toán
            _buildPaymentMethodSection(),
            const SizedBox(height: 20),
            // Hiển thị tóm tắt: số sản phẩm đã chọn, tổng tiền
            Text(
              'Số sản phẩm đã chọn: ${widget.selectedItems.length}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Tổng tiền: ${widget.totalPrice}đ',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                final token = userProvider.token;
                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bạn chưa đăng nhập!')),
                  );
                  return;
                }

                // Gọi API đặt hàng, truyền danh sách sản phẩm đã chọn
                await checkoutProvider.placeOrder(
                  token: token,
                  idDiaChi: selectedAddressId,
                  phuongThucThanhToan: paymentMethod,
                  selectedItems: widget.selectedItems,
                );

                if (checkoutProvider.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(checkoutProvider.errorMessage!)),
                  );
                } else {
                  final msg = checkoutProvider.orderData?['message'] ?? 'Đặt hàng thành công!';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg)),
                  );

                  // Trả về true để CartScreen reload
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Đặt hàng'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    // Ví dụ cứng 2 địa chỉ, thực tế bạn nên load từ AddressProvider
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn Địa Chỉ Giao Hàng',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        RadioListTile<int>(
          title: const Text('Địa chỉ 1'),
          value: 1,
          groupValue: selectedAddressId,
          onChanged: (value) {
            setState(() {
              selectedAddressId = value ?? 0;
            });
          },
        ),
        RadioListTile<int>(
          title: const Text('Địa chỉ 2'),
          value: 2,
          groupValue: selectedAddressId,
          onChanged: (value) {
            setState(() {
              selectedAddressId = value ?? 0;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn Phương Thức Thanh Toán',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        RadioListTile<String>(
          title: const Text('Thanh toán khi nhận hàng (COD)'),
          value: 'COD',
          groupValue: paymentMethod,
          onChanged: (value) {
            setState(() {
              paymentMethod = value ?? 'COD';
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Thanh toán bằng VN Pay'),
          value: 'VN_PAY',
          groupValue: paymentMethod,
          onChanged: (value) {
            setState(() {
              paymentMethod = value ?? 'VN_PAY';
            });
          },
        ),
      ],
    );
  }
}
