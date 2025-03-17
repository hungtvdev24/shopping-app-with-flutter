import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/myorder_provider.dart';
import '../../providers/user_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final myOrderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    if (userProvider.token != null) {
      myOrderProvider.loadOrderDetail(userProvider.token!, widget.orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyOrderProvider>(
      builder: (context, orderProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white, // Nền trắng
          appBar: AppBar(
            title: const Text("Chi tiết đơn hàng"),
            backgroundColor: Colors.grey[200], // Xám nhạt
            elevation: 0,
            titleTextStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body: orderProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : orderProvider.errorMessage != null
              ? Center(
            child: Text(
              orderProvider.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          )
              : orderProvider.orderDetail == null
              ? const Center(
            child: Text(
              "Không tìm thấy thông tin đơn hàng.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          )
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Đơn hàng #${orderProvider.orderDetail!['id_donHang']}",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow("Người nhận",
                      orderProvider.orderDetail!['ten_nguoiNhan']),
                  _buildInfoRow("SĐT",
                      orderProvider.orderDetail!['sdt_nhanHang']),
                  _buildInfoRow(
                    "Địa chỉ",
                    "${orderProvider.orderDetail!['ten_nha']}, ${orderProvider.orderDetail!['xa']}, ${orderProvider.orderDetail!['huyen']}, ${orderProvider.orderDetail!['tinh']}",
                  ),
                  _buildInfoRow(
                      "Phương thức thanh toán",
                      orderProvider
                          .orderDetail!['phuongThucThanhToan']),
                  _buildInfoRow("Tổng tiền",
                      "${orderProvider.orderDetail!['tongTien']} VNĐ"),
                  _buildInfoRow("Trạng thái",
                      orderProvider.orderDetail!['trangThaiDonHang']),
                  const Divider(height: 32),
                  const Text(
                    "Sản phẩm trong đơn hàng:",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  orderProvider.orderDetail!['chiTietDonHang'] !=
                      null &&
                      orderProvider.orderDetail![
                      'chiTietDonHang']!
                          .isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    itemCount: orderProvider
                        .orderDetail!['chiTietDonHang']
                        .length,
                    itemBuilder: (context, index) {
                      final item = orderProvider
                          .orderDetail!['chiTietDonHang']
                      [index];
                      return Card(
                        color: Colors.grey[100], // Xám nhạt
                        margin: const EdgeInsets.symmetric(
                            vertical: 4),
                        child: ListTile(
                          title: Text(
                            item['sanPham'] != null
                                ? item['sanPham']
                            ['tenSanPham']
                                : "Sản phẩm #${item['id_sanPham']}",
                            style: const TextStyle(
                                fontWeight:
                                FontWeight.bold),
                          ),
                          subtitle: Text(
                              "Số lượng: ${item['soLuong']}"),
                          trailing:
                          Text("${item['gia']} VNĐ"),
                        ),
                      );
                    },
                  )
                      : const Text(
                      "Không có sản phẩm nào trong đơn hàng."),
                  const SizedBox(height: 20),
                  if (orderProvider.orderDetail![
                  'trangThaiDonHang'] ==
                      'cho_xac_nhan')
                    ElevatedButton(
                      onPressed: () async {
                        final userProvider = Provider.of<
                            UserProvider>(context,
                            listen: false);
                        final success =
                        await orderProvider.cancelOrder(
                            userProvider.token!,
                            orderProvider
                                .orderDetail!['id_donHang']);
                        if (success) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                              content: Text(
                                  "Đã hủy đơn hàng thành công!")));
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                              content: Text(
                                  orderProvider.errorMessage ??
                                      "Lỗi khi hủy đơn hàng")));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[300], // Đỏ nhạt
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Hủy đơn hàng",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}